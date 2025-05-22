#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to print messages
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Update system packages
log "Updating system packages..."
sudo yum update -y

# Install Docker if not already installed
log "Installing Docker..."
sudo amazon-linux-extras install docker -y
sudo yum install docker -y

# Start Docker service
log "Starting Docker service..."
sudo service docker start

# Add ec2-user to the docker group
log "Adding ec2-user to docker group..."
sudo usermod -a -G docker ec2-user

# Pull latest official Redis image
log "Pulling latest Redis Docker image..."
docker pull redis

# Run Redis container with authentication, persistent data and restart policy
REDIS_PASSWORD="YourStrongPassword"
REDIS_CONTAINER_NAME="redis-server"

# Remove existing container if exists
if [ "$(docker ps -a | grep $REDIS_CONTAINER_NAME)" ]; then
  log "Removing existing Redis container..."
  docker stop $REDIS_CONTAINER_NAME
  docker rm $REDIS_CONTAINER_NAME
fi

# Create a directory for Redis data persistence
REDIS_DATA_DIR="/home/ec2-user/redis-data"
mkdir -p $REDIS_DATA_DIR

# Run new Redis container with password and persistent volume
log "Starting new Redis container with authentication and persistence..."
docker run -d \
  --name $REDIS_CONTAINER_NAME \
  -p 6379:6379 \
  -v $REDIS_DATA_DIR:/data \
  --restart always \
  redis redis-server \
  --requirepass "$REDIS_PASSWORD" \
  --appendonly yes

log "Redis server setup complete!"
log "Redis is running on port 6379 with password: $REDIS_PASSWORD"
