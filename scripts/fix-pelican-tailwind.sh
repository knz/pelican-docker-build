#!/bin/bash

# Fix pelican-tailwindcss plugin for Tailwind v4 compatibility
# This script addresses the missing dependencies in the plugin's package.json

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Fixing pelican-tailwindcss plugin for Tailwind v4 compatibility..."

# Find the plugin installation directory
PLUGIN_DIR=$(python3 -c "
import os
import pelican.plugins.tailwindcss
plugin_path = os.path.dirname(pelican.plugins.tailwindcss.__file__)
print(plugin_path)
" 2>/dev/null)

if [ -z "$PLUGIN_DIR" ]; then
    print_error "Could not find pelican-tailwindcss plugin installation directory"
    exit 1
fi

print_status "Found plugin at: $PLUGIN_DIR"

# Check if package.json exists
PACKAGE_JSON="$PLUGIN_DIR/package.json"
if [ ! -f "$PACKAGE_JSON" ]; then
    print_error "package.json not found at $PACKAGE_JSON"
    exit 1
fi

# Backup original package.json
cp "$PACKAGE_JSON" "$PACKAGE_JSON.backup"
print_status "Backed up original package.json"

# Check current package.json content
if grep -q "@tailwindcss/cli" "$PACKAGE_JSON" && grep -q "@tailwindcss/postcss" "$PACKAGE_JSON"; then
    print_success "Tailwind v4 dependencies already present in package.json"
else
    print_warning "Tailwind v4 dependencies missing, updating package.json..."
    
    # Create updated package.json with v4 dependencies
    cat > "$PACKAGE_JSON" << 'EOF'
{
    "name": "tailwindcss",
    "version": "1.0.0",
    "description": "",
    "main": "index.js",
    "scripts": {
        "tailwindcss": "tailwindcss"
    },
    "author": "",
    "license": "AGPL-3.0",
    "dependencies": {
        "@tailwindcss/cli": "^4.1.12",
        "@tailwindcss/postcss": "^4.1.12",
        "tailwindcss": "^4.1.12",
		"daisyui": "^5.5.11"
    }
}
EOF
    print_success "Updated package.json with Tailwind v4 dependencies"
fi

# Remove outdated lock file if it exists
if [ -f "$PLUGIN_DIR/package-lock.json" ]; then
    print_status "Removing outdated package-lock.json..."
    rm "$PLUGIN_DIR/package-lock.json"
fi

# Fix the permission issue by patching the plugin source code
PLUGIN_SOURCE="$PLUGIN_DIR/tailwindcss.py"
if [ -f "$PLUGIN_SOURCE" ]; then
    print_status "Patching plugin source to fix permission issues..."
    
    # Backup original source
    cp "$PLUGIN_SOURCE" "$PLUGIN_SOURCE.backup"
    
    # Check if already patched
    if grep -q "# PATCHED: Use config from theme directory" "$PLUGIN_SOURCE"; then
        print_success "Plugin source already patched for permission fix"
    else
        # Apply the patch using sed
        sed -i '
        # Comment out the problematic copyfile line
        s/^    shutil\.copyfile(twconfig_file_path, os\.path\.join(BASE_DIR, "tailwind\.config\.js"))/    # PATCHED: Use config from theme directory\n    # shutil.copyfile(twconfig_file_path, os.path.join(BASE_DIR, "tailwind.config.js"))/
        
        # Update the config path in generate_css function
        s/twconfig_file_path = os\.path\.join(BASE_DIR, "tailwind\.config\.js")/twconfig_file_path = os.path.join(THEME_PATH, "tailwind.config.js")/
        ' "$PLUGIN_SOURCE"
        
        print_success "Plugin source patched to use config from theme directory"
    fi
else
    print_warning "Plugin source file not found at $PLUGIN_SOURCE"
fi

# NB: do not run 'npm install' at this point;
# the first pelican run will complete the installation and also create a
# configuration file.

print_success "Plugin fix completed successfully!"
print_status "The pelican-tailwindcss plugin now supports Tailwind v4"
print_status "Permission issues with config file copying have been resolved"
