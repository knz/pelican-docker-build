#!/bin/bash

# Development script for Pelican websites
# Usage: ./dev.sh [task]
#
# Available tasks:
#   clean     - Clean generated files
#   build     - Build static site (default)
#   publish   - Build for production
#   dev       - Start development server
#   shell     - Interactive shell

set -e

# Cleanup function to remove Docker networks on exit
cleanup() {
    if [ -n "$DOCKER_COMPOSE" ]; then
        $DOCKER_COMPOSE down 2>/dev/null || true
    fi
}
trap cleanup EXIT

# Load configuration
CONFIG_FILE="${BUILD_CONFIG:-./build.config.sh}"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Default configuration - can be overridden in build.config.sh
PROJECT_NAME="${PROJECT_NAME:-pelican-site}"
SERVICE_NAME="${SERVICE_NAME:-$PROJECT_NAME}"
DEV_PORT="${DEV_PORT:-8000}"
PROD_PORT="${PROD_PORT:-80}"
INPUT_DIR="${INPUT_DIR:-content}"  # Changed default from input to content
OUTPUT_DIR="${OUTPUT_DIR:-output}"
MAKEFILE_PATH="${MAKEFILE_PATH:-.}"
SHARED_IMAGE="${SHARED_IMAGE:-kena42/pelican-docker-build:latest}"

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

show_help() {
    echo "Development Script for Pelican Websites"
    echo ""
    echo "Usage: $0 [task]"
    echo ""
    echo "Available tasks:"
    echo "  build     - Build static site (default)"
    echo "  dev       - Start development server"
    echo "  prod      - Build for production"
    echo "  clean     - Clean generated files"
    echo "  shell     - Start interactive shell"
    echo "  cleanup   - Clean up Docker resources (networks, stopped containers)"
    echo ""
    echo "Configuration:"
    echo "  Set BUILD_CONFIG environment variable to use custom config file"
    echo "  Default config file: ./build.config.sh"
    echo ""
    echo "Examples:"
    echo "  $0          # Build the site"
    echo "  $0 dev      # Start development server at http://localhost:$DEV_PORT"
    echo "  $0 shell    # Get interactive shell for custom commands"
    echo ""
    echo "Current configuration:"
    echo "  Project: $PROJECT_NAME"
    echo "  Service: $SERVICE_NAME" 
    echo "  Shared image: $SHARED_IMAGE"
    echo "  Dev port: $DEV_PORT"
    echo "  Input dir: $INPUT_DIR"
    echo "  Output dir: $OUTPUT_DIR"
}

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    print_warning "docker-compose not found. Trying docker compose..."
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

case "${1:-build}" in
    build)
        print_info "Building static site..."
        $DOCKER_COMPOSE run --rm $SERVICE_NAME bash -c "source .nvm/nvm.sh && source .venv/bin/activate && cd /app/$MAKEFILE_PATH && make html"
        print_success "Build completed - site generated in $OUTPUT_DIR/"
        ;;
    dev)
        print_info "Starting development server..."
        print_info "Server will be available at http://localhost:$DEV_PORT"
        print_info "Press Ctrl+C to stop"
        $DOCKER_COMPOSE run --rm -p $DEV_PORT:8000 $SERVICE_NAME bash -c "source .nvm/nvm.sh && source .venv/bin/activate && cd /app/$MAKEFILE_PATH && make devserver-global"
        ;;
    prod)
        print_info "Building for production..."
        $DOCKER_COMPOSE run --rm $SERVICE_NAME bash -c "source .nvm/nvm.sh && source .venv/bin/activate && cd /app/$MAKEFILE_PATH && make publish"
        print_success "Production build completed"
        ;;
    clean)
        print_info "Cleaning generated files..."
        $DOCKER_COMPOSE run --rm $SERVICE_NAME bash -c "source .nvm/nvm.sh && source .venv/bin/activate && cd /app/$MAKEFILE_PATH && make clean"
        print_success "Clean completed"
        ;;
    shell)
        print_info "Starting interactive shell..."
        print_info "Virtual environment will be activated automatically"
        print_info "Available commands: make clean, make html, make devserver, make publish"
        $DOCKER_COMPOSE run --rm $SERVICE_NAME bash -c "source .nvm/nvm.sh && source .venv/bin/activate && exec bash"
        ;;
    cleanup)
        print_info "Cleaning up Docker resources..."
        $DOCKER_COMPOSE down
        docker network prune -f
        print_success "Cleanup completed - removed unused networks and stopped containers"
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo "Unknown task: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
