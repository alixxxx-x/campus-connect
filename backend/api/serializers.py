

from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User, Course, Group, Grade, Attendance, CourseFile, Timetable, CourseAssignment, Message, Notification, ScheduleSession




class UserSerializer(serializers.ModelSerializer):
    
    # Include group details when serializing
    group_name = serializers.SerializerMethodField()
    group_id = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name',
            'role', 'student_id', 'program', 'semester', 'birth_date', 
            'phone', 'address', 'profile_picture', 'is_approved', 
            'rejection_reason', 'group', 'group_name', 'group_id'
        ]
        read_only_fields = ['id', 'role']

    def get_group_name(self, obj):
        return obj.group.name if obj.group else None

    def get_group_id(self, obj):
        return obj.group.id if obj.group else None


class UserSearchSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'full_name', 'role', 'profile_picture']

    def get_full_name(self, obj):
        name = obj.get_full_name().strip()
        return name if name else obj.username


class RegisterSerializer(serializers.ModelSerializer):
    
    password = serializers.CharField(write_only=True, min_length=8)
    password2 = serializers.CharField(write_only=True, label="Confirm Password")
    
    class Meta:
        model = User
        fields = [
            'username', 'email', 'password', 'password2',
            'first_name', 'last_name', 'student_id',
            'birth_date', 'phone', 'address', 'role'
        ]
    
    def validate(self, data):
        """Ensure passwords match"""
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Passwords don't match"})
        return data
    
    def create(self, validated_data):
        validated_data.pop('password2')
        validated_data.pop('role', None) 
        
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
            student_id=validated_data.get('student_id'),
            birth_date=validated_data.get('birth_date'),
            phone=validated_data.get('phone', ''),
            address=validated_data.get('address', ''),
            role=User.STUDENT, # Hardcoded for safety
            is_approved=False  # Must be approved by admin
        )
        return user


class LoginSerializer(serializers.Serializer):
    
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, data):
        username = data.get('username')
        password = data.get('password')
        
        # Authenticate credentials
        user = authenticate(username=username, password=password)
        
        if not user:
            raise serializers.ValidationError("Invalid credentials")
        
        # Check if student is approved
        if user.role == User.STUDENT and not user.is_approved:
            raise serializers.ValidationError("Account pending approval")
        
        data['user'] = user
        return data


class CourseSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Course
        fields = ['id', 'code', 'name', 'description', 'credits']


class CourseCreateSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Course
        fields = ['code', 'name', 'description', 'credits']


class ScheduleSessionSerializer(serializers.ModelSerializer):
    assignment_id = serializers.PrimaryKeyRelatedField(
        queryset=CourseAssignment.objects.all(), source='assignment', write_only=True
    )
    course_code = serializers.SerializerMethodField()
    course_name = serializers.SerializerMethodField()
    group_name = serializers.SerializerMethodField()
    teacher_name = serializers.SerializerMethodField()
    
    class Meta:
        model = ScheduleSession
        fields = [
            'id', 'assignment_id', 'course_code', 'course_name', 
            'group_name', 'teacher_name', 'day', 'start_time', 
            'end_time', 'room', 'session_type'
        ]

    def get_course_code(self, obj):
        return obj.assignment.course.code if obj.assignment and obj.assignment.course else None

    def get_course_name(self, obj):
        return obj.assignment.course.name if obj.assignment and obj.assignment.course else None

    def get_group_name(self, obj):
        return obj.assignment.group.name if obj.assignment and obj.assignment.group else None

    def get_teacher_name(self, obj):
        return obj.assignment.teacher.get_full_name() if obj.assignment and obj.assignment.teacher else None

class CourseAssignmentSerializer(serializers.ModelSerializer):
    teacher_name = serializers.CharField(source='teacher.get_full_name', read_only=True)
    course_name = serializers.CharField(source='course.name', read_only=True)
    course_code = serializers.CharField(source='course.code', read_only=True)
    group_name = serializers.CharField(source='group.name', read_only=True)
    group_id = serializers.PrimaryKeyRelatedField(source='group', read_only=True)
    sessions = ScheduleSessionSerializer(many=True, read_only=True)

    class Meta:
        model = CourseAssignment
        fields = [
            'id', 'teacher', 'teacher_name',
            'course', 'course_name', 'course_code',
            'group', 'group_id', 'group_name', 'academic_year', 'sessions'
        ]


# ============================================================================
# GROUP SERIALIZERS
# ============================================================================

