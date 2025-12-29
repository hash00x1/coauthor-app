# Agent Handoff Context - CoAuthor Build

## Quick Summary
Building a standalone macOS app called "CoAuthor" (professional writing tool) by forking VSCodium and bundling a custom extension. **The app now builds, launches, and the extension auto-installs successfully!** 🎉

---

## Current State

### What Works ✅
- App builds successfully (15-20 min build time)
- App launches on macOS Apple Silicon
- **Extension auto-installs on first launch** ✨
- **Extension UI loads and is functional** ✨
- 60+ coding extensions excluded from build
- Writer-friendly default settings applied
- Proper data folder isolation (`.coauthor`)

### Minor Issue ⚠️
- Extension icons not displaying (codicon.css loading error)
  - Extension is fully functional, just missing visual icons
  - Does not affect core functionality

### Location
```
/Users/Lukas_1/Code-Projects/CoAuthor-App/coauthor-app/
```

Built app:
```
/Applications/CoAuthor.app
```

Extension location in app:
```
/Applications/CoAuthor.app/Contents/Resources/app/extensions-vsix/coauthor-extension.vsix
```

---

## What Was Fixed

### Issue 1: Auto-Installer Not Triggering ✅ SOLVED
**Problem:** Extension installer service was running but silently failing

**Root Causes:**
1. **Version mismatch**: App version was `1.0.0`, extension required `^1.84.0`
2. **Wrong data folder**: Extensions installing to `.vscode-oss` instead of CoAuthor-specific location

**Solution:**
1. Updated `package.json`: Changed version from `1.0.0` to `1.95.0`
2. Updated `product.json`: Changed `dataFolderName` from `.vscode-oss` to `.coauthor`
3. Added comprehensive debug logging to `defaultExtensionsInitializer.ts`

### Issue 2: View Container Not Loading ✅ SOLVED
**Problem:** Extension installed but showed "MISSING" with error:
```
View container 'claude-dev-ActivityBar' does not exist
```

**Root Cause:** Extension was trying to register view in `auxiliarybar` (right sidebar), which wasn't properly supported in VSCodium fork

**Solution:** Modified extension's `package.json` to use `activitybar` instead:
```json
// Before:
"viewsContainers": {
  "auxiliarybar": [ ... ]
}

// After:
"viewsContainers": {
  "activitybar": [
    {
      "id": "claude-dev-ActivityBar",
      "title": "CoAuthor",
      "icon": "assets/icons/icon.svg"
    }
  ]
}
```

### Issue 3: Build Order ✅ SOLVED
**Problem:** Build failed with missing directory error during bundling

**Solution:** Create required directories BEFORE bundling step (updated in build process below)

---

## Critical Files

### Modified (Safe - Keep These)

1. **`src/vs/code/electron-utility/sharedProcess/contrib/defaultExtensionsInitializer.ts`**
   - Changed VSIX path from `bootstrap/extensions` to `app/extensions-vsix`
   - Enabled auto-install on all platforms (not just Windows)
   - Added comprehensive debug logging with `[CoAuthor]` prefix
   - **Status: Working perfectly** ✅

2. **`build/lib/extensions.{ts,js}`**
   - Excluded 60+ coding-related extensions
   - Kept markdown, latex, git, themes
   - **Status: Working perfectly** ✅

3. **`product.json`**
   - Changed `dataFolderName` from `.vscode-oss` to `.coauthor`
   - Added writer-friendly default settings
   - **Status: Working perfectly** ✅

4. **`package.json`**
   - Changed version from `1.0.0` to `1.95.0`
   - **Status: Working perfectly** ✅

5. **`resources/app/extensions-vsix/coauthor-extension.vsix`**
   - Modified to use `activitybar` instead of `auxiliarybar`
   - Properly structured with `extension/` directory inside .vsix
   - **Status: Working with minor icon issue** ⚠️

### Reverted (Critical - Don't Modify)
- **`build/gulpfile.vscode.js`** - Must stay at original VSCodium version
  - Any modifications cause persistent streamx errors and build hangs

---

## Build Process (Complete & Working)

**Build Time Breakdown:**
- Compilation: ~18-21 min
- Bundling: ~20 sec
- Packaging: ~40 sec
- Post-build: ~1 min
- **Total: ~22 min**

**Last Verified:** October 1, 2025 - Full clean build successful

### Prerequisites
```bash
cd /Users/Lukas_1/Code-Projects/CoAuthor-App/coauthor-app
```

