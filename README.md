# Messages for Android — a simple Mac app

A small native Mac app that shows your Android phone's texts on your Mac,
like iMessage does for iPhone. It wraps **Google Messages for web** in a
real Mac window with its own Dock icon — your phone still does the actual
sending and receiving.

## What it is (and isn't)

- **It is:** an Objective-C + WKWebView wrapper around https://messages.google.com/web
  (rewritten from Swift after the first version hit a Swift 6.3 compiler /
  macOS 27 SDK mismatch — this version builds with plain `clang`, no Swift
  toolchain needed)
- **It isn't:** iMessage. Apple keeps iMessage iPhone-only, so this shows your
  Android SMS/RCS messages (Google Messages) on the Mac instead.
- Your phone must be **on and online** for messages to flow. If the phone is
  off or offline, the Mac app shows what's already loaded but can't send new
  ones.
- Pairing is stored in the app, so you only scan the QR code once (tick
  "Remember this computer" when pairing).

## Build it on your Mac

You need the Xcode Command Line Tools only — no full Xcode, no developer
account, no Homebrew, and no Swift toolchain (the app is Objective-C,
compiled with `clang`).

1. Copy this whole folder to your Mac (e.g. `~/Downloads/android-messages-mac-app`).
2. Open **Terminal** on the Mac and run:
   ```bash
   cd ~/Downloads/android-messages-mac-app
   chmod +x build.sh
   ./build.sh
   ```
   If it says `clang` is missing, run `xcode-select --install` first,
   then run `./build.sh` again.
3. Drag **"Messages for Android.app"** into **Applications**.
4. Double-click it to open. The first time macOS may ask "Are you sure you
   want to open it?" because it isn't from the App Store — click **Open**.
   (It's ad-hoc signed by the build script; it's your own code, built on
   your own Mac.)

## Pair it with your phone

1. On your S22 Ultra, open **Google Messages** and make sure it's your
   default texting app (Settings → Apps → Default apps → SMS app →
   Google Messages, if it isn't already).
2. In Google Messages, tap your profile picture → **Device pairing** →
   **QR code scanner**.
3. In the Mac app, the pairing page shows a QR code — scan it with your
   phone, and tick **"Remember this computer"**.
4. Your conversations appear. New texts arrive while the app is open;
   reply from the Mac and it sends from your phone number.

## Known limits (honest ones)

- **Notifications:** web notifications from Google Messages may not always
  come through inside this wrapper the way they do in Chrome. Keep the app
  open and check it; if notifications matter a lot, use
  messages.google.com/web in Chrome instead, which notifies reliably.
- **Calls:** text only — no phone calls through the Mac.
- **One phone:** it pairs with the phone you scanned. To switch phones,
  unpair in Google Messages → Device pairing on the old phone and re-pair.

## The zero-code alternative

If you ever just want the same thing without building anything: on macOS
Sonoma or newer, open Safari → messages.google.com/web → **File → Add to
Dock**. That makes a web app in your Dock in about a minute, with the same
pairing. This little app is the same idea, just as a real app bundle with
its own icon.

## Files

- `Sources/main.m` — the whole app: window, web view, pairing persistence,
  Reload menu
- `Info.plist` — app name, bundle ID (`com.deepu.androidmessages`), icon
- `build.sh` — compiles with `clang`, builds the `.app`, makes the icon
- `assets/icon-1024.png` — app icon source
