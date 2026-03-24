#!/bin/bash

# Fix pelican-tailwindcss v0.4 plugin for Tailwind v4 compatibility
# The v0.4 plugin uses the standalone Tailwind CLI via pytailwindcss,
# but its CLI invocation still uses v3-style flags (-c for config).
# Tailwind v4 reads config via @config in the CSS file, and supports --minify.

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

# Patch utils/utils.py: remove -c flag, add --minify
UTILS_SOURCE="$PLUGIN_DIR/utils/utils.py"
if [ -f "$UTILS_SOURCE" ]; then
    # Check if already patched
    if grep -q '# PATCHED: Tailwind v4' "$UTILS_SOURCE"; then
        print_success "utils.py already patched"
    else
        print_status "Patching utils/utils.py for Tailwind v4 CLI flags..."
        cp "$UTILS_SOURCE" "$UTILS_SOURCE.backup"

        sed -i 's|f"{prefix}tailwindcss -c {twconfig_file_path} {input_output}"|# PATCHED: Tailwind v4 - drop -c flag (config via @config in CSS), add --minify\n        f"{prefix}tailwindcss {input_output} --minify"|' "$UTILS_SOURCE"

        print_success "Patched utils/utils.py: removed -c flag, added --minify"
    fi
else
    print_error "utils/utils.py not found at $UTILS_SOURCE"
    exit 1
fi

print_success "Plugin fix completed successfully!"
print_status "The pelican-tailwindcss plugin now uses Tailwind v4 CLI flags with --minify"