### Step 1: Clean Previous Builds
```bash
rm -rf out-build out-vscode .build ../VSCode-darwin-arm64
```

### Step 2: Compile TypeScript and Build Extensions (~18 min)
```bash
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js \
    compile-build-without-mangling \
    compile-non-native-extensions-build \
    compile-extension-media-build
```

### Step 3: Create Required Directories (CRITICAL - Must be before bundling!)
```bash
mkdir -p out-build/vs/workbench/services/extensionManagement/common/media
mkdir -p .build/telemetry .build/policies/darwin
```

### Step 4: Bundle VSCode (~20 sec)
```bash
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js bundle-vscode
```

### Step 5: Package Application (~30 sec)
```bash
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js vscode-darwin-arm64-ci
```

### Step 6: Add Extension .vsix (Post-Build)
```bash
cd /Users/Lukas_1/Code-Projects/CoAuthor-App
mkdir -p VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix
cp coauthor-app/resources/app/extensions-vsix/coauthor-extension.vsix \
   VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix/
```

### Step 7: Fix Corrupted Native Modules (CRITICAL!)
```bash
cd coauthor-app
find node_modules -name "*.node" -type f -exec sh -c \
  'src="{}"; dst="../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/$src"; \
   mkdir -p "$(dirname "$dst")"; cp -f "$src" "$dst"' \;
```

**Why this is critical:** During packaging, native `.node` files get corrupted (become `data` type instead of `Mach-O arm64`). Without this step, the app fails to launch.

### Step 8: Deploy to /Applications
```bash
rm -rf /Applications/CoAuthor.app
cp -R ../VSCode-darwin-arm64/CoAuthor.app /Applications/
xattr -cr /Applications/CoAuthor.app
```

### Complete Build Script (All Steps)
```bash
#!/bin/bash
set -e

cd /Users/Lukas_1/Code-Projects/CoAuthor-App/coauthor-app

echo "Step 1: Clean..."
rm -rf out-build out-vscode .build ../VSCode-darwin-arm64

echo "Step 2: Compile TypeScript and extensions..."
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js \
    compile-build-without-mangling \
    compile-non-native-extensions-build \
    compile-extension-media-build

echo "Step 3: Create required directories..."
mkdir -p out-build/vs/workbench/services/extensionManagement/common/media
mkdir -p .build/telemetry .build/policies/darwin

echo "Step 4: Bundle VSCode..."
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js bundle-vscode

echo "Step 5: Package application..."
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js vscode-darwin-arm64-ci

echo "Step 6: Add extension .vsix..."
cd /Users/Lukas_1/Code-Projects/CoAuthor-App
mkdir -p VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix
cp coauthor-app/resources/app/extensions-vsix/coauthor-extension.vsix \
   VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix/

echo "Step 7: Fix native modules..."
cd coauthor-app
find node_modules -name "*.node" -type f -exec sh -c \
  'src="{}"; dst="../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/$src"; \
   mkdir -p "$(dirname "$dst")"; cp -f "$src" "$dst"' \;

echo "Step 8: Deploy..."
rm -rf /Applications/CoAuthor.app
cp -R ../VSCode-darwin-arm64/CoAuthor.app /Applications/
xattr -cr /Applications/CoAuthor.app

echo "✅ Build complete! App deployed to /Applications/CoAuthor.app"
```

---

## How to Modify the Extension

If you need to modify the bundled extension (e.g., fix icons, change UI):

### 1. Extract and Modify
```bash
cd /tmp
rm -rf extension-mod
mkdir -p extension-mod/extension
unzip ~/coauthor-app/resources/app/extensions-vsix/coauthor-extension.vsix -d extension-mod/
cd extension-mod/extension

# Make your changes to package.json or other files
# Example: Fix viewsContainers
nano package.json
```

### 2. Repackage as .vsix
```bash
cd /tmp/extension-mod
zip -r coauthor-extension-fixed.vsix . -x "*.DS_Store" -q
```

**Important:** .vsix structure must be:
```
coauthor-extension.vsix
└── extension/
    ├── package.json
    ├── dist/
    ├── assets/
    └── ... (all extension files)
```

### 3. Replace in Project
```bash
cp /tmp/extension-mod/coauthor-extension-fixed.vsix \
   /Users/Lukas_1/Code-Projects/CoAuthor-App/coauthor-app/resources/app/extensions-vsix/coauthor-extension.vsix
```

### 4. Rebuild App
Follow the build process from Step 5 onwards (no need to recompile TypeScript unless you changed VS Code source).

---

## Key Commands

