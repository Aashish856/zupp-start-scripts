#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to print messages
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Update system packages
log "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker if not already installed
log "Installing Docker..."
sudo apt-get install -y docker.io

# Start Docker service
log "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to the docker group
log "Adding ubuntu user to docker group..."
sudo usermod -aG docker ubuntu

# Pull latest official Redis image
log "Pulling latest Redis Docker image..."
sudo docker pull redis:7-alpine

# Run Redis container with authentication, persistent data and restart policy
REDIS_PASSWORD="YourStrongPassword"
REDIS_CONTAINER_NAME="redis-server"

# Remove existing container if exists
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^${REDIS_CONTAINER_NAME}\$"; then
  log "Removing existing Redis container..."
  sudo docker stop $REDIS_CONTAINER_NAME
  sudo docker rm $REDIS_CONTAINER_NAME
fi

# Create a directory for Redis data persistence
REDIS_DATA_DIR="/home/ubuntu/redis-data"
log "Creating Redis data directory at $REDIS_DATA_DIR..."
sudo mkdir -p $REDIS_DATA_DIR

# Run new Redis container with password and persistent volume
log "Starting new Redis container with authentication and persistence..."
sudo docker run -d \
  --name $REDIS_CONTAINER_NAME \
  -p 6379:6379 \
  -v $REDIS_DATA_DIR:/data \
  --restart always \
  redis:7-alpine \
  redis-server --requirepass "$REDIS_PASSWORD" --appendonly yes

log "Redis server setup complete!"
log "Redis is running on port 6379 with password: $REDIS_PASSWORD"
