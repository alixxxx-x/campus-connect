from rest_framework import permissions
from .models import User


class IsAdmin(permissions.BasePermission):
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == User.ADMIN
        )


class IsTeacher(permissions.BasePermission):
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == User.TEACHER
        )


class IsStudent(permissions.BasePermission):
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == User.STUDENT
        )


class IsApprovedStudent(permissions.BasePermission):
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == User.STUDENT and
            request.user.is_approved
        )


class IsOwnerOrAdmin(permissions.BasePermission):
    
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return (
            obj == request.user or 
            request.user.role == User.ADMIN
        )


class IsTeacherOfCourse(permissions.BasePermission):
    
    def has_object_permission(self, request, view, obj):
        if request.user.role == User.ADMIN:
            return True
        
        if hasattr(obj, 'course'):
            return obj.course.teacher == request.user
        elif hasattr(obj, 'teacher'):
            return obj.teacher == request.user
        
        return False