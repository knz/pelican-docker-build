# Pelican Docker Build System

A reusable Docker-based build system for Pelican static site generators, designed to provide consistent development environments across projects using a **shared pre-built Docker image**.

## Features

- **Shared Docker image** - Build once, use across all projects
- **Pre-installed dependencies** - Python 3.12, Node.js 22, TailwindCSS v4, DaisyUI, Stork search
- **Project isolation** - Mount your project files over the generic image
- **TailwindCSS v4** support with automatic plugin fixes
- **Sitemap generation** - Automatic XML sitemap generation for search engines
- **Development server** with live reloading
- **Offline deployment** with image save/load utilities

## Architecture

This system uses a **shared Docker image approach**:

1. **Build Phase**: Create a generic `kena42/pelican-docker-build:latest` image with all tools and dependencies
2. **Runtime Phase**: Projects mount their files into containers using the shared image
3. **Benefits**: No per-project Docker builds, faster startup, consistent environments

## Quick Start

### 1. Use the Pre-Built Image (Recommended)

The easiest way is to use the pre-built image from Docker Hub:

```bash
# Projects can directly use kena42/pelican-docker-build:latest
# No local building required - Docker will pull automatically!
```

### 1b. Build Your Own Image (Optional)

If you need to customize the base image:

```bash
git clone https://github.com/your-org/pelican-docker-build.git
cd pelican-docker-build
./build-image.sh  # Creates kena42/pelican-docker-build:latest
docker push kena42/pelican-docker-build:latest  # Publish to Docker Hub
```

### 2. Add to Your Projects

```bash
# Copy just the runtime files to your project
cp pelican-docker-build/docker-compose.yml /path/to/your/project/
cp pelican-docker-build/dev.sh /path/to/your/project/
cp pelican-docker-build/build.config.sh.template /path/to/your/project/build.config.sh
```

### 3. Configure Your Project

```bash
# Edit the configuration for your project
nano build.config.sh
```

Example `build.config.sh`:
```bash
PROJECT_NAME="my-site"
SERVICE_NAME="my-site" 
DEV_PORT="8000"
INPUT_DIR="content"      # or "input" for some projects
OUTPUT_DIR="output"
SHARED_IMAGE="kena42/pelican-docker-build:latest"
```

### 4. Customize docker-compose.yml

Rename the service in `docker-compose.yml` to match your `SERVICE_NAME`:

```yaml
services:
  my-site:  # Change this to match your SERVICE_NAME
    image: kena42/pelican-docker-build:latest  # Uses shared image from Docker Hub
    # ... rest of configuration stays the same
```

### 5. Start Building

```bash
# Build the site
./dev.sh build

# Start development server  
./dev.sh dev

# Production build
./dev.sh prod

# Interactive shell
./dev.sh shell
```

## Commands

| Command | Description |
|---------|-------------|
| `./dev.sh build` | Build static site (default) |
| `./dev.sh dev` | Start development server with live reload |
| `./dev.sh prod` | Build for production deployment |
| `./dev.sh clean` | Clean generated files |
| `./dev.sh shell` | Start interactive shell in container |

## Configuration Options

Edit `build.config.sh` to customize your project:

```bash
# Required settings
PROJECT_NAME="my-site"          # Used for image names
SERVICE_NAME="my-site"          # Docker compose service name

# Port configuration
DEV_PORT="8000"                 # Development server port
PROD_PORT="80"                  # Production server port

# Directory structure
INPUT_DIR="input"               # Source content directory
OUTPUT_DIR="output"             # Generated site directory
MAKEFILE_PATH="."               # Location of Makefile
```

## Shared Image Management

### Building the Shared Image

**For most users**: Just use the pre-built `kena42/pelican-docker-build:latest` from Docker Hub.

**For maintainers**: Run this to update the shared image:

```bash
cd pelican-docker-build/
./build-image.sh  # Builds kena42/pelican-docker-build:latest
docker push kena42/pelican-docker-build:latest  # Publish to Docker Hub
```

### What's in the Shared Image

- Ubuntu 24.04 base system
- Python 3.12 + virtual environment with common Pelican packages
- Node.js 22 via NVM + TailwindCSS v4
- Stork search engine
- Pelican sitemap plugin for automatic XML sitemap generation
- Pre-applied TailwindCSS plugin fixes
- Minimal Pelican project for initialization

## Project Structure Requirements

Your Pelican project only needs:

```
your-project/
├── docker-compose.yml          # Copied from this repo, customized
├── package.json               # Additional Node.js dependencies (copied from this repo)
├── package-lock.json          # Additional Node.js dependencies (copied from this repo)
├── dev.sh                     # Main build script (copied from this repo, customize as needed)
├── build.config.sh            # Your project configuration
├── Makefile                   # Pelican build targets
├── pelicanconf.py             # Pelican configuration
├── content/                   # Your content directory
└── themes/                    # Your theme (optional)
```

## Offline Deployment

Save images for deployment to systems without internet:

```bash
# Save images
./scripts/save-images.sh

# Copy docker-images/ directory to target system, then:
./scripts/load-images.sh
```

## Examples

See the `examples/` directory for complete project configurations:

- `examples/quintism/` - Configuration for Quintism project
- `examples/landing/` - Configuration for Landing project

## TailwindCSS v4 Support

The system automatically fixes the pelican-tailwindcss plugin for TailwindCSS v4 compatibility by:

- Updating package.json with correct dependencies
- Patching plugin source to avoid permission issues
- Ensuring proper configuration file handling

## Troubleshooting

### Permission Issues
The container runs as the `ubuntu` user and automatically matches your host user ID to avoid permission problems.

### Port Conflicts
Change `DEV_PORT` in `build.config.sh` if the default port 8000 is already in use.

### Missing Dependencies
Ensure your project has:
- `requirements.txt` for Python dependencies
- `Makefile` with standard Pelican targets (`html`, `devserver`, `clean`, `publish`)
- `package.json` if using Node.js dependencies

### Build Failures
Check that all required files exist:
```bash
./dev.sh shell
# Inside container, manually run build steps:
source .venv/bin/activate
source .nvm/nvm.sh
make html
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
