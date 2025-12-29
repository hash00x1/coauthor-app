#!/bin/bash
# Patch streamx to be tolerant of streams without .end() method
# This fixes the "this.pipeTo.end is not a function" error when event-stream's
# es.merge() (which lacks .end()) is used in a pipeline with streamx-based streams

STREAMX_FILE="node_modules/streamx/index.js"

if [ ! -f "$STREAMX_FILE" ]; then
    echo "⚠️  Warning: streamx not found at $STREAMX_FILE - skipping patch"
    exit 0
fi

# Check if already patched
if grep -q "typeof this.pipeTo.end === 'function'" "$STREAMX_FILE"; then
    echo "✓ streamx already patched"
    exit 0
fi

# Apply patch
echo "🔧 Patching streamx for event-stream compatibility..."
sed -i.bak 's/if (this\.pipeTo !== null) this\.pipeTo\.end()/if (this.pipeTo !== null \&\& typeof this.pipeTo.end === '\''function'\'') this.pipeTo.end()/' "$STREAMX_FILE"

if grep -q "typeof this.pipeTo.end === 'function'" "$STREAMX_FILE"; then
    echo "✓ streamx patched successfully"
    rm -f "$STREAMX_FILE.bak"
else
    echo "✗ Failed to patch streamx"
    mv "$STREAMX_FILE.bak" "$STREAMX_FILE" 2>/dev/null
    exit 1
fi
