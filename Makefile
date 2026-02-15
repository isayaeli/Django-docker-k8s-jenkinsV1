# Makefile
# Common commands for Django project management

.PHONY: help build dev test deploy clean migrate shell

# Default target
.DEFAULT_GOAL := help

# Variables
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_DEV = docker-compose -f docker-compose.dev.yml
DOCKER_COMPOSE_TEST = docker-compose -f docker-compose.test.yml
KUBECTL = kubectl
PYTHON = python
MANAGE = $(PYTHON) manage.py

# Colors for output
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

help: ## Show this help message
	@echo '$(BLUE)Available commands:$(NC)'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# Development
dev: ## Start development environment
	@echo '$(YELLOW)Starting development environment...$(NC)'
	$(DOCKER_COMPOSE_DEV) up

dev-build: ## Build and start development environment
	@echo '$(YELLOW)Building and starting development environment...$(NC)'
	$(DOCKER_COMPOSE_DEV) up --build

dev-down: ## Stop development environment
	@echo '$(YELLOW)Stopping development environment...$(NC)'
	$(DOCKER_COMPOSE_DEV) down

dev-logs: ## View development logs
	$(DOCKER_COMPOSE_DEV) logs -f

# Production
build: ## Build production Docker images
	@echo '$(YELLOW)Building production images...$(NC)'
	$(DOCKER_COMPOSE) build

up: ## Start production containers
	@echo '$(YELLOW)Starting production containers...$(NC)'
	$(DOCKER_COMPOSE) up -d

down: ## Stop production containers
	@echo '$(YELLOW)Stopping production containers...$(NC)'
	$(DOCKER_COMPOSE) down

logs: ## View production logs
	$(DOCKER_COMPOSE) logs -f

# Testing
test: ## Run tests
	@echo '$(YELLOW)Running tests...$(NC)'
	$(DOCKER_COMPOSE_TEST) run --rm web pytest

test-cov: ## Run tests with coverage
	@echo '$(YELLOW)Running tests with coverage...$(NC)'
	$(DOCKER_COMPOSE_TEST) run --rm web pytest --cov=app --cov-report=html

test-fast: ## Run tests without rebuilding
	$(DOCKER_COMPOSE_TEST) run --rm --no-deps web pytest

lint: ## Run linters
	@echo '$(YELLOW)Running linters...$(NC)'
	$(DOCKER_COMPOSE_DEV) run --rm web flake8
	$(DOCKER_COMPOSE_DEV) run --rm web black --check .
	$(DOCKER_COMPOSE_DEV) run --rm web isort --check-only .

format: ## Format code
	@echo '$(YELLOW)Formatting code...$(NC)'
	$(DOCKER_COMPOSE_DEV) run --rm web black .
	$(DOCKER_COMPOSE_DEV) run --rm web isort .

# Database
migrate: ## Run database migrations
	@echo '$(YELLOW)Running migrations...$(NC)'
	$(DOCKER_COMPOSE_DEV) exec web python manage.py migrate

makemigrations: ## Create new migrations
	@echo '$(YELLOW)Creating migrations...$(NC)'
	$(DOCKER_COMPOSE_DEV) exec web python manage.py makemigrations

migrate-prod: ## Run migrations in production
	$(DOCKER_COMPOSE) exec web python manage.py migrate

# Django commands
shell: ## Open Django shell
	$(DOCKER_COMPOSE_DEV) exec web python manage.py shell

dbshell: ## Open database shell
	$(DOCKER_COMPOSE_DEV) exec web python manage.py dbshell

createsuperuser: ## Create Django superuser
	$(DOCKER_COMPOSE_DEV) exec web python manage.py createsuperuser

collectstatic: ## Collect static files
	@echo '$(YELLOW)Collecting static files...$(NC)'
	$(DOCKER_COMPOSE_DEV) exec web python manage.py collectstatic --noinput

# Kubernetes
k8s-deploy-dev: ## Deploy to Kubernetes development
	@echo '$(YELLOW)Deploying to development...$(NC)'
	$(KUBECTL) apply -k k8s/overlays/development

