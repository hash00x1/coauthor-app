# Building CoAuthor App

## Overview
CoAuthor is a professional long-form writing application built on VSCodium, featuring the CoAuthor AI extension pre-installed.

## Quick Start

### Prerequisites
- Node.js v18+ (v22.15.1 recommended)
- 6GB+ available RAM
- macOS (for darwin builds), Windows, or Linux

### Build Commands

```bash
# For macOS Apple Silicon (M1/M2/M3)
npm run build-coauthor

# Or manually:
NODE_OPTIONS=--max-old-space-size=6144 \
node ./node_modules/gulp/bin/gulp.js vscode-darwin-arm64

# For other platforms:
# Windows x64:    gulp vscode-win32-x64
# Linux x64:      gulp vscode-linux-x64
# macOS Intel:    gulp vscode-darwin-x64
```

### Output Location
The built application will be in:
```
../VSCode-darwin-arm64/CoAuthor.app/
```

## What's Different from Standard VSCodium

### 1. CoAuthor Extension Auto-Install
- Your working `coauthor-extension.vsix` is bundled in `resources/app/extensions-vsix/`
- On first launch, the extension automatically installs (no user action needed)
- Implementation: `src/vs/code/electron-utility/sharedProcess/contrib/defaultExtensionsInitializer.ts`

### 2. Coding Extensions Excluded
The following extension categories are **excluded from the build**:
- Programming language extensions (Python, Java, JavaScript, C++, etc.)
- Web development (HTML, CSS, Emmet)
- Build tools (npm, gulp, grunt, make)
- Debug tools
- Docker and terminal-specific tools

**Kept for writers:**
- All Markdown extensions
- LaTeX and reStructuredText
- Git/GitHub (version control)
- Themes and UI customization
- Media preview
- Diff and merge tools

Configuration: `build/lib/extensions.ts` (line 319)

### 3. Writer-Friendly Defaults
Pre-configured settings in `product.json`:
- Word wrap enabled
- Line numbers hidden
- Minimap disabled
- Auto-save enabled (1s delay)
- Code suggestions disabled
- Smooth cursor
- Clean, distraction-free interface

### 4. Branding
- App name: CoAuthor
- Bundle ID: `com.coauthor`
- Data folder: `.vscode-oss` (compatible with VSCode settings)

## Build Process Details

### Standard VSCodium Build Flow
```
1. Compile TypeScript → out-build/
2. Compile Extensions → .build/extensions/
3. Bundle/Minify     → out-vscode/ or out-vscode-min/
4. Package with Electron → ../VSCode-{platform}-{arch}/
```

### CoAuthor Additions
- Step 2.5: Copy `.vsix` files to packaging stream
- Step 4: Bundle includes `resources/app/extensions-vsix/coauthor-extension.vsix`

### Build Time
- **Full build (with minification):** ~25-30 minutes
- **Development build (no minification):** ~7-10 minutes
- **CI build (pre-compiled):** ~3-5 minutes

## Updating Your Extension

### Easy Update (Recommended)
```bash
# 1. Build your updated extension
cd /path/to/coauthor-extension
npm run package

# 2. Copy new .vsix to CoAuthor build
cp coauthor-extension.vsix \
   /path/to/coauthor-app/resources/app/extensions-vsix/

# 3. Rebuild CoAuthor
cd /path/to/coauthor-app
npm run build-coauthor
```

### Alternative: Replace in Existing Build
```bash
# Update the .vsix in an already-built app
cp coauthor-extension.vsix \
   ../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix/

# Users will auto-install the new version on next launch
```

## Troubleshooting

### Build Fails: "Out of memory"
```bash
# Increase Node.js memory:
NODE_OPTIONS=--max-old-space-size=8192 npm run build-coauthor
```

### Extension Not Auto-Installing
Check logs:
```bash
# macOS
~/Library/Application\ Support/CoAuthor/logs/

# Look for messages like:
# "Initializing default extensions"
# "Installing default extension: ...vsix"
```

Verify extension location in built app:
```bash
ls ../VSCode-darwin-arm64/CoAuthor.app/Contents/Resources/app/extensions-vsix/
```

### Build Artifacts Too Large
Clean intermediate files:
```bash
npm run clean

# Or manually:
rm -rf out-build out-vscode out-vscode-min .build
```

## Development Tips

### Quick Iteration
For faster development cycles:
1. Use `vscode-darwin-arm64` (no minification)
2. Keep `out-build/` cached between runs
3. Only run extension compilation when needed

### Testing Without Full Build
```bash
# Install your .vsix in regular VSCodium/VSCode:
code --install-extension coauthor-extension.vsix

# Test it works, then include in CoAuthor build
```

### Debugging Build Issues
```bash
# Verbose output:
DEBUG=* npm run build-coauthor

# Check specific build stage:
gulp compile-build-without-mangling  # TypeScript compilation
gulp bundle-vscode                   # Bundling
gulp vscode-darwin-arm64-ci          # Packaging only
```

## File Structure

```
coauthor-app/
├── resources/app/extensions-vsix/      # Auto-install extensions
│   └── coauthor-extension.vsix         # Your extension
├── build/
│   ├── gulpfile.vscode.js              # Main build script (modified)
│   └── lib/extensions.{ts,js}          # Extension exclusion list (modified)
├── src/vs/code/electron-utility/
│   └── sharedProcess/contrib/
│       └── defaultExtensionsInitializer.ts  # Auto-install logic (modified)
├── product.json                        # Branding + default settings (modified)
└── BUILD_COAUTHOR.md                   # This file
```

## Next Steps: Phase 2 (Optional)

To further customize for professional writing:

### Hide Coding-Related UI Elements
Edit these contribution files:
- `src/vs/workbench/contrib/debug/browser/debug.contribution.ts` (Remove Run & Debug)
- `src/vs/workbench/contrib/scm/browser/scm.contribution.ts` (Source Control customization)
- `src/vs/workbench/contrib/terminal/browser/terminal.contribution.ts` (Terminal panel)

### Custom Welcome Screen
- Modify `src/vs/workbench/contrib/welcomeGettingStarted/` for writer-focused onboarding

### Custom Layouts
- Edit `src/vs/workbench/browser/layout.ts` for default panel positions

## Support

- Website: https://www.co-author.app
- Extension Issues: [Your CoAuthor extension repo]
- Build Issues: This repository

## License

MIT (inherits from VSCodium/VSCode)




