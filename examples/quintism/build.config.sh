#!/bin/bash

# Build configuration for Quintism project

# Project configuration
PROJECT_NAME="quintism"
SERVICE_NAME="quintism"

# Shared image configuration
SHARED_IMAGE="kena42/pelican-docker-build:latest"

# Port configuration
DEV_PORT="8000"
PROD_PORT="80"

# Directory structure - Quintism has input/ directory with make targets
INPUT_DIR="input"
OUTPUT_DIR="output"
MAKEFILE_PATH="."

# This project uses the default settings for most other options