#!/bin/bash
# jenkins/scripts/test.sh
# Run all tests and generate reports

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}Running Tests${NC}"
echo -e "${GREEN}===========================================${NC}"

# Create test results directory
mkdir -p test-results

# Run linters
echo -e "${YELLOW}Running linters...${NC}"
docker-compose -f docker-compose.test.yml run --rm lint || {
    echo -e "${RED}Linting failed!${NC}"
    exit 1
}

# Run security checks
echo -e "${YELLOW}Running security checks...${NC}"
docker-compose -f docker-compose.test.yml run --rm security || {
    echo -e "${YELLOW}Warning: Security issues found${NC}"
}

# Run unit tests
echo -e "${YELLOW}Running unit tests...${NC}"
docker-compose -f docker-compose.test.yml run --rm web \
    pytest tests/unit/ -v --junitxml=test-results/unit-results.xml || {
    echo -e "${RED}Unit tests failed!${NC}"
    exit 1
}

# Run integration tests
echo -e "${YELLOW}Running integration tests...${NC}"
docker-compose -f docker-compose.test.yml run --rm web \
    pytest tests/integration/ -v --junitxml=test-results/integration-results.xml || {
    echo -e "${RED}Integration tests failed!${NC}"
    exit 1
}

# Run coverage
echo -e "${YELLOW}Generating coverage report...${NC}"
docker-compose -f docker-compose.test.yml run --rm coverage

# Display coverage summary
if [ -f coverage.xml ]; then
    echo -e "${YELLOW}Coverage Summary:${NC}"
    cat coverage.xml | grep -o 'line-rate="[^"]*"' | head -1
fi

# Cleanup
echo -e "${YELLOW}Cleaning up...${NC}"
docker-compose -f docker-compose.test.yml down -v

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}All tests completed successfully!${NC}"
echo -e "${GREEN}===========================================${NC}"
