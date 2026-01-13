"""
Campus Connect - API Views
"""

from rest_framework import generics, status, permissions, filters, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.shortcuts import get_object_or_404
from django.db.models import Q
from django_filters.rest_framework import DjangoFilterBackend

from .models import User, Course, Group, Grade, Attendance, CourseFile, Timetable, CourseAssignment, Message, Notification, ScheduleSession
from .serializers import *
from .permissions import IsAdmin, IsTeacher, IsStudent, IsApprovedStudent


# Authentication Views

class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        return Response({
            'message': 'Registration successful. Awaiting admin approval.',
            'user': UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        
        # Generate JWT tokens
        refresh = RefreshToken.for_user(user)
        
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserSerializer(user).data
        })


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        return Response({'message': 'Logout successful'}, status=status.HTTP_200_OK)


class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_object(self):
        return self.request.user


class UserSearchView(generics.ListAPIView):
    serializer_class = UserSearchSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['first_name', 'last_name', 'username', 'email']

    def get_queryset(self):
        return User.objects.filter(is_active=True).filter(
            Q(role=User.STUDENT, is_approved=True) |
            Q(role=User.TEACHER) |
            Q(role=User.ADMIN) |
            Q(is_staff=True) |
            Q(is_superuser=True)
        ).exclude(id=self.request.user.id).distinct()


# Admin Views - User Management

class PendingStudentsView(generics.ListAPIView):
    serializer_class = StudentDetailSerializer
    permission_classes = [IsAdmin]
    
    def get_queryset(self):
        return User.objects.filter(role=User.STUDENT, is_approved=False)


class ApproveStudentView(APIView):
    """
    Approve a student or teacher registration
    """
    permission_classes = [IsAdmin]

    def post(self, request, pk):
        try:
            user = User.objects.get(pk=pk)
            user.is_approved = True
            user.rejection_reason = None
            user.save()
            return Response({
                'message': f'{user.role.capitalize()} approved successfully',
                'user': UserSerializer(user).data
            })
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    
class RejectStudentView(APIView):
    permission_classes = [IsAdmin]

    def post(self, request, pk):
        reason = request.data.get('reason', 'Requirements not met')
        try:
            user = User.objects.get(pk=pk)
            user.is_approved = False
            user.rejection_reason = reason
            user.save()
            return Response({'message': f'{user.role.capitalize()} rejected', 'reason': reason})
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)


class DeleteStudentView(generics.DestroyAPIView):
    permission_classes = [IsAdmin]
    queryset = User.objects.filter(role=User.STUDENT)


class StudentListView(generics.ListAPIView):
    serializer_class = StudentDetailSerializer
    permission_classes = [IsAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['is_approved', 'group', 'program', 'semester']
    search_fields = ['username', 'first_name', 'last_name', 'email', 'student_id']
    ordering_fields = ['username', 'created_at', 'student_id']
    
    def get_queryset(self):
        return User.objects.filter(role=User.STUDENT)


class AssignStudentToGroupView(APIView):
    permission_classes = [IsAdmin]
    
    def post(self, request):
        student_id = request.data.get('student_id')
        group_id = request.data.get('group_id')
        
        try:
            student = User.objects.get(pk=student_id, role=User.STUDENT)
            group = Group.objects.get(pk=group_id)
            
            student.group = group
            student.save()
            
            return Response({
                'message': f'Student assigned to {group.name}',
                'student': UserSerializer(student).data
            })
        except User.DoesNotExist:
            return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)
        except Group.DoesNotExist:
            return Response({'error': 'Group not found'}, status=status.HTTP_404_NOT_FOUND)


class TeacherListView(generics.ListAPIView):
    serializer_class = TeacherDetailSerializer
    permission_classes = [IsAdmin]
    filter_backends = [filters.SearchFilter]
    search_fields = ['username', 'first_name', 'last_name', 'email']
    queryset = User.objects.filter(role=User.TEACHER)


