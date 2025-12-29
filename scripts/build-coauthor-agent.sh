#!/bin/bash
set -e

# Pre-build script for coauthor-agent extension
# This script builds the extension in complete isolation to prevent dependency conflicts
# with the main build system (specifically streamx version conflicts)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENT_DIR="$PROJECT_ROOT/extensions/coauthor-agent"
WEBVIEW_DIR="$AGENT_DIR/webview-ui"

echo "=================================================="
echo "Pre-building coauthor-agent extension (isolated)"
echo "=================================================="

# Check if agent directory exists
if [ ! -d "$AGENT_DIR" ]; then
    echo "ERROR: coauthor-agent directory not found at $AGENT_DIR"
    exit 1
fi

# Build webview-ui first
echo ""
echo "[1/4] Installing webview-ui dependencies..."
cd "$WEBVIEW_DIR"
if [ ! -d "node_modules" ]; then
    npm install
else
    echo "  → node_modules exists, skipping install"
fi

echo ""
echo "[2/4] Installing coauthor-agent dependencies..."
cd "$AGENT_DIR"
if [ ! -d "node_modules" ]; then
    npm install
else
    echo "  → node_modules exists, skipping install"
fi

echo ""
echo "[3/4] Building coauthor-agent extension..."
npm run package

echo ""
echo "[4/4] Verifying build output..."
if [ -f "$AGENT_DIR/dist/extension.js" ]; then
    echo "  ✓ dist/extension.js exists"
else
    echo "  ✗ ERROR: dist/extension.js not found!"
    exit 1
fi

if [ -d "$AGENT_DIR/webview-ui/build" ] && [ -f "$AGENT_DIR/webview-ui/build/index.html" ]; then
    echo "  ✓ webview-ui/build/ exists"
else
    echo "  ✗ ERROR: webview-ui/build/ not found!"
    exit 1
fi

echo ""
echo "=================================================="
echo "✓ coauthor-agent pre-build completed successfully"
echo "=================================================="
echo ""
echo "The extension is now ready for inclusion in the main build."
echo "Run the main build with: npm run gulp vscode-darwin-arm64"
