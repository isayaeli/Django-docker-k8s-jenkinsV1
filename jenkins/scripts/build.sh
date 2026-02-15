#!/bin/bash
# jenkins/scripts/build.sh
# Build Docker images for the application

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"your-registry.com"}
IMAGE_NAME=${IMAGE_NAME:-"safarichap"}
IMAGE_TAG=${1:-"latest"}

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Building Docker Images${NC}"
echo -e "${GREEN}Registry: ${DOCKER_REGISTRY}${NC}"
echo -e "${GREEN}Image: ${IMAGE_NAME}${NC}"
echo -e "${GREEN}Tag: ${IMAGE_TAG}${NC}"
echo -e "${GREEN}===========================================${NC}"

# Build Django image
echo -e "${YELLOW}Building safarichap image...${NC}"
docker build \
    -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
    -f docker/django/Dockerfile \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    --build-arg VCS_REF=$(git rev-parse --short HEAD) \
    --build-arg VERSION=${IMAGE_TAG} \
    .

# Build Nginx image
echo -e "${YELLOW}Building Nginx image...${NC}"
docker build \
    -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-nginx:${IMAGE_TAG} \
    -f docker/nginx/Dockerfile \
    --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
    .

# List images
echo -e "${YELLOW}Built images:${NC}"
docker images | grep ${IMAGE_NAME}

# Get image sizes
echo -e "${YELLOW}Image sizes:${NC}"
echo -e "Django: $(docker images ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} --format "{{.Size}}")"
echo -e "Nginx: $(docker images ${DOCKER_REGISTRY}/${IMAGE_NAME}-nginx:${IMAGE_TAG} --format "{{.Size}}")"

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}===========================================${NC}"
