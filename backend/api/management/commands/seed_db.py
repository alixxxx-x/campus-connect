from django.core.management.base import BaseCommand
from django.utils import timezone
from api.models import User, Course, Group, CourseAssignment, Grade, Attendance, Timetable, Notification
import random
from datetime import timedelta, date

class Command(BaseCommand):
    help = 'Seeds the database with initial data'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding database...')

        # 1. Create Admins
        self.stdout.write('Creating Admins...')
        admin, created = User.objects.get_or_create(
            username='admin',
            defaults={
                'email': 'admin@campus.com',
                'role': User.ADMIN,
                'is_staff': True,
                'is_superuser': True,
                'is_approved': True
            }
        )
        if created:
            admin.set_password('admin123')
            admin.save()

        # 2. Create Courses
        self.stdout.write('Creating Courses...')
        courses_data = [
            {'code': 'CS101', 'name': 'Intro to Programming', 'credits': 4},
            {'code': 'CS102', 'name': 'Data Structures', 'credits': 4},
            {'code': 'MATH101', 'name': 'Calculus I', 'credits': 3},
            {'code': 'PHY101', 'name': 'Physics I', 'credits': 3},
            {'code': 'ENG101', 'name': 'English Communication', 'credits': 2},
            {'code': 'DB201', 'name': 'Database Systems', 'credits': 3},
            {'code': 'WEB201', 'name': 'Web Development', 'credits': 3},
        ]
        
        courses = []
        for c in courses_data:
            course, _ = Course.objects.get_or_create(code=c['code'], defaults=c)
            courses.append(course)

        # 3. Create Groups
        self.stdout.write('Creating Groups...')
        groups_data = ['Group A', 'Group B', 'Group C']
        groups = []
        for g_name in groups_data:
            group, _ = Group.objects.get_or_create(
                name=g_name, 
                defaults={'academic_year': '2025-2026'}
            )
            # Assign random courses to groups
            group.courses.set(random.sample(courses, 4))
            groups.append(group)

        # 4. Create Teachers
        self.stdout.write('Creating Teachers...')
        teachers = []
        for i in range(1, 6):
            t, created = User.objects.get_or_create(
                username=f'teacher{i}',
                defaults={
                    'email': f'teacher{i}@campus.com',
                    'role': User.TEACHER,
                    'is_approved': True,
                    'first_name': f'Teacher',
                    'last_name': f'{i}'
                }
            )
            if created:
                t.set_password('teacher123')
                t.save()
            teachers.append(t)

        # 5. Assign Teachers to Courses/Groups
        self.stdout.write('Assigning Teachers...')
        for group in groups:
            for course in group.courses.all():
                CourseAssignment.objects.get_or_create(
                    group=group,
                    course=course,
                    academic_year='2025-2026',
                    defaults={'teacher': random.choice(teachers)}
                )

        # 6. Create Students
        self.stdout.write('Creating Students...')
        students = []
        for i in range(1, 21): # 20 students
            group = random.choice(groups)
            s, created = User.objects.get_or_create(
                username=f'student{i}',
                defaults={
                    'email': f'student{i}@campus.com',
                    'role': User.STUDENT,
                    'student_id': f'202500{i}',
                    'is_approved': True,
                    'group': group,
                    'first_name': f'Student',
                    'last_name': f'{i}',
                    'program': 'Computer Science',
                    'semester': 1
                }
            )
            if created:
                s.set_password('student123')
                s.save()
            students.append(s)

        # 7. Create Grades & Attendance (Randomized)
        self.stdout.write('Generating Grades and Attendance...')
        for student in students:
            if not student.group: continue
            
            for course in student.group.courses.all():
                # Grades
                Grade.objects.get_or_create(
                    student=student,
                    course=course,
                    defaults={
                        'td_mark': random.uniform(10, 20),
                        'tp_mark': random.uniform(10, 20),
                        'exam_mark': random.uniform(8, 20),
                        'comments': 'Great progress!' if random.random() > 0.5 else 'Needs improvement.'
                    }
                )
                
                # Attendance (Last 5 weeks)
                for w in range(1, 6):
                    Attendance.objects.get_or_create(
                        student=student,
                        course=course,
                        week_number=w,
                        defaults={
                            'status': random.choices(
                                [Attendance.PRESENT, Attendance.ABSENT, Attendance.LATE],
                                weights=[80, 10, 10]
                            )[0]
                        }
                    )

        # 8. Notifications
        self.stdout.write('Creating Notifications...')
        for user in students + teachers:
             Notification.objects.create(
                 user=user,
                 title='Welcome to Campus Connect',
                 message='Welcome to the new academic year!',
                 notification_type='INFO'
             )

        self.stdout.write(self.style.SUCCESS('Database seeded successfully!'))
