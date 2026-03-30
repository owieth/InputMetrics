#!/bin/bash
# Generates appcast.xml for Sparkle auto-updates.
# Usage: ./scripts/generate-appcast.sh <version> <dmg_path>
# Requires: Sparkle's generate_appcast tool (bundled with Sparkle SPM package)
# The output appcast.xml is written to docs/appcast.xml for GitHub Pages hosting.

set -euo pipefail

VERSION="${1:?Usage: $0 <version> <dmg_path>}"
DMG_PATH="${2:?Usage: $0 <version> <dmg_path>}"
REPO="owieth/InputMetrics"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${VERSION}/InputMetrics-v${VERSION}.dmg"
APPCAST_PATH="docs/appcast.xml"

DMG_SIZE=$(stat -f%z "$DMG_PATH")
RELEASE_DATE=$(date -u "+%a, %d %b %Y %H:%M:%S +0000")

cat > "$APPCAST_PATH" << EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>InputMetrics</title>
    <link>https://owieth.github.io/InputMetrics/appcast.xml</link>
    <description>InputMetrics update feed</description>
    <language>en</language>
    <item>
      <title>Version ${VERSION}</title>
      <pubDate>${RELEASE_DATE}</pubDate>
      <sparkle:version>${VERSION}</sparkle:version>
      <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>
      <sparkle:releaseNotesLink>https://github.com/${REPO}/releases/tag/v${VERSION}</sparkle:releaseNotesLink>
      <enclosure
        url="${DOWNLOAD_URL}"
        length="${DMG_SIZE}"
        type="application/octet-stream"
        sparkle:edSignature="PLACEHOLDER_SIGNATURE"
      />
    </item>
  </channel>
</rss>
EOF

echo "Generated $APPCAST_PATH for v${VERSION}"
echo "NOTE: Replace PLACEHOLDER_SIGNATURE with the actual EdDSA signature."
echo "      Run: sign_update \"$DMG_PATH\" with your Sparkle private key."
