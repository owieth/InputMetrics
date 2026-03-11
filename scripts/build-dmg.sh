#!/usr/bin/env bash
set -euo pipefail

SCHEME="InputMetrics"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
ARCHIVE_PATH="${BUILD_DIR}/${SCHEME}.xcarchive"
EXPORT_DIR="${BUILD_DIR}/export"
DMG_DIR="${BUILD_DIR}/dmg"
KEYCHAIN_PROFILE="${NOTARYTOOL_PROFILE:-InputMetrics}"

# Extract version from Info.plist
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" \
  "${PROJECT_DIR}/InputMetrics/InputMetrics/Info.plist")
DMG_NAME="${SCHEME}-${VERSION}.dmg"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}"

echo "==> Building ${SCHEME} v${VERSION}"

# Clean previous build
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Create export options plist for Developer ID
EXPORT_OPTIONS="${BUILD_DIR}/ExportOptions.plist"
cat > "${EXPORT_OPTIONS}" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
PLIST

# Archive
echo "==> Archiving..."
xcodebuild archive \
  -project "${PROJECT_DIR}/InputMetrics.xcodeproj" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -archivePath "${ARCHIVE_PATH}" \
  -quiet

# Export
echo "==> Exporting with Developer ID signing..."
xcodebuild -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_DIR}" \
  -exportOptionsPlist "${EXPORT_OPTIONS}" \
  -quiet

APP_PATH="${EXPORT_DIR}/${SCHEME}.app"
if [ ! -d "${APP_PATH}" ]; then
  echo "Error: ${APP_PATH} not found" >&2
  exit 1
fi

# Create DMG
echo "==> Creating DMG..."
mkdir -p "${DMG_DIR}"
cp -R "${APP_PATH}" "${DMG_DIR}/"
ln -s /Applications "${DMG_DIR}/Applications"

hdiutil create \
  -volname "${SCHEME}" \
  -srcfolder "${DMG_DIR}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}"

# Notarize
echo "==> Notarizing..."
xcrun notarytool submit "${DMG_PATH}" \
  --keychain-profile "${KEYCHAIN_PROFILE}" \
  --wait

# Staple
echo "==> Stapling..."
xcrun stapler staple "${DMG_PATH}"

# Verify
echo "==> Verifying..."
spctl --assess --type open --context context:primary-signature -v "${DMG_PATH}"

echo ""
echo "Done: ${DMG_PATH}"