k8s-deploy-staging: ## Deploy to Kubernetes staging
	@echo '$(YELLOW)Deploying to staging...$(NC)'
	$(KUBECTL) apply -k k8s/overlays/staging

k8s-deploy-prod: ## Deploy to Kubernetes production
	@echo '$(YELLOW)Deploying to production...$(NC)'
	$(KUBECTL) apply -k k8s/overlays/production

k8s-status: ## Check Kubernetes deployment status
	$(KUBECTL) get all -n django-app

k8s-logs: ## View Kubernetes logs
	$(KUBECTL) logs -f -l app=django -n django-app

k8s-shell: ## Open shell in Kubernetes pod
	$(KUBECTL) exec -it -n django-app $$($(KUBECTL) get pod -n django-app -l app=django -o jsonpath='{.items[0].metadata.name}') -- /bin/bash

# Celery
celery-worker: ## Start Celery worker
	$(DOCKER_COMPOSE_DEV) exec web celery -A myproject worker --loglevel=info

celery-beat: ## Start Celery beat
	$(DOCKER_COMPOSE_DEV) exec web celery -A myproject beat --loglevel=info

celery-flower: ## Start Flower monitoring
	$(DOCKER_COMPOSE_DEV) exec web celery -A myproject flower

# Cleanup
clean: ## Clean up containers and volumes
	@echo '$(YELLOW)Cleaning up...$(NC)'
	$(DOCKER_COMPOSE_DEV) down -v
	$(DOCKER_COMPOSE_TEST) down -v
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name ".coverage" -delete
	find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true

clean-db: ## Remove database volume (DESTRUCTIVE!)
	@echo '$(YELLOW)WARNING: This will delete all database data!$(NC)'
	@read -p "Are you sure? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		$(DOCKER_COMPOSE_DEV) down -v; \
		echo '$(GREEN)Database volumes removed$(NC)'; \
	else \
		echo '$(RED)Cancelled$(NC)'; \
	fi

# Backup and restore
backup-db: ## Backup database
	@echo '$(YELLOW)Creating database backup...$(NC)'
	./scripts/backup-db.sh

restore-db: ## Restore database from backup
	@echo '$(YELLOW)Restoring database...$(NC)'
	./scripts/restore-db.sh

# Documentation
docs: ## Build documentation
	@echo '$(YELLOW)Building documentation...$(NC)'
	cd docs && make html

docs-serve: ## Serve documentation locally
	@echo '$(YELLOW)Serving documentation at http://localhost:8001$(NC)'
	cd docs/_build/html && python -m http.server 8001

# Setup
install: ## Install dependencies
	@echo '$(YELLOW)Installing dependencies...$(NC)'
	pip install -r app/requirements/development.txt

setup: ## Initial project setup
	@echo '$(YELLOW)Setting up project...$(NC)'
	cp .env.example .env
	@echo '$(GREEN)Created .env file - please update with your values$(NC)'
	$(MAKE) dev-build
	$(MAKE) migrate
	@echo '$(GREEN)Setup complete!$(NC)'

# CI/CD
ci-test: ## Run CI tests
	$(DOCKER_COMPOSE_TEST) run --rm web pytest --junitxml=test-results.xml

ci-lint: ## Run CI linters
	$(DOCKER_COMPOSE_TEST) run --rm web flake8 --format=junit-xml --output-file=lint-results.xml

ci-security: ## Run security checks
	$(DOCKER_COMPOSE_TEST) run --rm web bandit -r app -f json -o security-results.json

# Version
version: ## Show version information
	@echo '$(BLUE)Django Version:$(NC)'
	@$(DOCKER_COMPOSE_DEV) exec web python -c "import django; print(django.get_version())"
	@echo '$(BLUE)Docker Compose Version:$(NC)'
	@$(DOCKER_COMPOSE) version
	@echo '$(BLUE)Kubectl Version:$(NC)'
	@$(KUBECTL) version --client
