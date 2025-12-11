#!/bin/bash

# Build the shared Pelican Docker image
# Run this script to create/update the shared image that all projects will use

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

IMAGE_NAME="${IMAGE_NAME:-kena42/pelican-docker-build}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

print_info "Building shared Pelican Docker image: $FULL_IMAGE_NAME"
print_info "This image contains:"
print_info "  - Ubuntu 24.04 base"
print_info "  - Python 3.12 + common Pelican packages"
print_info "  - Node.js 22 + TailwindCSS v4 + DaisyUI"
print_info "  - Stork search engine"
print_info "  - TailwindCSS plugin fixes"
print_info "  - Minimal Pelican project for initialization"

# Check if docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

# Build the image
print_info "Building Docker image (this may take several minutes)..."
docker build -t "$FULL_IMAGE_NAME" .

print_success "Docker image built successfully: $FULL_IMAGE_NAME"

# Show image info
print_info "Image details:"
docker images "$IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

print_info ""
print_info "To publish this image to Docker Hub:"
print_info "  docker push $FULL_IMAGE_NAME"
print_info ""
print_info "To use this image in your projects:"
print_info "  1. Copy docker-compose.yml to your project"
print_info "  2. Update service name and ports as needed"
print_info "  3. Run './dev.sh dev' to start development"
print_info ""
print_info "To save this image for offline use:"
print_info "  ./scripts/save-images.sh"
