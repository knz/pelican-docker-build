# Multi-stage Dockerfile for Pelican website development
# Build stage - includes all build tools for compilation
FROM ubuntu:24.04 AS builder

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3-pip \
    curl \
    git \
    make \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create the working directory.
RUN chown -R ubuntu:ubuntu /app && chmod -R a+rX /app
USER ubuntu:ubuntu
ENV HOME=/app

# Install Node.js 22 via nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
    && NVM_DIR=/app/.nvm && . $NVM_DIR/nvm.sh \
    && nvm install 22 \
    && nvm use 22 \
    && nvm alias default 22 \
	&& chmod a+rX $NVM_DIR
ENV NVM_DIR="/app/.nvm"

# Install Rust (required for Stork compilation)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
ENV PATH="/app/.cargo/bin:${PATH}"

# Build and install Stork
RUN cargo install stork-search --locked && chmod -R a+rX /app/.cargo

# Download and install the Node.js modules
COPY package.json       package.json
COPY package-lock.json  package-lock.json
RUN . $NVM_DIR/nvm.sh && npm ci && chmod -R a+rX node_modules

# Install the Python dependencies if requirements.txt exists
# The Pelican module has a pre-built 70MB macOS debug binary, which we don't need or want.
COPY requirements.txt requirements.txt
RUN python3 -m venv .venv \
    && . .venv/bin/activate \
	&& pip install --upgrade pip \
	&& pip install -r requirements.txt \
    && (find .venv -path "*/pelican/build/*-apple-darwin*" -type d -exec rm -rf {} + 2>/dev/null || true)

# Fix the pelican tailwind plugin for use with TailwindCSS v4 if fix script exists
COPY scripts/fix-pelican-tailwind.sh scripts/fix-pelican-tailwind.sh
RUN . .venv/bin/activate && . $NVM_DIR/nvm.sh \
    && ./scripts/fix-pelican-tailwind.sh

# Run the build once if Makefile exists. This also initializes npm_modules in the pelican
# tailwind plugin. So we can adjust the access permissions afterwards.
COPY pelicanconf.py     pelicanconf.py
COPY publishconf.py     publishconf.py
COPY content            content
COPY Makefile           Makefile
COPY tailwind.config.js tailwind.config.js
COPY postcss.config.js  postcss.config.js
COPY input.css          input.css
RUN . .venv/bin/activate && . $NVM_DIR/nvm.sh \
    && make clean  html \
    && chmod -R a+rX .venv

# Runtime stage - minimal dependencies only
FROM ubuntu:24.04 AS runtime

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Fix for repository timestamp issues in Docker
RUN apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false

# Install only essential runtime dependencies (excluding nodejs/npm - will use nvm)
RUN apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    curl \
    make \
    sqlite3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
	&& ln -s /usr/bin/python3.12 /usr/bin/python3

# Copy the Node.js installation
COPY --from=builder /app/.nvm /app/.nvm
ENV NVM_DIR="/app/.nvm"

# Copy Node.js modules
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

# Copy compiled Python virtual environment, including Pelican and plugins.
COPY --from=builder /app/.venv /app/.venv

# Copy Stork binary from Cargo installation
COPY --from=builder /app/.cargo/bin/stork /usr/local/bin/stork

# Switch to the non-root user
USER ubuntu:ubuntu

# Set working directory
WORKDIR /app

# Expose common ports
EXPOSE 8000 80

# Default command activates virtual environment and drops to shell
CMD ["bash", "-c", "source .venv/bin/activate && source $NVM_DIR/nvm.sh && exec bash"]
