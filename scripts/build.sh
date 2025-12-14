#!/bin/bash
# Build script for Campfire Guess Who? mod
# Requires LSLib's divine tool to be in PATH

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOD_DIR="$(dirname "$SCRIPT_DIR")"
MOD_NAME="MyRomanceGuessWho"
OUTPUT_DIR="${MOD_DIR}/build"

echo "Building ${MOD_NAME}..."

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Check for divine
if ! command -v divine &> /dev/null; then
    echo "Error: LSLib's 'divine' tool not found in PATH"
    echo ""
    echo "Please install LSLib from: https://github.com/Norbyte/lslib/releases"
    echo "And add the directory containing divine.exe to your PATH"
    echo ""
    echo "Alternatively, use BG3 Modder's Multitool to pack the mod manually."
    exit 1
fi

# Create the PAK file
divine -g bg3 \
    -a create-package \
    -s "${MOD_DIR}" \
    -d "${OUTPUT_DIR}/${MOD_NAME}.pak" \
    -c lz4

echo ""
echo "Success! PAK file created at: ${OUTPUT_DIR}/${MOD_NAME}.pak"
echo ""
echo "To install, copy the .pak file to:"
echo "  Windows: %LocalAppData%\\Larian Studios\\Baldur's Gate 3\\Mods"
echo "  Mac: ~/Documents/Larian Studios/Baldur's Gate 3/Mods"
