#!/bin/bash
set -e

# Complete build script for CoAuthor-App
# This script orchestrates the full build process:
# 1. Pre-build coauthor-agent extension (isolated to prevent dependency conflicts)
# 2. Run the main VSCodium build

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse command line arguments
PLATFORM="${1:-darwin}"
ARCH="${2:-arm64}"
BUILD_TARGET="vscode-${PLATFORM}-${ARCH}"

echo "╔═══════════════════════════════════════════════════════╗"
echo "║         CoAuthor-App Full Build Process              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "Target: $BUILD_TARGET"
echo "Project: $PROJECT_ROOT"
echo ""

# Step 1: Pre-build coauthor-agent
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Pre-building coauthor-agent extension"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPT_DIR/build-coauthor-agent.sh"

# Step 2: Run main build
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Running main VSCodium build"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$PROJECT_ROOT"

# Use increased memory allocation for build
export NODE_OPTIONS="--max-old-space-size=6144"

# Run the appropriate gulp task
node ./node_modules/gulp/bin/gulp.js "$BUILD_TARGET-ci"

# Check if build succeeded
BUILD_OUTPUT="../VSCode-${PLATFORM}-${ARCH}"
if [ -d "$BUILD_OUTPUT" ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║              ✓ BUILD COMPLETED SUCCESSFULLY           ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    echo "Output location: $BUILD_OUTPUT"

    # Show directory size
    if command -v du &> /dev/null; then
        SIZE=$(du -sh "$BUILD_OUTPUT" | cut -f1)
        echo "Build size: $SIZE"
    fi

    # Check for coauthor-agent in build output
    if [ -d "$BUILD_OUTPUT/resources/app/extensions/coauthor-agent" ]; then
        echo "✓ coauthor-agent extension included"
    else
        echo "⚠ Warning: coauthor-agent extension not found in build output"
    fi
else
    echo ""
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                ✗ BUILD FAILED                         ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    echo "Expected output directory not found: $BUILD_OUTPUT"
    exit 1
fi
