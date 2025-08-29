#!/bin/bash

# Load Docker images from saved files
# Run this on the target machine to restore images

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
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if docker-images directory exists
if [ ! -d "docker-images" ]; then
    print_error "docker-images directory not found!"
    print_info "Make sure you've copied the docker-images/ directory from the source machine"
    exit 1
fi

print_info "Loading Docker images from docker-images/ directory..."

# Load base image first
if [ -f "docker-images/ubuntu-24.04.tar.gz" ]; then
    print_info "Loading Ubuntu 24.04 base image..."
    docker load < docker-images/ubuntu-24.04.tar.gz
fi

# Load project image
print_info "Loading ${PROJECT_NAME} image..."
docker load < "docker-images/${PROJECT_NAME}.tar.gz"

print_success "All images loaded successfully!"

print_info ""
print_info "Available images:"
docker images | grep -E "(${PROJECT_NAME}|ubuntu)" | head -10

print_info ""
print_info "You can now use:"
print_info "  ./dev.sh dev     # Start development server"
print_info "  ./dev.sh build   # Build static site"
print_info "  ./dev.sh shell   # Interactive shell"