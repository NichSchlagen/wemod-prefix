#!/usr/bin/env bash

# Publish wemod_prefix.zip as the "latest" GitHub release.
# Usage: ./scripts/release.sh
# Requires: gh CLI (https://cli.github.com), logged in via "gh auth login"

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE="$REPO_ROOT/wemod_prefix.zip"
REPO="NichSchlagen/wemod-prefix"

# --- Checks ---
if ! command -v gh &>/dev/null; then
    echo "❌ gh CLI not found. Install:"
    echo "   https://cli.github.com"
    exit 1
fi

if [[ ! -f "$ARCHIVE" ]]; then
    echo "❌ wemod_prefix.zip not found. Build it first:"
    echo "   ./scripts/build-prefix.sh"
    exit 1
fi

ARCHIVE_SIZE=$(du -h "$ARCHIVE" | cut -f1)
WINE_VERSION=$(wine --version 2>/dev/null || echo "unknown")
echo "Archive : $ARCHIVE ($ARCHIVE_SIZE)"
echo "Wine    : $WINE_VERSION"
echo "Repo    : $REPO"
echo ""

# --- Delete existing "latest" release if present ---
if gh release view latest --repo "$REPO" &>/dev/null; then
    echo "⚠️  Deleting existing 'latest' release..."
    gh release delete latest --repo "$REPO" --yes
fi

# --- Create new release ---
echo "🚀 Creating 'latest' release..."
gh release create latest \
    --repo "$REPO" \
    --title "Latest WeMod Prefix ($WINE_VERSION)" \
    --notes "Pre-built WeMod prefix with corefonts + dotnet48.

Built with: $WINE_VERSION
Works with: Wine 9.0+

**Installation via wemod-launcher:**
\`\`\`bash
./wemod prefix download
\`\`\`" \
    "$ARCHIVE"

echo ""
echo "✅ Release published!"
echo "   https://github.com/$REPO/releases/latest"
