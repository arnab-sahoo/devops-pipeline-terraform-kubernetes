#!/bin/bash
# scripts/validate_service.sh

# Check if the application is running
if curl -f http://localhost:8080/health; then
    echo "Application health check passed"
    exit 0
else
    echo "Application health check failed"
    exit 1
fi