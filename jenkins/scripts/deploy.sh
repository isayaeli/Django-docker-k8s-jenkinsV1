#!/bin/bash
# jenkins/scripts/deploy.sh
# Deploy application to Kubernetes

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
ENVIRONMENT=${1:-development}
IMAGE_TAG=${2:-latest}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"your-registry.com"}
IMAGE_NAME=${IMAGE_NAME:-"safarichap"}

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Deploying to ${ENVIRONMENT}${NC}"
echo -e "${GREEN}Image Tag: ${IMAGE_TAG}${NC}"
echo -e "${GREEN}===========================================${NC}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo -e "${RED}Error: Invalid environment. Must be development, staging, or production${NC}"
    exit 1
fi

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: kubectl is not configured or cluster is not reachable${NC}"
    exit 1
fi

# Update kustomization with new image
echo -e "${YELLOW}Updating kustomization...${NC}"
cd k8s/overlays/${ENVIRONMENT}
kustomize edit set image ${DOCKER_REGISTRY}/${IMAGE_NAME}=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

# Apply configurations
echo -e "${YELLOW}Applying Kubernetes configurations...${NC}"
kubectl apply -k .

# Wait for rollout
echo -e "${YELLOW}Waiting for deployment to complete...${NC}"
NAMESPACE="django-${ENVIRONMENT}"
kubectl rollout status deployment/safarichap -n ${NAMESPACE} --timeout=10m
kubectl rollout status deployment/nginx -n ${NAMESPACE} --timeout=5m

# Check pod status
echo -e "${YELLOW}Checking pod status...${NC}"
kubectl get pods -n ${NAMESPACE}

# Check services
echo -e "${YELLOW}Checking services...${NC}"
kubectl get svc -n ${NAMESPACE}

# Check ingress
echo -e "${YELLOW}Checking ingress...${NC}"
kubectl get ingress -n ${NAMESPACE}

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}===========================================${NC}"

# Return to original directory
cd ../../..
