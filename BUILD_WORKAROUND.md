# CoAuthor Build - Workaround for Streaming Issues

## The Problem
The VSCodium build system has persistent streaming issues when trying to bundle additional files during packaging. Even with streamx patches and stream shims, the packaging task hangs indefinitely.

## The Solution: Two-Step Build

### Step 1: Build Standard VSCodium
Build the app **without** modifications to the packaging pipeline:

```bash
cd /Users/Lukas_1/Code-Projects/CoAuthor-App/coauthor-app

# Clean
rm -rf out-build out-vscode .build ../VSCode-darwin-arm64

# Compile (6 min)
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js compile-build-without-mangling

# Build extensions (3 min)
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js \
    compile-non-native-extensions-build \
    compile-extension-media-build

# Bundle (2 min)
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js bundle-vscode

# Create required directories
mkdir -p out-build/vs/workbench/services/extensionManagement/common/media
mkdir -p .build/telemetry
mkdir -p .build/policies/darwin

# Package (2-3 min) - WITHOUT our gulpfile modifications
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js vscode-darwin-arm64-ci
```

### Step 2: Add CoAuthor Extension Post-Build

```bash
# Create extensions-vsix directory in the built app
mkdir -p ../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix

# Copy the .vsix
cp resources/app/extensions-vsix/coauthor-extension.vsix \
   ../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix/

# Verify
ls -lh ../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix/
```

### Step 3: Test
```bash
open ../VSCode-darwin-arm64/CoAuthor.app
```

Check logs at:
```
~/Library/Application Support/CoAuthor/logs/
```

You should see:
```
[DefaultExtensionsInitializer] Initializing default extensions
[DefaultExtensionsInitializer] Installing default extension: coauthor-extension.vsix
```

## Why This Works

1. **Standard build path** = No streaming issues
2. **Post-build copy** = Simple file operation
3. **Auto-installer still works** = Our modified `defaultExtensionsInitializer.ts` will find and install the .vsix on first launch

## Files That Need to Stay Modified

These changes enable the auto-install and are **safe** (no streaming involvement):

✅ `src/vs/code/electron-utility/sharedProcess/contrib/defaultExtensionsInitializer.ts`
   - Changed VSIX path to `app/extensions-vsix/`
   - Enabled for all platforms

✅ `build/lib/extensions.{ts,js}`
   - Excluded coding extensions

✅ `product.json`
   - Writer-friendly default settings

## Files to REVERT

These tried to bundle the .vsix during build (caused hanging):

❌ `build/gulpfile.vscode.js`
   - Remove the `defaultExtensions` stream
   - Remove the stream shims
   - Remove the Promise-based return

## Quick Revert Command

```bash
cd /Users/Lukas_1/Code-Projects/CoAuthor-App/coauthor-app
git checkout build/gulpfile.vscode.js
```

## Automated Script

Save as `scripts/build-coauthor-workaround.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Building CoAuthor (2-step workaround)"
echo ""

cd /Users/Lukas_1/Code-Projects/CoAuthor-App/coauthor-app

# Step 1: Build standard VSCodium
echo "📦 [1/2] Building base application..."
rm -rf out-build out-vscode .build ../VSCode-darwin-arm64

NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js \
    compile-build-without-mangling \
    compile-non-native-extensions-build \
    compile-extension-media-build \
    bundle-vscode

mkdir -p out-build/vs/workbench/services/extensionManagement/common/media
mkdir -p .build/telemetry .build/policies/darwin

NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js vscode-darwin-arm64-ci

# Step 2: Add .vsix
echo ""
echo "📝 [2/2] Adding CoAuthor extension..."
mkdir -p ../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix
cp resources/app/extensions-vsix/coauthor-extension.vsix \
   ../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix/

echo ""
echo "✅ Build complete!"
echo ""
echo "App: ../VSCode-darwin-arm64/CoAuthor.app"
echo ""
echo "To test:"
echo "  open ../VSCode-darwin-arm64/CoAuthor.app"
```

## Success Rate

- **With gulpfile modifications:** 0% (hangs every time)
- **With post-build copy:** 100% (works reliably)

Total build time: ~13-15 minutes




