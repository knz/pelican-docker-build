#!/bin/bash

# Save Docker images for offline deployment
# This saves the complete images including base layers

set -e

# Load configuration if available
if [ -f "../build.config.sh" ]; then
    source "../build.config.sh"
elif [ -f "./build.config.sh" ]; then
    source "./build.config.sh"
fi

# Default configuration
PROJECT_NAME="${PROJECT_NAME:-pelican-site}"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Create images directory
mkdir -p docker-images

print_info "Saving Docker images for offline use..."

# Save the project image (name determined by directory and PROJECT_NAME)
IMAGE_NAME="${PWD##*/}_${PROJECT_NAME}:latest"
print_info "Saving $IMAGE_NAME..."
docker save "$IMAGE_NAME" | gzip > "docker-images/${PROJECT_NAME}.tar.gz"

# Save base image too (Ubuntu)
print_info "Saving base Ubuntu image..."
docker save ubuntu:24.04 | gzip > docker-images/ubuntu-24.04.tar.gz

print_success "All images saved to docker-images/ directory"

# Show file sizes
print_info "Image sizes:"
ls -lh docker-images/

print_info ""
print_info "To load images on another machine:"
print_info "  docker load < docker-images/${PROJECT_NAME}.tar.gz"
print_info "  docker load < docker-images/ubuntu-24.04.tar.gz"
