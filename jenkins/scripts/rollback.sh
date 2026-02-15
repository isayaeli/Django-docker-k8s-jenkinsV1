#!/bin/bash
# jenkins/scripts/rollback.sh
# Rollback deployment to previous version

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
ENVIRONMENT=${1:-development}
REVISION=${2:-0}  # 0 means previous revision

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Rolling back deployment${NC}"
echo -e "${GREEN}Environment: ${ENVIRONMENT}${NC}"
echo -e "${GREEN}===========================================${NC}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo -e "${RED}Error: Invalid environment${NC}"
    exit 1
fi

NAMESPACE="safarichap-${ENVIRONMENT}"

# Show rollout history
echo -e "${YELLOW}Deployment history:${NC}"
kubectl rollout history deployment/safarichap -n ${NAMESPACE}

# Confirm rollback for production
if [ "$ENVIRONMENT" = "production" ]; then
    echo -e "${RED}WARNING: Rolling back PRODUCTION deployment!${NC}"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "${RED}Rollback cancelled${NC}"
        exit 0
    fi
fi

# Perform rollback
echo -e "${YELLOW}Performing rollback...${NC}"
if [ "$REVISION" -eq 0 ]; then
    kubectl rollout undo deployment/safarichap -n ${NAMESPACE}
else
    kubectl rollout undo deployment/safarichap -n ${NAMESPACE} --to-revision=${REVISION}
fi

# Wait for rollback
echo -e "${YELLOW}Waiting for rollback to complete...${NC}"
kubectl rollout status deployment/safarichap -n ${NAMESPACE} --timeout=10m

# Check status
echo -e "${YELLOW}Current deployment status:${NC}"
kubectl get deployment safarichap -n ${NAMESPACE}
kubectl get pods -n ${NAMESPACE} -l app=safarichap

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Rollback completed successfully!${NC}"
echo -e "${GREEN}===========================================${NC}"
