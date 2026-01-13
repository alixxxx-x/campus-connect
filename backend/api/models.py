from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator

class User(AbstractUser):
class User(AbstractUser):
    

    ADMIN = 'ADMIN'
    TEACHER = 'TEACHER'
    STUDENT = 'STUDENT'
    
    ROLE_CHOICES = [
        (ADMIN, 'Admin'),
        (TEACHER, 'Teacher'),
        (STUDENT, 'Student'),
    ]
    
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default=STUDENT)
    
    student_id = models.CharField(max_length=20, unique=True, null=True, blank=True)
    program = models.CharField(max_length=100, null=True, blank=True)
    semester = models.IntegerField(default=1, validators=[MinValueValidator(1), MaxValueValidator(10)])
    birth_date = models.DateField(null=True, blank=True)
    phone = models.CharField(max_length=15, blank=True)
    address = models.TextField(blank=True)
    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)
    
    is_approved = models.BooleanField(default=False)
    rejection_reason = models.TextField(null=True, blank=True)
    
    group = models.ForeignKey('Group', on_delete=models.SET_NULL, null=True, blank=True, related_name='students')
    
    class Meta:
        ordering = ['username']
    
    def __str__(self):
        return f"{self.username} ({self.role})"



class Course(models.Model):
    code = models.CharField(max_length=10, unique=True)
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    credits = models.IntegerField(default=3)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['code']
    
    def __str__(self):
        return f"{self.code} - {self.name}"



class Group(models.Model):
    name = models.CharField(max_length=50, unique=True)
    academic_year = models.CharField(max_length=10)
    
    courses = models.ManyToManyField(Course, related_name='groups', blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['name']
    
    def __str__(self):
        return self.name


class CourseAssignment(models.Model):
    teacher = models.ForeignKey(User, on_delete=models.CASCADE, limit_choices_to={'role': User.TEACHER}, related_name='teaching_assignments')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='assignments')
    group = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='course_assignments')
    academic_year = models.CharField(max_length=10)

    class Meta:
        unique_together = ['course', 'group', 'academic_year']

    def __str__(self):
        return f"{self.teacher.username} - {self.course.code} ({self.group.name})"



class Grade(models.Model):
    student = models.ForeignKey(
        User, 
        on_delete=models.CASCADE,
        limit_choices_to={'role': User.STUDENT},
        related_name='grades'
    )
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='grades')
    
    td_mark = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        null=True, 
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(20)]
    )
    tp_mark = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        null=True, 
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(20)]
    )
    exam_mark = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        null=True, 
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(20)]
    )
    
    comments = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['student', 'course']
        ordering = ['-updated_at']
    
    def __str__(self):
        return f"{self.student.username} - {self.course.code}"
    
    @property
    def average(self):
        marks = [m for m in [self.td_mark, self.tp_mark, self.exam_mark] if m is not None]
        return sum(marks) / len(marks) if marks else None



class Attendance(models.Model):
    student = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        limit_choices_to={'role': User.STUDENT},
        related_name='attendances'
    )
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='attendances')
    
    date = models.DateField(auto_now_add=True)
    week_number = models.IntegerField()
    PRESENT = 'PRESENT'
    ABSENT = 'ABSENT'
    LATE = 'LATE'
    EXCUSED = 'EXCUSED'
    
    STATUS_CHOICES = [
        (PRESENT, 'Present'),
        (ABSENT, 'Absent'),
        (LATE, 'Late'),
        (EXCUSED, 'Excused'),
    ]
    
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default=PRESENT)
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['student', 'course', 'week_number']
        ordering = ['week_number']
    
    def __str__(self):
        return f"{self.student.username} - {self.course.code} - {self.date}"



class CourseFile(models.Model):
class CourseFile(models.Model):
    
    FILE_TYPES = [
        ('LECTURE', 'Lecture Notes'),
        ('LAB', 'Lab Material'),
        ('ASSIGNMENT', 'Assignment'),
        ('SOLUTION', 'Solution'),
        ('OTHER', 'Other'),
    ]
    
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='files')
    uploaded_by = models.ForeignKey(User, on_delete=models.CASCADE)
    
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    file = models.FileField(upload_to='course_files/')
    file_type = models.CharField(max_length=20, choices=FILE_TYPES, default='OTHER')
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.course.code} - {self.title}"



class Timetable(models.Model):
    group = models.ForeignKey(Group, on_delete=models.CASCADE, related_name='timetables')
    
    title = models.CharField(max_length=200)
    image = models.ImageField(upload_to='timetables/')
    
    semester = models.CharField(max_length=50, blank=True)
    academic_year = models.CharField(max_length=10)
    
    is_active = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.group.name} - {self.title}"



class Message(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages')
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        return f"From {self.sender.username} to {self.receiver.username}"



class Notification(models.Model):
    NOTIFICATION_TYPES = [
        ('MESSAGE', 'New Message Received'),
        ('EXAM', 'Exam Notification'),
        ('GRADE', 'New Grade Published'),
        ('INFO', 'General Information'),
        ('REG', 'Registration Update'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=200)
    message = models.TextField()
    notification_type = models.CharField(max_length=10, choices=NOTIFICATION_TYPES, default='INFO')
    created_at = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.notification_type}: {self.title} for {self.user.username}"


class ScheduleSession(models.Model):
    assignment = models.ForeignKey(CourseAssignment, on_delete=models.CASCADE, related_name='sessions')
    
    DAY_CHOICES = [
        ('MONDAY', 'Monday'),
        ('TUESDAY', 'Tuesday'),
        ('WEDNESDAY', 'Wednesday'),
        ('THURSDAY', 'Thursday'),
        ('FRIDAY', 'Friday'),
        ('SATURDAY', 'Saturday'),
        ('SUNDAY', 'Sunday'),
    ]
    
    day = models.CharField(max_length=10, choices=DAY_CHOICES)
    start_time = models.TimeField()
    end_time = models.TimeField()
    room = models.CharField(max_length=50)
    
    SESSION_TYPES = [
        ('LECTURE', 'Lecture'),
        ('LAB', 'Lab'),
        ('TUTORIAL', 'Tutorial'),
    ]
    session_type = models.CharField(max_length=20, choices=SESSION_TYPES, default='LECTURE')
    
    class Meta:
        ordering = ['day', 'start_time']

    def __str__(self):
        return f"{self.assignment.course.code} - {self.day} {self.start_time}"
