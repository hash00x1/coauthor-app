#!/bin/bash
set -e

###############################################################################
# CoAuthor Build Script
#
# Builds the CoAuthor standalone application with the CoAuthor extension
# pre-installed via .vsix bundling.
#
# Usage:
#   ./scripts/build-coauthor.sh [platform] [arch]
#
# Examples:
#   ./scripts/build-coauthor.sh                    # Current platform/arch
#   ./scripts/build-coauthor.sh darwin arm64       # macOS Apple Silicon
#   ./scripts/build-coauthor.sh linux x64          # Linux x64
###############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect platform and architecture
PLATFORM="${1:-$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/darwin/darwin/')}"
ARCH="${2:-$(uname -m | sed 's/x86_64/x64/' | sed 's/aarch64/arm64/' | sed 's/arm64/arm64/')}"

case "$PLATFORM" in
  darwin) PLATFORM="darwin" ;;
  linux)  PLATFORM="linux" ;;
  msys*|mingw*|cygwin*|windows) PLATFORM="win32" ;;
esac

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         CoAuthor Application Builder                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Platform:${NC} $PLATFORM"
echo -e "${GREEN}Architecture:${NC} $ARCH"
echo ""

# Check prerequisites
echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js not found${NC}"
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "  ${GREEN}✓${NC} Node.js $NODE_VERSION"

if ! command -v npm &> /dev/null; then
    echo -e "${RED}✗ npm not found${NC}"
    exit 1
fi

NPM_VERSION=$(npm --version)
echo -e "  ${GREEN}✓${NC} npm $NPM_VERSION"

# macOS toolchain sanity (node-gyp/native modules)
if [ "$PLATFORM" = "darwin" ]; then
    echo -e "${YELLOW}  Checking macOS build toolchain (clang)...${NC}"

    if ! command -v xcrun &> /dev/null; then
        echo -e "${RED}✗ xcrun not found (Xcode Command Line Tools missing?)${NC}"
        echo -e "  Run: ${BLUE}xcode-select --install${NC}"
        exit 1
    fi

    XRUN_CLANG="$(xcrun --find clang 2>/dev/null || true)"
    XRUN_CLANGXX="$(xcrun --find clang++ 2>/dev/null || true)"

    if [ -z "$XRUN_CLANG" ] || [ -z "$XRUN_CLANGXX" ]; then
        echo -e "${RED}✗ Unable to locate clang via xcrun${NC}"
        echo -e "  Current developer dir: ${BLUE}$(xcode-select -p 2>/dev/null || echo 'unknown')${NC}"
        echo -e "  Try: ${BLUE}sudo xcode-select -s /Library/Developer/CommandLineTools${NC}"
        exit 1
    fi

    # If CC/CXX are set but point to a non-existent clang path, node-gyp will fail.
    if [ -n "${CC:-}" ] && [ ! -x "${CC:-}" ]; then
        echo -e "  ${YELLOW}CC is set but invalid:${NC} ${CC}"
        export CC="$XRUN_CLANG"
        echo -e "  ${GREEN}✓${NC} Using clang from xcrun for CC: ${CC}"
    fi

    if [ -n "${CXX:-}" ] && [ ! -x "${CXX:-}" ]; then
        echo -e "  ${YELLOW}CXX is set but invalid:${NC} ${CXX}"
        export CXX="$XRUN_CLANGXX"
        echo -e "  ${GREEN}✓${NC} Using clang++ from xcrun for CXX: ${CXX}"
    fi

    # If unset, prefer xcrun's toolchain (safe default across Xcode/CLT installs)
    if [ -z "${CC:-}" ]; then
        export CC="$XRUN_CLANG"
    fi
    if [ -z "${CXX:-}" ]; then
        export CXX="$XRUN_CLANGXX"
    fi

    # Set SDKROOT so the compiler can find standard headers like <unordered_set>
    export SDKROOT="$(xcrun --show-sdk-path)"

    # Ensure a sane PATH so we don't get "spawnSync /bin/sh ENOENT"
    # This ensures standard macOS system paths are present.
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH"

    echo -e "  ${GREEN}✓${NC} macOS toolchain: CC=${CC}"
    echo -e "  ${GREEN}✓${NC} macOS SDKROOT: ${SDKROOT}"
fi

