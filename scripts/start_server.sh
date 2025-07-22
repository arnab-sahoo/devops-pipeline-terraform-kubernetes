#!/bin/bash
# scripts/start_server.sh

cd /opt/devops-app

# Stop any existing containers
docker-compose down

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Pull latest image
docker-compose pull

# Start the application
docker-compose up -d

# Wait for application to be ready
sleep 30

echo "Application started successfully"
