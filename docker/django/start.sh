#!/bin/bash
set -e

cd /app

# Run migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Start Gunicorn
exec gunicorn config.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --threads 2 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile - \
    --log-level info