class CreateTeacherView(generics.CreateAPIView):
    permission_classes = [IsAdmin]
    
    def post(self, request):
        data = request.data
        
        # Validate required fields
        required = ['username', 'email', 'password']
        if not all(field in data for field in required):
            return Response(
                {'error': 'Missing required fields'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Create teacher
        teacher = User.objects.create_user(
            username=data['username'],
            email=data['email'],
            password=data['password'],
            first_name=data.get('first_name', ''),
            last_name=data.get('last_name', ''),
            role=User.TEACHER,
            is_approved=True
        )
        
        return Response({
            'message': 'Teacher created successfully',
            'teacher': UserSerializer(teacher).data
        }, status=status.HTTP_201_CREATED)


class DeleteTeacherView(generics.DestroyAPIView):
    permission_classes = [IsAdmin]
    queryset = User.objects.filter(role=User.TEACHER)


# Course Management Views

class CourseListCreateView(generics.ListCreateAPIView):
    queryset = Course.objects.all()
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['code', 'name']
    ordering_fields = ['code', 'name', 'credits']
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return CourseCreateSerializer
        return CourseSerializer
    
    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


class CourseDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    
    def get_permissions(self):
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


class TeacherCoursesView(generics.ListAPIView):
    serializer_class = CourseAssignmentSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        return CourseAssignment.objects.filter(teacher=self.request.user)


class StudentCoursesView(generics.ListAPIView):
    serializer_class = CourseAssignmentSerializer
    permission_classes = [IsStudent]
    
    def get_queryset(self):
        student = self.request.user
        if student.group:
            return CourseAssignment.objects.filter(group=student.group)
        return CourseAssignment.objects.none()


class AssignCourseToGroupView(APIView):
    permission_classes = [IsAdmin]
    
    def post(self, request):
        course_id = request.data.get('course_id')
        group_id = request.data.get('group_id')
        
        try:
            course = Course.objects.get(pk=course_id)
            group = Group.objects.get(pk=group_id)
            
            group.courses.add(course)
            
            return Response({
                'message': f'Course {course.code} assigned to {group.name}',
                'course': CourseSerializer(course).data
            })
        except Course.DoesNotExist:
            return Response({'error': 'Course not found'}, status=status.HTTP_404_NOT_FOUND)
        except Group.DoesNotExist:
            return Response({'error': 'Group not found'}, status=status.HTTP_404_NOT_FOUND)


# Group Management Views

class GroupListCreateView(generics.ListCreateAPIView):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    
    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


class GroupDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    
    def get_permissions(self):
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


# Course Assignment Views

class CourseAssignmentListCreateView(generics.ListCreateAPIView):
    queryset = CourseAssignment.objects.all()
    serializer_class = CourseAssignmentSerializer
    permission_classes = [IsAdmin]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['group', 'teacher', 'course']


class CourseAssignmentDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = CourseAssignment.objects.all()
    serializer_class = CourseAssignmentSerializer
    permission_classes = [IsAdmin]


# Grade Management Views

class GradeListCreateView(generics.ListCreateAPIView):
    serializer_class = GradeSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        queryset = Grade.objects.all()
        
        if course_id:
            queryset = queryset.filter(course_id=course_id)
        
        if self.request.user.role == User.TEACHER:
            queryset = queryset.filter(course__teacher=self.request.user)
        
        return queryset


class GradeUpdateView(generics.UpdateAPIView):
    queryset = Grade.objects.all()
    serializer_class = GradeUpdateSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        return Grade.objects.filter(course__teacher=self.request.user)


class StudentGradesView(generics.ListAPIView):
    serializer_class = GradeSerializer
    permission_classes = [IsStudent]
    
    def get_queryset(self):
        return Grade.objects.filter(student=self.request.user)


class CourseStudentsGradesView(generics.ListAPIView):
    serializer_class = GradeSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        assignment_id = self.kwargs['course_id']
        
        assignment = get_object_or_404(CourseAssignment, pk=assignment_id, teacher=self.request.user)
        course = assignment.course
        group = assignment.group
        
        students = User.objects.filter(
            role=User.STUDENT,
            group=group
        )
        
        for student in students:
            Grade.objects.get_or_create(
                student=student,
                course=course
            )
        
        return Grade.objects.filter(course=course, student__group=group)


# Attendance Views

class AttendanceListCreateView(generics.ListCreateAPIView):
    serializer_class = AttendanceSerializer
    permission_classes = [IsTeacher]
    
    def get_queryset(self):
        queryset = Attendance.objects.filter(
            course__assignments__teacher=self.request.user
        ).distinct()
        
        course_id = self.request.query_params.get('course_id')
        week = self.request.query_params.get('week')
        
        if course_id:
            queryset = queryset.filter(course_id=course_id)
        if week:
            queryset = queryset.filter(week_number=week)
            
        return queryset


class BulkAttendanceView(APIView):
    permission_classes = [IsTeacher]
    
    def post(self, request):
        records = request.data.get('attendance', [])
        results = []
        for data in records:
            student_id = data.get('student')
            course_id = data.get('course')
            week_number = data.get('week_number')
            
            if not CourseAssignment.objects.filter(course_id=course_id, teacher=request.user).exists():
                continue
                
            attendance, created = Attendance.objects.update_or_create(
                student_id=student_id,
                course_id=course_id,
                week_number=week_number,
                defaults={
                    'status': data.get('status'),
                    'notes': data.get('notes', '')
                }
            )
            results.append(AttendanceSerializer(attendance).data)
            
        return Response(results, status=status.HTTP_200_OK)


class StudentAttendanceView(generics.ListAPIView):
    serializer_class = AttendanceSerializer
    permission_classes = [IsStudent]
    
    def get_queryset(self):
        return Attendance.objects.filter(student=self.request.user)


# File Management Views

class CourseFileListCreateView(generics.ListCreateAPIView):
    serializer_class = CourseFileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        queryset = CourseFile.objects.all()
        
        course_id = self.request.query_params.get('course_id')
        if course_id:
            queryset = queryset.filter(course_id=course_id)
        
        if self.request.user.role == User.STUDENT:
            if self.request.user.group:
                queryset = queryset.filter(course__groups=self.request.user.group)
            else:
                queryset = CourseFile.objects.none()
        
        elif self.request.user.role == User.TEACHER:
            queryset = queryset.filter(course__teacher=self.request.user)
        
        return queryset
    
    def perform_create(self, serializer):
        serializer.save(uploaded_by=self.request.user)


class CourseFileDetailView(generics.RetrieveDestroyAPIView):
    queryset = CourseFile.objects.all()
    serializer_class = CourseFileSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_permissions(self):
        if self.request.method == 'DELETE':
            return [permissions.IsAuthenticated()]
        return [permissions.IsAuthenticated()]
    
    def perform_destroy(self, instance):
        if instance.uploaded_by == self.request.user or self.request.user.role == User.ADMIN:
            instance.delete()
        else:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You don't have permission to delete this file")


# Timetable Views

class TimetableListCreateView(generics.ListCreateAPIView):
    serializer_class = TimetableSerializer
    
    def get_permissions(self):
        if self.request.method == 'POST':
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]
    
    def get_queryset(self):
        queryset = Timetable.objects.filter(is_active=True)
        
        if self.request.user.role == User.STUDENT:
            if self.request.user.group:
                queryset = queryset.filter(group=self.request.user.group)
            else:
                queryset = Timetable.objects.none()
        
        return queryset


class TimetableDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Get, Update, or Delete a timetable
    """
    
    queryset = Timetable.objects.all()
    serializer_class = TimetableSerializer
    
    def get_permissions(self):
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]


class StudentTimetableView(APIView):
    """
    Get current student's active timetable
    
    Returns the active timetable for student's group.
    """
    
    permission_classes = [IsStudent]
    
    def get(self, request):
        student = request.user
        
        if not student.group:
            return Response(
                {'message': 'You are not assigned to any group yet'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        timetable = Timetable.objects.filter(
            group=student.group,
            is_active=True
        ).first()
        
        if not timetable:
            return Response(
                {'message': 'No timetable available for your group'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        return Response(TimetableSerializer(timetable).data)


# Interaction Views (Messages & Notifications)

class NotificationListView(generics.ListAPIView):
    """
    List notifications for current user
    """
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)


class NotificationMarkReadView(APIView):
    """
    Mark a notification as read
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        notification = get_object_or_404(Notification, pk=pk, user=request.user)
        notification.is_read = True
        notification.save()
        return Response({'status': 'notification marked as read'})


class MessageListCreateView(generics.ListCreateAPIView):
    """
    List messages with a specific user or send a new message
    """
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        other_user_id = self.request.query_params.get('with_user')
        if not other_user_id:
            # Return all conversations summary (simplified for now)
            return Message.objects.filter(
                Q(sender=self.request.user) | Q(receiver=self.request.user)
            )
        
        return Message.objects.filter(
            (Q(sender=self.request.user) & Q(receiver_id=other_user_id)) |
            (Q(sender_id=other_user_id) & Q(receiver=self.request.user))
        )

    def perform_create(self, serializer):
        message = serializer.save(sender=self.request.user)
        
        # Create a notification for the receiver
        sender = self.request.user
        sender_display_name = sender.get_full_name().strip() or sender.username
        
        Notification.objects.create(
            user=message.receiver,
            title=f"New Message from {sender_display_name}",
            message=message.content[:100] + ("..." if len(message.content) > 100 else ""),
            notification_type='MESSAGE'
        )


class ScheduleSessionViewSet(viewsets.ModelViewSet):
    """
    CRUD for class schedule sessions.
    """
    queryset = ScheduleSession.objects.all()
    serializer_class = ScheduleSessionSerializer
    permission_classes = [IsAdmin]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['assignment__group', 'day']