class GroupSerializer(serializers.ModelSerializer):
    
    student_count = serializers.SerializerMethodField()
    courses = CourseSerializer(many=True, read_only=True)
    
    class Meta:
        model = Group
        fields = ['id', 'name', 'academic_year', 'student_count', 'courses']
    
    def get_student_count(self, obj):
        """Count students in this group"""
        return obj.students.count()


# ============================================================================
# GRADE SERIALIZERS
# ============================================================================

class GradeSerializer(serializers.ModelSerializer):
    
    course_code = serializers.CharField(source='course.code', read_only=True)
    course_name = serializers.CharField(source='course.name', read_only=True)
    student_name = serializers.CharField(source='student.get_full_name', read_only=True)
    student_id = serializers.CharField(source='student.student_id', read_only=True)
    average = serializers.DecimalField(max_digits=5, decimal_places=2, read_only=True)
    
    class Meta:
        model = Grade
        fields = [
            'id', 'student', 'student_name', 'student_id',
            'course', 'course_code', 'course_name',
            'td_mark', 'tp_mark', 'exam_mark', 'average',
            'comments', 'updated_at'
        ]
        read_only_fields = ['average']


class GradeUpdateSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Grade
        fields = ['td_mark', 'tp_mark', 'exam_mark', 'comments']


# ============================================================================
# ATTENDANCE SERIALIZERS
# ============================================================================

class AttendanceSerializer(serializers.ModelSerializer):
    
    student_name = serializers.CharField(source='student.get_full_name', read_only=True)
    student_id = serializers.CharField(source='student.student_id', read_only=True)
    course_code = serializers.CharField(source='course.code', read_only=True)
    
    class Meta:
        model = Attendance
        fields = [
            'id', 'student', 'student_name', 'student_id',
            'course', 'course_code', 'date', 'week_number',
            'status', 'notes'
        ]


# ============================================================================
# FILE SERIALIZERS
# ============================================================================

class CourseFileSerializer(serializers.ModelSerializer):
    
    uploaded_by_name = serializers.CharField(source='uploaded_by.get_full_name', read_only=True)
    course_code = serializers.CharField(source='course.code', read_only=True)
    
    class Meta:
        model = CourseFile
        fields = [
            'id', 'course', 'course_code', 'title', 'description',
            'file', 'file_type', 'uploaded_by', 'uploaded_by_name',
            'created_at'
        ]
        read_only_fields = ['uploaded_by']


# ============================================================================
# TIMETABLE SERIALIZERS
# ============================================================================

class TimetableSerializer(serializers.ModelSerializer):
    
    group_name = serializers.CharField(source='group.name', read_only=True)
    
    class Meta:
        model = Timetable
        fields = [
            'id', 'group', 'group_name', 'title', 'image',
            'semester', 'academic_year', 'is_active', 'created_at'
        ]


# ============================================================================
# NESTED SERIALIZERS FOR COMPLEX DATA
# ============================================================================

class StudentDetailSerializer(serializers.ModelSerializer):
    
    group_name = serializers.SerializerMethodField()
    grade_count = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 'role',
            'student_id', 'program', 'semester', 'birth_date', 'phone', 'address',
            'profile_picture', 'is_approved', 'rejection_reason', 'group', 'group_name',
            'grade_count'
        ]
    
    def get_group_name(self, obj):
        return obj.group.name if obj.group else None
    
    def get_grade_count(self, obj):
        """How many courses this student has grades for"""
        return obj.grades.count()


class TeacherDetailSerializer(serializers.ModelSerializer):
    
    courses = CourseAssignmentSerializer(source='teaching_assignments', many=True, read_only=True)
    course_count = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 'role',
            'phone', 'courses', 'course_count'
        ]
    
    def get_course_count(self, obj):
        """Number of courses this teacher is teaching"""
        return obj.teaching_assignments.count()


# ============================================================================
# INTERACTION SERIALIZERS (Messages & Notifications)
# ============================================================================

class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.SerializerMethodField()
    receiver_name = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'sender', 'sender_name', 'receiver', 'receiver_name', 'content', 'timestamp', 'is_read']
        read_only_fields = ['sender', 'timestamp']

    def get_sender_name(self, obj):
        name = obj.sender.get_full_name().strip()
        return name if name else obj.sender.username

    def get_receiver_name(self, obj):
        name = obj.receiver.get_full_name().strip()
        return name if name else obj.receiver.username


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'user', 'title', 'message', 'notification_type', 'created_at', 'is_read']
        read_only_fields = ['created_at']