### Launch App
```bash
open /Applications/CoAuthor.app
```

### Debug Launch (See Console Output)
```bash
/Applications/CoAuthor.app/Contents/MacOS/Electron
```

### Check If Running
```bash
ps aux | grep CoAuthor
```

### View Logs
```bash
# Most recent logs
ls -t ~/Library/Application\ Support/CoAuthor/logs/ | head -1

# Auto-installer logs
cat ~/Library/Application\ Support/CoAuthor/logs/*/sharedprocess.log | grep "\[CoAuthor\]"

# Extension activation logs
cat ~/Library/Application\ Support/CoAuthor/logs/*/window1/exthost/output_logging_*/1-*.log
```

### Reset App Data (Triggers Fresh Install)
```bash
rm -rf ~/Library/Application\ Support/CoAuthor ~/.coauthor
```

### Check Installed Extensions
```bash
ls -la ~/.coauthor/extensions/
```

### Verify .vsix in App Bundle
```bash
ls -lh /Applications/CoAuthor.app/Contents/Resources/app/extensions-vsix/
```

---

## What Happens on First Launch

1. **App starts**, `DefaultExtensionsInitializer` service initializes
2. **Storage check**: Reads `initializing-default-extensions` key (defaults to `true` on first run)
3. **Path resolution**: Looks for `.vsix` files in `app/extensions-vsix/`
4. **Installation**: Installs each `.vsix` to `~/.coauthor/extensions/`
5. **Storage update**: Sets key to `false` to prevent re-installation
6. **Extension activation**: Extension activates and registers UI in activity bar

**Debug logs show:**
```
[CoAuthor] DefaultExtensionsInitializer constructor called
[CoAuthor] Storage key 'initializing-default-extensions' current value: true
[CoAuthor] Condition passed - will initialize default extensions
[CoAuthor] initializeDefaultExtensions called
[CoAuthor] Extensions location: file:///Applications/CoAuthor.app/Contents/Resources/app/extensions-vsix
[CoAuthor] Initializing default extensions
[CoAuthor] Installing default extension: coauthor-extension.vsix
[CoAuthor] Default extension installed
[CoAuthor] Extension initialization complete, setting key to false
```

---

## Outstanding Issues

### Minor: Icon Display ⚠️
**Symptom:** Extension icons not showing in UI

**Error in logs:**
```
Webview.loadLocalResource - Error using fileReader.
requestUri=file:///.../node_modules/@vscode/codicons/dist/codicon.css
```

**Impact:** Low - Extension is fully functional, just missing visual icons

**Potential fixes to try:**
1. Bundle codicons CSS directly in extension instead of loading from node_modules
2. Check webview resource loading permissions in extension manifest
3. Copy codicons to extension assets folder

**Workaround:** Extension works perfectly without icons

---

## Project Structure

```
/Users/Lukas_1/Code-Projects/CoAuthor-App/
├── coauthor-app/                                 ← VSCodium fork
│   ├── src/vs/code/electron-utility/sharedProcess/contrib/
│   │   └── defaultExtensionsInitializer.ts       ← Auto-installer (✅ working)
│   ├── build/
│   │   ├── gulpfile.vscode.js                   ← Build pipeline (ORIGINAL - don't modify)
│   │   └── lib/extensions.{ts,js}               ← Extension exclusions (modified)
│   ├── product.json                             ← Branding + data folder (modified)
│   ├── package.json                             ← App version (modified to 1.95.0)
│   ├── resources/app/extensions-vsix/
│   │   └── coauthor-extension.vsix              ← 51MB extension (modified)
│   ├── scripts/patch-streamx.sh                 ← Essential patch
│   ├── problem-description.md                   ← Complete history
│   ├── BUILD_WORKAROUND.md                      ← Old build instructions
│   └── HANDOFF.md                               ← This file
│
└── VSCode-darwin-arm64/
    └── CoAuthor.app/                            ← Built application (432MB)
```

---

## Success Criteria

- [x] Extension auto-installs on first launch (no manual intervention)
- [x] CoAuthor UI/theme loads automatically
- [x] Extension is fully functional
- [x] Single command builds and packages everything
- [ ] Icon display issue resolved (minor, not blocking)

---

## Environment

- **Platform:** macOS 14.6.0 (darwin 24.6.0)
- **Hardware:** Apple M2, 8GB RAM
- **Node:** v22.15.1
- **Architecture:** arm64
- **App Version:** 1.95.0
- **Extension Location:** `~/.coauthor/extensions/`
- **App Data Location:** `~/Library/Application Support/CoAuthor/`

