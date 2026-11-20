#!/bin/bash
# Build an iPhone/iPad *UI PREVIEW ONLY* IPA; no game engine or game files.
# Run from repository root: bash ios-preview/build_preview_ipa.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"
mkdir -p Build

for tool in xcodegen xcodebuild zip; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Missing: $tool" >&2
        exit 1
    fi
done

echo "[1/3] Generating standalone Xcode project..."
xcodegen generate --spec project.yml > Build/xcodegen.log 2>&1 || {
    tail -n 40 Build/xcodegen.log
    exit 1
}

echo "[2/3] Building unsigned iPhone app..."
if ! xcodebuild \
    -project AMMARYTGTAUIPreview.xcodeproj \
    -scheme AMMARYTGTAUIPreview \
    -configuration Release \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$DIR/Build/DerivedData" \
    CODE_SIGNING_ALLOWED=NO \
    build > Build/xcodebuild.log 2>&1; then
    echo "Build failed. Last 50 lines of Build/xcodebuild.log:" >&2
    tail -n 50 Build/xcodebuild.log >&2
    exit 1
fi

APP="$DIR/Build/DerivedData/Build/Products/Release-iphoneos/AMMARYTGTAUIPreview.app"
[ -d "$APP" ] || { echo "Built .app not found: $APP" >&2; exit 1; }

echo "[3/3] Packaging IPA for signing with your own Apple team..."
STAGE="$DIR/Build/Package"
rm -rf "$STAGE"
mkdir -p "$STAGE/Payload"
ditto "$APP" "$STAGE/Payload/AMMARYTGTAUIPreview.app"

IPA="$DIR/Build/AMMAR-YT-GTA-V-Preview.ipa"
rm -f "$IPA"
(cd "$STAGE" && zip -qr "$IPA" Payload)
[ -s "$IPA" ] || { echo "IPA packaging failed" >&2; exit 1; }

echo
echo "SUCCESS: $IPA"
echo "This IPA is a UI-only preview, NOT a working GTA V game."
echo "Sign it using your own compatible Apple profile before installing."
open -R "$IPA" 2>/dev/null || true
