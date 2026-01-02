"""
Campus Connect - Custom Permission Classes
These control who can access which API endpoints.

How it works with Flutter:
1. Flutter sends JWT token in Authorization header: "Bearer <token>"
2. Django validates token and identifies the user
3. Permission class checks user's role
4. If allowed → proceed, else → 403 Forbidden response
"""

from rest_framework import permissions
from .models import User


class IsAdmin(permissions.BasePermission):
    """
    Only users with ADMIN role can access.
    
    Used in: Admin management endpoints
    - Managing students (approve/delete)
    - Managing teachers
    - Creating courses and groups
    - Uploading timetables
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == User.ADMIN
        )


class IsTeacher(permissions.BasePermission):
    """
    Only users with TEACHER role can access.
    
    Used in: Teacher-specific endpoints
    - Viewing assigned courses
    - Entering/updating marks
    - Marking attendance
    - Uploading course files
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == User.TEACHER
        )


class IsStudent(permissions.BasePermission):
    """
    Only users with STUDENT role can access.
    
    Used in: Student-specific endpoints
    - Viewing marks
    - Viewing timetable
    - Viewing course files
    - Viewing profile
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == User.STUDENT
        )


class IsApprovedStudent(permissions.BasePermission):
    """
    Only approved students can access.
    
    Used when you want to ensure student is not pending.
    Most student endpoints already check this during login,
    but this adds extra security layer.
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == User.STUDENT and
            request.user.is_approved
        )


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Object-level permission: only owner or admin can modify.
    
    Example: Student can update their own profile but not others.
    Admin can update anyone's profile.
    """
    
    def has_object_permission(self, request, view, obj):
        # Read permissions for authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions only for owner or admin
        return (
            obj == request.user or 
            request.user.role == User.ADMIN
        )


class IsTeacherOfCourse(permissions.BasePermission):
    """
    Only the teacher assigned to a course can access course data.
    
    Used in: Grade management, course file uploads
    Ensures teachers can only modify their own courses.
    """
    
    def has_object_permission(self, request, view, obj):
        # Admin can access everything
        if request.user.role == User.ADMIN:
            return True
        
        # Check if user is the teacher of this course
        if hasattr(obj, 'course'):
            return obj.course.teacher == request.user
        elif hasattr(obj, 'teacher'):
            return obj.teacher == request.user
        
        return False