.PHONY: help build dev test deploy clean

help:
	@echo "Available commands:"
	@echo "  make dev          - Start development environment"
	@echo "  make build        - Build Docker images"
	@echo "  make test         - Run tests"
	@echo "  make deploy-dev   - Deploy to development"
	@echo "  make deploy-prod  - Deploy to production"
	@echo "  make clean        - Clean up containers and volumes"

dev:
	docker-compose -f docker-compose.dev.yml up

build:
	docker-compose build

test:
	docker-compose -f docker-compose.test.yml run --rm web pytest
	docker-compose -f docker-compose.test.yml down -v

deploy-dev:
	kubectl apply -k k8s/overlays/development

deploy-staging:
	kubectl apply -k k8s/overlays/staging

deploy-prod:
	kubectl apply -k k8s/overlays/production

clean:
	docker-compose down -v
	docker system prune -f

migrate:
	docker-compose exec web python manage.py migrate

collectstatic:
	docker-compose exec web python manage.py collectstatic --noinput

shell:
	docker-compose exec web python manage.py shell

logs:
	docker-compose logs -f web

backup-db:
	./scripts/backup-db.sh

restore-db:
	./scripts/restore-db.sh