#!/bin/bash

# Build configuration for Landing project (example)

# Project configuration
PROJECT_NAME="landing"
SERVICE_NAME="landing"

# Shared image configuration
SHARED_IMAGE="kena42/pelican-docker-build:latest"

# Port configuration
DEV_PORT="8001"  # Different port to avoid conflicts
PROD_PORT="80"

# Directory structure - adjust based on landing project layout
INPUT_DIR="content"      # Assuming landing uses content/ instead of input/
OUTPUT_DIR="output"
MAKEFILE_PATH="."

# Landing project specific settings can be added here