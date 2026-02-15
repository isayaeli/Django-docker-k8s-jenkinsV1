# Django Application - Production Deployment

A production-ready Django application with Docker, Kubernetes, and Jenkins CI/CD pipeline.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## ✨ Features

- **Django 4.2+** with REST Framework
- **PostgreSQL** database
- **Redis** for caching and Celery broker
- **Celery** for async task processing
- **Docker** containerization
- **Kubernetes** orchestration
- **Jenkins** CI/CD pipeline
- **Nginx** reverse proxy
- **Horizontal Pod Autoscaling**
- **Comprehensive testing** with pytest
- **Code quality** tools (black, flake8, isort)
- **Pre-commit hooks**
- **Logging and monitoring**

## 🔧 Prerequisites

- Docker Desktop or Docker Engine (20.10+)
- Docker Compose (2.0+)
- Python 3.11+
- kubectl (for Kubernetes deployment)
- Make (optional, for using Makefile commands)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd django-project
```

### 2. Set Up Environment

```bash
# Copy environment template
cp .env.example .env.dev

# Edit .env.dev with your settings
nano .env.dev
```

### 3. Start Development Environment

```bash
# Using Make
make dev

# OR using docker-compose directly
docker-compose -f docker-compose.dev.yml up
```

### 4. Access the Application

- Django: http://localhost:8000
- Django Admin: http://localhost:8000/admin
- Flower (Celery Monitor): http://localhost:5555
- PostgreSQL: localhost:5432
- Redis: localhost:6379

### 5. Create Superuser

```bash
make createsuperuser

# OR
docker-compose -f docker-compose.dev.yml exec web python manage.py createsuperuser
```

## 📁 Project Structure

```
django-project/
├── app/                    # Django application
│   ├── myproject/         # Project settings
│   ├── apps/              # Django apps
│   ├── static/            # Static files
│   ├── templates/         # Templates
│   └── requirements/      # Python dependencies
├── docker/                # Docker configurations
├── k8s/                   # Kubernetes manifests
├── jenkins/               # Jenkins pipelines
├── scripts/               # Utility scripts
├── tests/                 # Test files
├── docs/                  # Documentation
└── Makefile              # Common commands
```

## 💻 Development

### Starting Development Server

```bash
# Start all services
make dev

# View logs
make dev-logs

# Stop services
make dev-down
```

### Database Operations

```bash
# Run migrations
make migrate

# Create migrations
make makemigrations

# Open Django shell
make shell

# Open database shell
make dbshell
```

### Celery Tasks

```bash
# View Celery worker logs
docker-compose logs -f celery

# Monitor tasks in Flower
# Open http://localhost:5555
```

### Code Quality

```bash
# Run linters
make lint

# Format code
make format

# Run all checks
make lint && make format
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
make test

# Run tests with coverage
make test-cov

# Run specific test file
docker-compose -f docker-compose.test.yml run --rm web pytest tests/test_models.py

# Run with markers
docker-compose -f docker-compose.test.yml run --rm web pytest -m unit
```

### Test Coverage

Coverage reports are generated in `htmlcov/` directory.

```bash
# Open coverage report
open htmlcov/index.html
```

## 🚢 Deployment

### Docker Deployment

```bash
# Build production images
make build

# Start production containers
make up

# View logs
make logs

# Stop containers
make down
```

### Kubernetes Deployment

```bash
# Deploy to development
make k8s-deploy-dev

# Deploy to staging
make k8s-deploy-staging

# Deploy to production
make k8s-deploy-prod

# Check status
make k8s-status

# View logs
make k8s-logs
```

### Using Scripts

```bash
# Deploy with custom scripts
./k8s-scripts/deploy.sh production v1.0.0

# Run migrations
./k8s-scripts/migrate.sh production v1.0.0

# Scale deployment
./k8s-scripts/scale.sh production 5

# Rollback
./k8s-scripts/rollback.sh production
```

## ⚙️ Configuration

### Environment Variables

Key environment variables (see `.env.example` for full list):

```bash
# Django
DJANGO_SETTINGS_MODULE=myproject.settings.production
SECRET_KEY=your-secret-key
DEBUG=False
ALLOWED_HOSTS=example.com,www.example.com

# Database
POSTGRES_DB=django_prod
POSTGRES_USER=django
POSTGRES_PASSWORD=secure-password
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Redis & Celery
REDIS_URL=redis://redis:6379/0
CELERY_BROKER_URL=redis://redis:6379/0

# Email
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_HOST_USER=apikey
EMAIL_HOST_PASSWORD=your-api-key
```

### Settings Files

- `base.py` - Shared settings
- `development.py` - Development settings
- `production.py` - Production settings
- `test.py` - Test settings

## 📊 Monitoring

### Application Monitoring

- **Flower**: Monitor Celery tasks at http://localhost:5555
- **Django Admin**: View application data at /admin
- **Logs**: Use `make logs` or `make k8s-logs`

### Kubernetes Monitoring

```bash
# Check pod status
kubectl get pods -n django-app

# View resource usage
kubectl top pods -n django-app

# Check HPA status
kubectl get hpa -n django-app

# View events
kubectl get events -n django-app --sort-by='.lastTimestamp'
```

### Database Backup

```bash
# Create backup
make backup-db

# Restore from backup
make restore-db
```

## 🐛 Troubleshooting

### Common Issues

**Issue: Cannot connect to PostgreSQL**
```bash
# Check if postgres is running
docker-compose ps postgres

# View postgres logs
docker-compose logs postgres

# Test connection
docker-compose exec web python manage.py dbshell
```

**Issue: Celery tasks not executing**
```bash
# Check celery worker status
docker-compose logs celery

# Inspect registered tasks
docker-compose exec celery celery -A myproject inspect registered

# Check Redis connection
docker-compose exec redis redis-cli ping
```

**Issue: Static files not loading**
```bash
# Collect static files
make collectstatic

# Check nginx configuration
docker-compose logs nginx
```

### Debugging

```bash
# Access Django shell
make shell

# Access container shell
docker-compose exec web bash

# View all logs
docker-compose logs -f

# Check container status
docker-compose ps
```

### Getting Help

1. Check [Documentation](docs/)
2. View logs: `make logs` or `make dev-logs`
3. Run health checks
4. Check [Troubleshooting Guide](docs/troubleshooting.md)

## 📚 Additional Documentation

- [Architecture](docs/architecture.md) - System architecture and design
- [API Documentation](docs/api.md) - API endpoints and usage
- [Deployment Guide](docs/deployment.md) - Detailed deployment instructions
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests: `make test`
4. Run linters: `make lint`
5. Format code: `make format`
6. Commit your changes
7. Push and create a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- Isaya Bendera - Initial work

## 🙏 Acknowledgments

- safarichap.com
- info@safarichap.com