---

## Lessons Learned

### 1. Version Compatibility Matters
VSCode extensions have strict version requirements. Always ensure the app version meets the extension's `engines.vscode` requirement.

### 2. Data Folder Isolation
Using a custom `dataFolderName` (`.coauthor`) prevents conflicts with other VSCode installations and keeps extensions isolated.

### 3. View Container API Differences
Not all VSCode view container APIs are equally supported in VSCodium forks. `activitybar` is more reliable than `auxiliarybar`.

### 4. .vsix Structure is Critical
The extension installer expects a specific structure:
- Must have `extension/` directory at root (NOT nested `extension/extension/`)
- `extension/package.json` must be present
- All extension files must be inside `extension/`
- **Common error:** "extension/package.json not found inside zip" means wrong structure
- **Fix:** Recreate with proper structure from source files

### 5. Native Module Corruption
Electron packaging sometimes corrupts native `.node` files. Always copy them fresh from `node_modules` after packaging.

### 6. Build Order Matters
Some gulp tasks expect directories to exist before they run. Create them explicitly rather than relying on implicit creation.

### 7. Debug Logging is Essential
Adding `[CoAuthor]` prefixed logs throughout the auto-installer made debugging possible. Without them, silent failures would be impossible to diagnose.

---

## Common Issues & Troubleshooting

### "extension/package.json not found inside zip"
**Cause:** Incorrect .vsix structure (likely double-nested `extension/extension/`)

**Fix:**
```bash
cd /tmp
mkdir -p vsix-fix/extension
# Copy extension files to vsix-fix/extension/
cp -R /path/to/extension/files/* vsix-fix/extension/
cd vsix-fix
zip -r coauthor-extension.vsix . -x "*.DS_Store" -q
# Verify structure
unzip -l coauthor-extension.vsix | grep "extension/package.json"
```

### Extension Not Installing on First Launch
**Check:**
1. Verify .vsix exists: `ls -lh /Applications/CoAuthor.app/Contents/Resources/app/extensions-vsix/`
2. Check logs: `cat ~/Library/Application\ Support/CoAuthor/logs/*/sharedprocess.log | grep "\[CoAuthor\]"`
3. Reset app data: `rm -rf ~/Library/Application\ Support/CoAuthor ~/.coauthor`

### App Won't Launch
**Most likely:** Native modules corrupted during packaging
**Fix:** Re-run Step 7 (native module copy) from build process

### Build Hangs During Bundling
**Check:** Did you create required directories before bundling?
**Fix:** Run Step 3 (create directories) before Step 4 (bundle)

---

## Next Steps (Planned)

### Priority 1: Icon & Visual Polish 🎨
1. **Fix codicon loading** - Bundle icons properly in extension
2. **Design custom CoAuthor icons** - Replace generic icons with branded ones
3. **UI/UX improvements** - Polish the writing-focused interface
4. **Theme refinement** - Ensure writer-friendly color scheme

### Priority 2: Feature Enhancements
1. **Optimize writer workflow** - Remove unnecessary coding features
2. **Add writing-specific tools** - Grammar, style, word count
3. **Improve extension performance** - Faster load times

### Priority 3: Distribution
1. **Create installer/DMG** - Easy distribution for end users
2. **Add auto-update mechanism** - Update extension without full rebuild
3. **Code signing** - Proper macOS signing for distribution

---

## Important Notes

1. **Never modify `build/gulpfile.vscode.js`** - Always causes build to hang
2. **Step 7 (native module copy) is mandatory** - App won't launch without it
3. **Step 3 (create directories) must be before Step 4** - Build fails otherwise
4. **Disk space matters** - Need 15GB+ free during build
5. **Extension is already built** - Don't try to rebuild it, just use/modify the .vsix
6. **Storage keys persist** - May need to clear app data to re-trigger auto-install
7. **First launch is special** - Extension only auto-installs once, on first launch

---

**Current Status:** ✅ **SUCCESS** - App builds, launches, extension auto-installs and works perfectly!

**Achievements:**
- ✅ Full build pipeline working (22 min total)
- ✅ Extension auto-installer functional
- ✅ UI loads and displays correctly in activity bar
- ✅ All core functionality operational

**Known Minor Issue:**
- ⚠️ Icons not displaying (codicon.css) - doesn't affect functionality

**Ready for:** UX improvements and icon design/branding work

---

Last Updated: October 1, 2025 - Build #2 (Full Rebuild Success)
