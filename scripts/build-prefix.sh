#!/usr/bin/env bash

# Build WeMod Prefix locally.
# Usage: ./scripts/build-prefix.sh
# Output: ./wemod_prefix.zip

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WINEPREFIX="$REPO_ROOT/wemod_prefix"
ARCHIVE="$REPO_ROOT/wemod_prefix.zip"

echo "========================================="
echo "Building WeMod Prefix"
echo "========================================="

# --- Dependency checks ---
if ! command -v wine &>/dev/null; then
    echo "❌ wine not found. Please install wine via your package manager."
    exit 1
fi
if ! command -v winetricks &>/dev/null; then
    echo "❌ winetricks not found. Please install winetricks via your package manager."
    exit 1
fi
if ! command -v zip &>/dev/null; then
    echo "❌ zip not found. Please install zip via your package manager."
    exit 1
fi
if ! command -v unzip &>/dev/null; then
    echo "❌ unzip not found. Please install unzip via your package manager."
    exit 1
fi

WINE_VERSION=$(wine --version)
echo "Wine: $WINE_VERSION"
echo ""

# --- Clean old prefix ---
if [[ -d "$WINEPREFIX" ]]; then
    echo "⚠️  Removing existing prefix..."
    rm -rf "$WINEPREFIX"
fi
if [[ -f "$ARCHIVE" ]]; then
    rm -f "$ARCHIVE"
fi

# --- Build prefix ---
export WINEPREFIX
export WINEARCH=win64
export WINEDEBUG=-all

echo "📥 Installing corefonts..."
winetricks -q corefonts
wineserver --wait 2>/dev/null || true
echo "✅ corefonts done"

echo "📥 Installing dotnet48..."
winetricks -q dotnet48
wineserver --wait 2>/dev/null || true
echo "✅ dotnet48 done"

# --- Verify ---
FONT_COUNT=$(ls -1 "$WINEPREFIX/drive_c/windows/Fonts/" 2>/dev/null | wc -l)
echo ""
echo "Fonts installed: $FONT_COUNT"

# --- Archive ---
echo ""
echo "📦 Creating archive..."
cd "$WINEPREFIX"
# Archive only required prefix data. Do NOT archive everything, because
# dosdevices/z: can point to / and explode archive size/memory usage.
zip -6 -y -r "$ARCHIVE" \
    drive_c \
    system.reg \
    user.reg \
    userdef.reg \
    dosdevices \
    -x "drive_c/users/*/Temp/*" \
       "drive_c/windows/temp/*" \
       "drive_c/windows/Installer/\$PatchCache\$/*" \
       "drive_c/windows/SoftwareDistribution/Download/*" \
       "drive_c/windows/WinSxS/Temp/*" \
       "drive_c/*.log" \
       "drive_c/windows/*.log" \
       "drive_c/windows/panther/*" \
    -q
cd "$REPO_ROOT"

# Sanity check: if c: got dereferenced, the archive contains dosdevices/c:/...
# which means drive_c content was added multiple times.
if unzip -l "$ARCHIVE" | grep -q "dosdevices/c:/"; then
    echo "❌ Archive sanity check failed: dosdevices/c: was dereferenced."
    echo "   This would duplicate drive_c and massively increase archive size."
    exit 1
fi

ARCHIVE_SIZE=$(du -h "$ARCHIVE" | cut -f1)
PREFIX_SIZE=$(du -sh "$WINEPREFIX" | cut -f1)
echo "✅ $ARCHIVE ($ARCHIVE_SIZE)"
echo "   Prefix size: $PREFIX_SIZE"

echo ""
echo "========================================="
echo "✅ Build complete!"
echo "========================================="
echo ""
echo "Next step: publish the release"
echo "  ./scripts/release.sh"
echo ""
