#!/bin/bash
# Build "Messages for Android" (.app) on your Mac.
# Needs only the Xcode Command Line Tools (clang). No Swift, no Xcode
# project, no Apple Developer account, no Homebrew.
set -e
cd "$(dirname "$0")"

if ! command -v clang >/dev/null 2>&1; then
  echo "clang not found. Install the Command Line Tools first:"
  echo "  xcode-select --install"
  echo "Then run this script again."
  exit 1
fi

APP="Messages for Android.app"
BIN="$APP/Contents/MacOS/AndroidMessages"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "Compiling…"

# The macOS 27 SDK needs newer tools than the Command Line Tools
# sometimes ship: its .tbd files mention arm64e.x1, which an old
# linker rejects. So: prefer full Xcode's clang when present, and
# otherwise pick the newest SDK whose libSystem.tbd the linker can
# actually read (skipping any SDK that mentions arm64e.x1).
if [ -x /Applications/Xcode.app/Contents/Developer/usr/bin/clang ]; then
  CC=/Applications/Xcode.app/Contents/Developer/usr/bin/clang
  echo "Using Xcode toolchain."
else
  CC=clang
fi
SDKROOT=""
for sdk in /Library/Developer/CommandLineTools/SDKs/MacOSX*.sdk; do
  [ -d "$sdk" ] || continue
  if ! grep -q "arm64e.x1" "$sdk/usr/lib/libSystem.tbd" 2>/dev/null; then
    SDKROOT="$sdk"
  fi
done
if [ -n "$SDKROOT" ]; then
  echo "Using SDK: $SDKROOT"
  SDKFLAGS="-isysroot $SDKROOT"
else
  echo "No older compatible SDK found — trying the default SDK."
  echo "If this fails, update the Command Line Tools (xcode-select --install)"
  echo "or install Xcode from the App Store."
  SDKFLAGS=""
fi

$CC -O2 $SDKFLAGS -mmacosx-version-min=13.0 \
  -framework AppKit -framework WebKit \
  -o "$BIN" Sources/main.m

cp Info.plist "$APP/Contents/Info.plist"

# App icon (assets/icon-1024.png -> AppIcon.icns), if iconutil is available.
if command -v iconutil >/dev/null 2>&1 && [ -f assets/icon-1024.png ]; then
  echo "Making app icon…"
  rm -rf /tmp/AppIcon.iconset
  mkdir -p /tmp/AppIcon.iconset
  sips -z 16 16     assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_16x16.png >/dev/null
  sips -z 32 32     assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_16x16@2x.png >/dev/null
  sips -z 32 32     assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_32x32.png >/dev/null
  sips -z 64 64     assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_32x32@2x.png >/dev/null
  sips -z 128 128   assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_128x128.png >/dev/null
  sips -z 256 256   assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_128x128@2x.png >/dev/null
  sips -z 256 256   assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_256x256.png >/dev/null
  sips -z 512 512   assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_256x256@2x.png >/dev/null
  sips -z 512 512   assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_512x512.png >/dev/null
  sips -z 1024 1024 assets/icon-1024.png --out /tmp/AppIcon.iconset/icon_512x512@2x.png >/dev/null
  iconutil -c icns /tmp/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
  rm -rf /tmp/AppIcon.iconset
else
  echo "Skipping icon (iconutil or assets/icon-1024.png missing) — the app still works."
fi

# Ad-hoc sign so macOS runs it without a developer certificate.
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo ""
echo "Built: $APP"
echo "Drag it into Applications, then double-click to open."
echo "First launch: pair it with your phone (see README.md)."
