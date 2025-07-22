#!/bin/bash
# scripts/stop_server.sh

cd /opt/devops-app

# Stop the application gracefully
docker-compose down

# Remove unused images to free up space
docker image prune -f

echo "Application stopped successfully"
