#!/bin/bash
# Mod packing utility for BG3, ported from ShinyHobo's Windows batch script
# Creates a PAK file with info.json metadata, packaged in a zip

set -e

echo "Welcome to the BG3 mod packing utility (shell port of ShinyHobo's script)"
echo "Please ensure your workspace root directory is the same name as your mod."

# Get the mod directory (first argument, or current directory)
MODDIR="${1:-.}"
MODDIR="$(cd "$MODDIR" && pwd)"

# Get pak name from directory name
PAKNAME="$(basename "$MODDIR")"

echo "Mod directory: $MODDIR"
echo "Pak name: $PAKNAME"

# Find meta.lsx
META="$MODDIR/Mods/$PAKNAME/meta.lsx"

if [ ! -f "$META" ]; then
    echo "Error: meta.lsx not found at $META"
    exit 1
fi

echo "Reading metadata from: $META"

# Extract values from meta.lsx using grep and sed
# Format: <attribute id="Folder" type="LSString" value="MyRomanceGuessWho"/>
extract_attribute() {
    local attr_id="$1"
    grep -o "<attribute id=\"$attr_id\"[^>]*value=\"[^\"]*\"" "$META" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'
}

FOLDERVALUE=$(extract_attribute "Folder")
UUIDVALUE=$(extract_attribute "UUID")
NAMEVALUE=$(extract_attribute "Name")
VERSION=$(extract_attribute "Version64")

echo "Folder: $FOLDERVALUE"
echo "UUID: $UUIDVALUE"
echo "Name: $NAMEVALUE"
echo "Version: $VERSION"

# Validate folder matches pak name
if [ "$FOLDERVALUE" != "$PAKNAME" ]; then
    echo "Error: Input folder ($PAKNAME) is not the same name as the folder name used in meta.lsx ($FOLDERVALUE)."
    exit 1
fi

# Create temp directory
TEMPDIR="$MODDIR/../temp"
mkdir -p "$TEMPDIR"

PAKPATH="$TEMPDIR/$PAKNAME.pak"

# Check for divine in PATH or current directory
DIVINE=""
if command -v divine &> /dev/null; then
    DIVINE="divine"
elif command -v divine.exe &> /dev/null; then
    DIVINE="divine.exe"
elif [ -f "./divine.exe" ]; then
    DIVINE="./divine.exe"
elif [ -f "./divine" ]; then
    DIVINE="./divine"
elif [ -f "./lslib/divine.exe" ]; then
    DIVINE="./lslib/divine.exe"
else
    echo "Error: divine executable not found. Please ensure LSLib's divine is in PATH or current directory."
    exit 1
fi

echo "Using divine: $DIVINE"

# Create mod pack
echo "Creating PAK file..."
"$DIVINE" -g "bg3" --action "create-package" --source "$MODDIR" --destination "$PAKPATH" -l "all"

if [ ! -f "$PAKPATH" ]; then
    echo "Error: Failed to create PAK file"
    exit 1
fi

# Calculate MD5
if command -v md5sum &> /dev/null; then
    MD5=$(md5sum "$PAKPATH" | awk '{print $1}')
elif command -v md5 &> /dev/null; then
    MD5=$(md5 -q "$PAKPATH")
elif command -v certutil &> /dev/null; then
    # Windows fallback
    MD5=$(certutil -hashfile "$PAKPATH" MD5 | grep -v ":" | tr -d '[:space:]')
else
    echo "Warning: Could not calculate MD5 (no md5sum, md5, or certutil found)"
    MD5="unknown"
fi

echo "MD5: $MD5"

# Create info.json
JSONPATH="$TEMPDIR/info.json"
cat > "$JSONPATH" << EOF
{
    "mods": [
        {
            "modName": "$NAMEVALUE",
            "UUID": "$UUIDVALUE",
            "folderName": "$PAKNAME",
            "version": "$VERSION",
            "MD5": "$MD5"
        }
    ]
}
EOF

echo "Created info.json"

# Create zip
ZIPPATH="$MODDIR/../$PAKNAME.zip"
echo "Creating zip archive..."

if command -v zip &> /dev/null; then
    (cd "$TEMPDIR" && zip -r "$ZIPPATH" .)
elif command -v powershell &> /dev/null; then
    powershell -Command "Compress-Archive -Force '$TEMPDIR/*' '$ZIPPATH'"
elif command -v 7z &> /dev/null; then
    7z a "$ZIPPATH" "$TEMPDIR/*"
else
    echo "Warning: No zip utility found. PAK and info.json are in: $TEMPDIR"
    echo "All done! (without zip)"
    exit 0
fi

# Clean up temp directory
rm -rf "$TEMPDIR"

echo ""
echo "All done!"
echo "Output: $ZIPPATH"
