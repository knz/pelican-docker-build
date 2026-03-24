# Tailwind v4 Compatibility Fix for pelican-tailwindcss v0.4

## The Problem

The `pelican-tailwindcss` plugin (version 0.4.0) uses the standalone Tailwind CLI
via `pytailwindcss`, but its CLI invocation is written for Tailwind v3:

- Uses `-c tailwind.config.js` flag — Tailwind v4 reads config via `@config` in CSS
- Does not pass `--minify` — minification was previously handled by a separate PostCSS step

## The Solution

### Automated Fix

**For Docker users**: The fix is pre-applied in `kena42/pelican-docker-build:latest` — no action needed.

**For manual installations**: Run the provided fix script:
```bash
./scripts/fix-pelican-tailwind.sh
```

This script patches `utils/utils.py` in the plugin directory to:
1. Remove the `-c` config flag (Tailwind v4 uses `@config` directive in `input.css`)
2. Add `--minify` for built-in CSS minification

### What Changed from the v0.3 Patch

The v0.3 patch was much more invasive because v0.3 used npm/Node.js internally:
- Rewrote the plugin's `package.json` with v4 dependencies
- Fixed `shutil.copyfile` permission issues
- Required npm install in the plugin directory

The v0.4 plugin eliminated all of that by switching to the standalone CLI via `pytailwindcss`.
The only remaining issue is the CLI flags.

### PostCSS Removal

With `--minify` built into the Tailwind v4 CLI:
- `postcss`, `postcss-cli`, `autoprefixer`, `cssnano`, `@tailwindcss/postcss` are no longer needed
- Tailwind v4 includes vendor prefixing built-in (replaces autoprefixer)
- The `npx postcss` step in Makefiles is replaced with `cp output.css minified.css`
- `postcss.config.js` can be removed from projects

### Input CSS Configuration

Your `input.css` should use the v4 CSS-first configuration approach:
```css
@import 'tailwindcss';
@config './tailwind.config.js';
```

The `@config` directive tells Tailwind where to find the config file, replacing the `-c` CLI flag.

## Verification

To verify the fix worked:

1. **Test build:**
   ```bash
   # For Docker users:
   ./dev.sh build

   # For manual installations:
   make clean && make html
   ```

2. **Look for success messages:**
   ```
   tailwindcss  Settings were found
   tailwindcss  Build CSS @ /path/to/output.css
   ```

3. **Check that output.css is minified** (single line, no whitespace).

## Technical Details

### Plugin Architecture (v0.4)
- Uses `pytailwindcss` to manage the standalone Tailwind CLI binary
- Downloads the CLI on first run via `tailwindcss_install`
- Version controlled via `TAILWIND.version` in `pelicanconf.py`
- No npm, no node_modules, no package.json in the plugin directory

### Fix Implementation
The patch modifies `utils/utils.py` in the plugin directory:

Before:
```python
f"{prefix}tailwindcss -c {twconfig_file_path} {input_output}"
```

After:
```python
f"{prefix}tailwindcss {input_output} --minify"
```
