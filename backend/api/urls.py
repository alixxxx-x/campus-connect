from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenObtainPairView

from . import views

urlpatterns = [

    
    path('auth/register/', views.RegisterView.as_view(), name='register'),
    
    path('auth/login/', views.LoginView.as_view(), name='login'),
    
    path('auth/logout/', views.LogoutView.as_view(), name='logout'),
    
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    path('auth/profile/', views.UserProfileView.as_view(), name='profile'),

    path('users/search/', views.UserSearchView.as_view(), name='user-search'),
    
    

    
    path('admin/pending-students/', views.PendingStudentsView.as_view(), name='pending-students'),
    
    path('admin/approve-student/<int:pk>/', views.ApproveStudentView.as_view(), name='approve-student'),
    
    path('admin/reject-student/<int:pk>/', views.RejectStudentView.as_view(), name='reject-student'),
    
    path('admin/students/', views.StudentListView.as_view(), name='student-list'),
    
    path('admin/students/<int:pk>/', views.DeleteStudentView.as_view(), name='delete-student'),
    
    path('admin/assign-group/', views.AssignStudentToGroupView.as_view(), name='assign-group'),
    
    path('admin/teachers/', views.TeacherListView.as_view(), name='teacher-list'),
    
    path('admin/teachers/create/', views.CreateTeacherView.as_view(), name='create-teacher'),
    
    path('admin/teachers/<int:pk>/', views.DeleteTeacherView.as_view(), name='delete-teacher'),
    
    

    
    path('courses/', views.CourseListCreateView.as_view(), name='course-list'),
    
    path('courses/<int:pk>/', views.CourseDetailView.as_view(), name='course-detail'),
    
    path('courses/my-courses/', views.TeacherCoursesView.as_view(), name='teacher-courses'),
    
    path('courses/student-courses/', views.StudentCoursesView.as_view(), name='student-courses'),
    
    path('courses/assign-to-group/', views.AssignCourseToGroupView.as_view(), name='assign-course'),
    
    

    
    path('groups/', views.GroupListCreateView.as_view(), name='group-list'),
    
    path('groups/<int:pk>/', views.GroupDetailView.as_view(), name='group-detail'),
    
    

    path('admin/assignments/', views.CourseAssignmentListCreateView.as_view(), name='assignment-list'),
    path('admin/assignments/<int:pk>/', views.CourseAssignmentDetailView.as_view(), name='assignment-detail'),


    
    path('grades/', views.GradeListCreateView.as_view(), name='grade-list'),
    
    path('grades/<int:pk>/', views.GradeUpdateView.as_view(), name='grade-update'),
    
    path('grades/my-grades/', views.StudentGradesView.as_view(), name='my-grades'),
    
    path('grades/course/<int:course_id>/students/', views.CourseStudentsGradesView.as_view(), name='course-grades'),
    
    

    
    path('attendance/', views.AttendanceListCreateView.as_view(), name='attendance-list'),
    
    path('attendance/bulk/', views.BulkAttendanceView.as_view(), name='attendance-bulk'),
    
    path('attendance/my-attendance/', views.StudentAttendanceView.as_view(), name='my-attendance'),
    
    

    
    path('files/', views.CourseFileListCreateView.as_view(), name='file-list'),
    
    path('files/<int:pk>/', views.CourseFileDetailView.as_view(), name='file-detail'),
    
    

    
    path('timetables/', views.TimetableListCreateView.as_view(), name='timetable-list'),
    
    path('timetables/<int:pk>/', views.TimetableDetailView.as_view(), name='timetable-detail'),
    
    path('timetables/my-timetable/', views.StudentTimetableView.as_view(), name='my-timetable'),


    path('notifications/', views.NotificationListView.as_view(), name='notifications'),
    path('notifications/<int:pk>/read/', views.NotificationMarkReadView.as_view(), name='notification-mark-read'),
    path('messages/', views.MessageListCreateView.as_view(), name='messages'),
    

    path('schedule/', views.ScheduleSessionViewSet.as_view({'get': 'list', 'post': 'create'}), name='schedule-list'),
    path('schedule/<int:pk>/', views.ScheduleSessionViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'}), name='schedule-detail'),
]
