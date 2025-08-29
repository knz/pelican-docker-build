# Tailwind v4 Compatibility Fix for pelican-tailwindcss

## The Problem

The `pelican-tailwindcss` plugin (version 0.3.0) has two main issues:

1. **Incomplete Tailwind v4 dependencies** - designed for Tailwind CSS v3
2. **Permission issues** - unnecessarily copies config files to plugin directory

### Root Causes

#### 1. Dependency Issues
The plugin's `package.json` only includes:
```json
{
  "dependencies": {
    "tailwindcss": "^3.1.4"
  }
}
```

But Tailwind v4 requires additional packages:
- `@tailwindcss/cli` - Command line interface
- `@tailwindcss/postcss` - PostCSS integration

#### 2. Permission Issues
The plugin unnecessarily copies `tailwind.config.js` from your project to the plugin directory:
```python
# In tailwindcss.py line 23:
shutil.copyfile(twconfig_file_path, os.path.join(BASE_DIR, "tailwind.config.js"))
```

This causes `PermissionError` when running with different UIDs in containerized environments.

See: https://github.com/pelican-plugins/tailwindcss/issues/12

### Error Symptoms
- Build failures with PostCSS-related errors
- Missing Tailwind v4 features
- CSS generation issues
- Permission denied errors when copying config files

## The Solution

### Automated Fix

**For Docker users**: The fix is pre-applied in `kena42/pelican-docker-build:latest` - no action needed.

**For manual installations**: Run the provided fix script:
```bash
./scripts/fix-pelican-tailwind.sh
```

This script:
1. Locates the plugin installation directory
2. Backs up the original `package.json`
3. Updates it with Tailwind v4 dependencies
4. Patches the plugin source code to fix permission issues
5. Installs the required packages (Note: npm install not run in Docker - happens at first pelican build)

### Manual Fix
If the automated script fails, you can fix it manually:

1. **Find the plugin directory:**
   ```bash
   python3 -c "
   import os
   import pelican.plugins.tailwindcss
   plugin_path = os.path.dirname(pelican.plugins.tailwindcss.__file__)
   print(plugin_path)
   "
   ```

2. **Navigate to the plugin directory:**
   ```bash
   cd /path/to/plugin/directory  # Use path from step 1
   ```

3. **Backup and update package.json:**
   ```bash
   cp package.json package.json.backup
   ```

4. **Replace package.json content:**
   ```json
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
           "tailwindcss": "^4.1.12"
       }
   }
   ```

5. **Fix the permission issue by patching the plugin source:**
   ```bash
   # Backup the original source file
   cp tailwindcss.py tailwindcss.py.backup
   
   # Edit tailwindcss.py and make these changes:
   # Line 23: Comment out the copyfile line:
   # shutil.copyfile(twconfig_file_path, os.path.join(BASE_DIR, "tailwind.config.js"))
   
   # Line 63: Change the config path in generate_css function from:
   # twconfig_file_path = os.path.join(BASE_DIR, "tailwind.config.js")
   # to:
   # twconfig_file_path = os.path.join(THEME_PATH, "tailwind.config.js")
   ```

6. **Install dependencies:**
   ```bash
   npm install
   ```

## Integration with Docker Build System

This fix is automatically applied in the shared Docker image:
- **Image build time**: `fix-pelican-tailwind.sh` runs during Docker image creation
- **Pre-installed**: All projects using `kena42/pelican-docker-build:latest` get the fix automatically
- **No user action required**: Projects inherit the fixed plugin from the shared image

## Verification

To verify the fix worked:

1. **Check if dependencies are installed:**
   ```bash
   cd /path/to/plugin/directory
   npm list
   ```

2. **Test build:**
   ```bash
   # For Docker users:
   ./dev.sh build
   
   # For manual installations:
   make clean && make html
   ```

3. **Look for success messages:**
   ```
   tailwindcss 🌬  The version is right (v4.1.12)
   tailwindcss 🌬  Settings were found
   tailwindcss 🌬  Build CSS (/path/to/output.css)
   ```

## Why This Fix is Necessary

### Tailwind CSS v4 Breaking Changes
Tailwind v4 introduced major architectural changes:
- PostCSS plugin moved to separate package
- New CSS-first configuration approach
- Different dependency requirements

### Plugin Maintenance Status
The `pelican-tailwindcss` plugin hasn't been updated for v4 compatibility, requiring this manual intervention until the plugin is officially updated.

## Future Considerations

### When Plugin is Updated
When the plugin officially supports Tailwind v4:
1. The fix script will detect existing v4 dependencies
2. No changes will be made
3. The process remains backward compatible

### Alternative Solutions
If this fix becomes problematic:
1. **Downgrade to Tailwind v3:** Change config to use version "3.4.x"
2. **Switch to direct Tailwind:** Remove plugin and use Tailwind CLI directly
3. **Create custom integration:** Build your own Pelican/Tailwind integration

## Technical Details

### Plugin Architecture
The pelican-tailwindcss plugin:
- Installs its own node_modules in the plugin directory
- Copies `tailwind.config.js` from your project
- Runs `npx tailwindcss` with plugin-specific paths
- Manages version installation via npm

### Fix Implementation
The fix script:
- Uses Python to locate the plugin dynamically
- Preserves original package.json as backup
- Updates only the dependencies section
- Patches the plugin source code to eliminate file copying
- Runs npm install in the plugin's context

#### Source Code Patch Details
The patch modifies `tailwindcss.py`:
1. **Line 23**: Comments out `shutil.copyfile()` that copies config to plugin directory
2. **Line 63**: Changes config path in `generate_css()` to use original theme location

This eliminates the permission issue while maintaining full functionality.

This ensures the fix works regardless of:
- Python installation method (system, user, virtualenv)
- Operating system
- Plugin installation location
- Container user ID or file permissions
