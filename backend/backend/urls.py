"""
Campus Connect - Main URL Configuration (config/urls.py)
This is the main URLs file that routes requests to your api app.

All API endpoints are prefixed with /api/
Example: http://localhost:8000/api/auth/login/
"""

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # Django admin panel (for debugging/management)
    # Access at: http://localhost:8000/admin/
    path('admin/', admin.site.urls),
    
    # All API endpoints are under /api/
    # This includes your api/urls.py
    path('api/', include('api.urls')),
]

# Serve media files in development
# Flutter can access uploaded files at: http://localhost:8000/media/...
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)