# Check if .vsix exists
if [ ! -f "resources/app/extensions-vsix/coauthor-extension.vsix" ]; then
    echo -e "${RED}✗ CoAuthor extension .vsix not found!${NC}"
    echo -e "  Expected: ${YELLOW}resources/app/extensions-vsix/coauthor-extension.vsix${NC}"
    echo ""
    echo "  Please copy your extension .vsix to this location:"
    echo "  ${BLUE}cp /path/to/coauthor-extension.vsix resources/app/extensions-vsix/${NC}"
    exit 1
fi

VSIX_SIZE=$(du -h resources/app/extensions-vsix/coauthor-extension.vsix | cut -f1)
echo -e "  ${GREEN}✓${NC} CoAuthor extension found ($VSIX_SIZE)"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}  Installing dependencies...${NC}"

    # Run install with toolchain variables explicitly passed
    # This avoids "poisoning" the local .npmrc with npm config set
    CC="$CC" CXX="$CXX" SDKROOT="$SDKROOT" npm install
fi

echo ""

# Clean previous build
echo -e "${YELLOW}[2/6] Cleaning previous build artifacts...${NC}"
rm -rf out-build out-vscode out-vscode-min .build
rm -rf "../VSCode-${PLATFORM}-${ARCH}"
echo -e "  ${GREEN}✓${NC} Cleaned"
echo ""

# Compile TypeScript
echo -e "${YELLOW}[3/6] Compiling application source...${NC}"
echo -e "  ${BLUE}This may take 3-5 minutes...${NC}"
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js compile-build-without-mangling
echo -e "  ${GREEN}✓${NC} Compilation complete"
echo ""

# Compile extensions
echo -e "${YELLOW}[4/6] Building extensions...${NC}"
echo -e "  ${BLUE}Building writer-friendly extensions only...${NC}"
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js \
    clean-extensions-build \
    compile-non-native-extensions-build \
    compile-extension-media-build
echo -e "  ${GREEN}✓${NC} Extensions built"
echo ""

# Create required directories (must exist before bundling/packaging)
echo -e "${YELLOW}[4.5/6] Creating required directories...${NC}"
mkdir -p out-build/vs/workbench/services/extensionManagement/common/media
mkdir -p .build/telemetry
mkdir -p ".build/policies/${PLATFORM}"
echo -e "  ${GREEN}✓${NC} Created"
echo ""

# Bundle application
echo -e "${YELLOW}[5/6] Bundling application...${NC}"
echo -e "  ${BLUE}This may take 2-3 minutes...${NC}"
NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js bundle-vscode
echo -e "  ${GREEN}✓${NC} Bundling complete"
echo ""

# Package with Electron
echo -e "${YELLOW}[6/6] Packaging with Electron...${NC}"
echo -e "  ${BLUE}This may take 2-3 minutes...${NC}"
echo -e "  ${BLUE}Creating ../VSCode-${PLATFORM}-${ARCH}/${NC}"

NODE_OPTIONS=--max-old-space-size=6144 \
  node ./node_modules/gulp/bin/gulp.js \
    "vscode-${PLATFORM}-${ARCH}-ci"

echo -e "  ${GREEN}✓${NC} Packaging complete"
echo ""

# Success message
OUTPUT_DIR="../VSCode-${PLATFORM}-${ARCH}"

if [ "$PLATFORM" = "darwin" ]; then
    APP_PATH="${OUTPUT_DIR}/CoAuthor.app"
elif [ "$PLATFORM" = "win32" ]; then
    APP_PATH="${OUTPUT_DIR}/CoAuthor.exe"
else
    APP_PATH="${OUTPUT_DIR}/coauthor"
fi

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Build Successful! 🎉                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Application built at:${NC}"
echo -e "  ${BLUE}${APP_PATH}${NC}"
echo ""
echo -e "${GREEN}Extension included:${NC}"
echo -e "  ${BLUE}resources/app/extensions-vsix/coauthor-extension.vsix${NC}"
echo -e "  ${YELLOW}(will auto-install on first launch)${NC}"
echo ""
echo -e "${GREEN}Build size:${NC}"
du -sh "$OUTPUT_DIR" | cut -f1 | xargs echo "  "
echo ""
echo -e "${YELLOW}To run CoAuthor:${NC}"

if [ "$PLATFORM" = "darwin" ]; then
    echo -e "  ${BLUE}open '${APP_PATH}'${NC}"
elif [ "$PLATFORM" = "win32" ]; then
    echo -e "  ${BLUE}${APP_PATH}${NC}"
else
    echo -e "  ${BLUE}${APP_PATH}/bin/coauthor${NC}"
fi

echo ""
echo -e "${YELLOW}For more information, see BUILD_COAUTHOR.md${NC}"




