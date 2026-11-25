# Post-Installation Guide - Omalauncher

This guide covers what to do after installing Omalauncher on your device or setting up your development environment.

## Table of Contents

1. [After Installing the App on a Device](#1-after-installing-the-app-on-a-device)
2. [After Setting Up Development Environment](#2-after-setting-up-development-environment)
3. [After Building from Source](#3-after-building-from-source)
4. [After Updating Omalauncher](#4-after-updating-omalauncher)
5. [Post-Installation Scripts](#5-post-installation-scripts)

---

## 1. After Installing the App on a Device

### 1.1 First Launch

When you first launch Omalauncher:

1. **Set as Default Launcher**
   - Android will prompt you to set Omalauncher as your default home app
   - Tap "Set as default" or "Always"
   - If you missed it: Settings → Apps → Default apps → Home app → Omalauncher

2. **Grant Permissions**
   Omalauncher may request these permissions:
   - **Storage**: For accessing files (optional, only if you use Files feature)
   - **Microphone**: For voice input (optional, only if you use Voice feature)
   - **Location**: For location-based widgets (optional)
   - **Notifications**: For notification access (optional)

3. **Initial Setup**
   - The first launch shows a welcome screen
   - Tap through the introduction pages
   - Select your preferred language

### 1.2 Recommended First Steps

#### Enable Developer Options
```
Settings → About phone → Tap "Build number" 7 times
Settings → Developer options → Enable:
- USB debugging (for ADB access)
- Stay awake (while charging)
- OEM unlocking (if you plan to root)
```

#### Connect to ADB
```bash
# Connect your device via USB
adb devices

# Verify connection
adb shell pm list packages | grep omalauncher
```

### 1.3 Configuring Omalauncher

#### Home Screen Setup
1. **Add Widgets**
   - Long-press on home screen → "Add widget"
   - Browse available widgets
   - Tap to add a widget to your home screen

2. **Customize App Drawer**
   - The app drawer is a widget (`drawer.owl`)
   - Long-press → Edit → Modify drawer settings

3. **Change Theme**
   - Settings → Appearance → Theme
   - Select from 22+ Omarchy themes
   - Or add custom themes from omarchy.org

4. **Add Home Pages**
   - Swipe left/right to see existing pages
   - Settings → Home → Add page
   - Or swipe to the rightmost page and tap "+"

#### Linux Setup (Optional)

To enable Linux functionality:

1. **Install Linux**
   - Settings → Linux → Install
   - This downloads Arch Linux ARM (~800MB)
   - Takes 5-10 minutes depending on your connection

2. **Set Up Pacman**
   - After installation, open a terminal widget
   - Run: `pacman -Syu` (update packages)

3. **Install Coding Agents**
   - Settings → Linux → Coding agents
   - Select and install your preferred agent (Claude, Copilot, etc.)

4. **Test Linux**
   - Open terminal widget
   - Run: `echo "Hello from Linux"`
   - Or: `neofetch` (if installed)

### 1.4 Using the Bar

The bar at the bottom is your primary input:

- **Open apps**: Type app name → Enter
- **Search**: Type query → Enter (goes to coding agent)
- **Voice input**: Tap microphone or hold to speak
- **App list**: Focus the bar (tap it) to see all apps
- **Navigation**: Arrow keys to move, Enter to select

### 1.5 Installing Widgets from Store

1. Open the widget store:
   - Long-press home screen → "Add widget" → "Store"
   - Or: Settings → Store

2. Browse widgets by category

3. Tap a widget to see:
   - Description
   - Preview images
   - What it runs (commands)
   - What it installs (packages)

4. Tap "Install" to add to your home screen

---

## 2. After Setting Up Development Environment

### 2.1 Verify Setup

```bash
# Check Java version
java -version
# Should be 21+

# Check Android SDK
sdkmanager --list | grep "Android SDK"

# Check NDK
sdkmanager --list | grep "NDK"

# Check Gradle
./gradlew --version
```

### 2.2 Clone and Prepare Repository

```bash
# Clone the repository
git clone https://github.com/soli-rsa/omalauncher.git
cd omalauncher

# Fetch proot (required for Linux functionality)
./scripts/fetch-proot.sh

# Verify proot is in place
ls -la app/src/main/jniLibs/arm64-v8a/libproot.so
```

### 2.3 Configure local.properties

If you have Android SDK/NDK in non-standard locations:

```bash
# Create or edit local.properties
cat > local.properties << EOF
sdk.dir=/path/to/android/sdk
ndk.dir=/path/to/android/ndk
EOF
```

### 2.4 Build and Install

```bash
# Build debug version
./gradlew :app:assembleFossDebug

# Install on connected device
./gradlew :app:installFossDebug

# Or manually install
adb install -r app/build/outputs/apk/foss/debug/app-foss-debug.apk
```

### 2.5 Set Up for Development

#### Configure Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### Install Pre-commit Hooks (Optional)
```bash
# Create pre-commit hook
cat > .git/hooks/pre-commit << 'SCRIPT'
#!/bin/sh
./gradlew :owl:test :app:testFossDebugUnitTest :app:lintFossDebug
SCRIPT
chmod +x .git/hooks/pre-commit
```

---

## 3. After Building from Source

### 3.1 First Debug Build

```bash
# Run all tests
./gradlew :owl:test :app:testFossDebugUnitTest

# Build and install
./gradlew :app:assembleFossDebug :app:installFossDebug

# Verify installation
adb shell pm list packages | grep omalauncher
```

### 3.2 Test Linux Functionality

```bash
# Install Linux on device (via app)
# Or push pre-built rootfs for testing
adb push ArchLinuxARM-aarch64-latest.tar.gz /sdcard/Android/data/dev.omalauncher/files/

# Verify Linux is running
adb shell "run-as dev.omalauncher ls files/arch"
```

### 3.3 Test Widgets

```bash
# Copy test widget to device
adb push test-widget.owl /sdcard/Download/

# Import in Omalauncher
# Long-press → Add widget → Import

# Check widget errors
adb shell "cat /sdcard/Android/data/dev.omalauncher/files/widgets/.errors/test-widget.txt"
```

### 3.4 Run Instrumentation Tests

```bash
# Run all instrumentation tests
./gradlew :app:connectedFossDebugAndroidTest

# Run specific test
./gradlew :app:connectedFossDebugAndroidTest -P android.testInstrumentationRunnerArguments.class=dev.omalauncher.ui.HardcodedTextTest
```

---

## 4. After Updating Omalauncher

### 4.1 For Users (App Update)

1. **Update via Play Store**
   - Open Play Store → My apps & games → Omalauncher → Update

2. **Update via APK**
   - Download latest APK from GitHub releases
   - Install: `adb install -r omalauncher-v1.x.x.apk`

3. **Post-Update Checks**
   - Open Settings → About → Check version
   - Verify Linux still works (if installed)
   - Check widgets are still rendering
   - Test coding agents

### 4.2 For Developers (Code Update)

```bash
# Pull latest changes
git pull origin main

# Rebuild proot if fetch-proot.sh changed
./scripts/fetch-proot.sh

# Clean and rebuild
./gradlew clean :app:assembleFossDebug

# Run tests
./gradlew :owl:test :app:testFossDebugUnitTest

# Install updated version
./gradlew :app:installFossDebug
```

### 4.3 Migration Notes

If the update includes breaking changes:

1. **Check CHANGELOG.md** for migration instructions

2. **Data Migration**
   - Settings are automatically migrated
   - Widgets are preserved
   - Linux rootfs is preserved (unless major version change)

3. **If Issues Occur**
   - Clear app cache: Settings → Apps → Omalauncher → Storage → Clear cache
   - Reinstall Linux: Settings → Linux → Reinstall
   - Reset widgets: Settings → Widgets → Reset all

---

## 5. Post-Installation Scripts

### 5.1 Quick Start Script

Run this after cloning the repository to set up your development environment:

```bash
# Save as scripts/post-install-dev.sh
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Omalauncher Post-Installation Setup ==="
echo ""

# Check Java
echo "Checking Java version..."
java -version 2>&1 | head -1
if ! java -version 2>&1 | grep -q "21\|25"; then
    echo "WARNING: Java 21+ recommended"
fi

# Check Android SDK
echo ""
echo "Checking Android SDK..."
if [ -z "${ANDROID_HOME:-}" ]; then
    echo "ANDROID_HOME not set. Please set it to your Android SDK path."
else
    echo "Android SDK: $ANDROID_HOME"
fi

# Fetch proot
echo ""
echo "Fetching proot (this may take a while)..."
cd "$PROJECT_DIR"
./scripts/fetch-proot.sh

# Build owl.jar
echo ""
echo "Building OWL compiler..."
./gradlew :owl:owlJar

# Run tests
echo ""
echo "Running tests..."
./gradlew :owl:test :app:testFossDebugUnitTest

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Connect an Android device via USB"
echo "2. Enable USB debugging on the device"
echo "3. Run: ./gradlew :app:installFossDebug"
echo ""
```

### 5.2 Device Setup Script

Automate device setup for testing:

```bash
# Save as scripts/setup-device.sh
#!/usr/bin/env bash
set -euo pipefail

SERIAL="${1:--}"  # ADB serial number, optional
APK="${2:-app/build/outputs/apk/foss/debug/app-foss-debug.apk}"

echo "=== Device Setup for Omalauncher Testing ==="
echo ""

ADB_CMD="adb"
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

# Check device is connected
echo "Checking device connection..."
$ADB_CMD devices | grep -q device || { echo "No device connected"; exit 1; }

# Get package name
PKG="dev.omalauncher"

# Uninstall existing version (keeps data)
echo "Uninstalling existing version (keeps data)..."
$ADB_CMD uninstall $PKG 2>/dev/null || true

# Install new version
echo "Installing Omalauncher..."
$ADB_CMD install -r "$APK"

# Wait for app to settle
echo "Waiting for app to initialize..."
sleep 5

# Grant permissions
echo "Granting permissions..."
$ADB_CMD shell pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
$ADB_CMD shell pm grant $PKG android.permission.WRITE_EXTERNAL_STORAGE
$ADB_CMD shell pm grant $PKG android.permission.RECORD_AUDIO

# Set as default launcher
echo "Setting as default launcher..."
$ADB_CMD shell cmd package set-home-activity $PKG/.MainActivity

# Launch app
echo "Launching Omalauncher..."
$ADB_CMD shell am start -n $PKG/.MainActivity

echo ""
echo "=== Device Setup Complete! ==="
echo ""
echo "Omalauncher is now installed and ready for testing."
echo "Open the app on your device to complete first-run setup."
```

### 5.3 Linux Setup Verification Script

Verify Linux subsystem is working correctly:

```bash
# Save as scripts/verify-linux.sh
#!/usr/bin/env bash
set -euo pipefail

SERIAL="${1:--}"
ADB_CMD="adb"
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

PKG="dev.omalauncher"

echo "=== Linux Subsystem Verification ==="
echo ""

# Check if Linux is installed
LINUX_DIR=$($ADB_CMD shell "run-as $PKG ls files/arch" 2>/dev/null | head -1)
if [ -z "$LINUX_DIR" ]; then
    echo "❌ Linux is not installed"
    echo "   Run: Settings → Linux → Install"
    exit 1
fi

echo "✓ Linux rootfs exists"

# Check proot
PROOT_FILE=$($ADB_CMD shell "run-as $PKG ls files/arch/bin/proot" 2>/dev/null)
if [ -z "$PROOT_FILE" ]; then
    echo "❌ proot not found in rootfs"
    exit 1
fi

echo "✓ proot is present"

# Check if Linux process is running
LINUX_PID=$($ADB_CMD shell pidof $PKG | tr -d '\r')
if [ -z "$LINUX_PID" ]; then
    echo "⚠️  Linux service is not running"
    echo "   Try launching a terminal widget or Linux app"
else
    echo "✓ Linux service is running (PID: $LINUX_PID)"
fi

# Test a simple command
echo ""
echo "Testing Linux command execution..."
TEST_OUTPUT=$($ADB_CMD shell "run-as $PKG sh -c 'echo test'" 2>/dev/null | tr -d '\r')
if [ "$TEST_OUTPUT" = "test" ]; then
    echo "✓ Linux command execution works"
else
    echo "⚠️  Linux command execution test failed"
fi

# Check pacman
PACMAN_TEST=$($ADB_CMD shell "run-as $PKG sh -c 'pacman --version'" 2>/dev/null | head -1 | tr -d '\r')
if [[ "$PACMAN_TEST" == *"pacman"* ]]; then
    echo "✓ pacman is available"
else
    echo "⚠️  pacman not found or not working"
fi

echo ""
echo "=== Verification Complete ==="
```

### 5.4 Widget Testing Script

Test widgets on a connected device:

```bash
# Save as scripts/test-widget.sh
#!/usr/bin/env bash
set -euo pipefail

WIDGET_FILE="${1:?Usage: test-widget.sh <widget.owl> [serial]}"
SERIAL="${2:-}"

ADB_CMD="adb"
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

PKG="dev.omalauncher"
WIDGET_NAME=$(basename "$WIDGET_FILE" .owl)

echo "=== Testing Widget: $WIDGET_NAME ==="
echo ""

# Push widget to device
DEVICE_PATH="/sdcard/Download/$WIDGET_NAME.owl"
echo "Pushing widget to device..."
$ADB_CMD push "$WIDGET_FILE" "$DEVICE_PATH"

# Import widget via ADB
echo "Importing widget..."
$ADB_CMD shell am start -n $PKG/.MainActivity \
    --es action import \
    --es file "$DEVICE_PATH"

# Wait for import
sleep 3

# Check for errors
ERROR_FILE="/sdcard/Android/data/$PKG/files/widgets/.errors/${WIDGET_NAME}.txt"
echo "Checking for errors..."
ERRORS=$($ADB_CMD shell "cat $ERROR_FILE 2>/dev/null" | tr -d '\r')

if [ -n "$ERRORS" ]; then
    echo "❌ Widget has errors:"
    echo "$ERRORS"
    exit 1
fi

echo "✓ Widget imported successfully"
echo ""
echo "Check your device - the widget should now be available to add to your home screen."
```

---

## Quick Reference Commands

### ADB Commands
```bash
# List connected devices
adb devices

# Install APK
adb install -r app-foss-debug.apk

# Uninstall (keeps data)
adb uninstall dev.omalauncher

# Uninstall (removes data)
adb uninstall -k dev.omalauncher

# Launch app
adb shell am start -n dev.omalauncher/.MainActivity

# Force stop
adb shell am force-stop dev.omalauncher

# Clear cache
adb shell pm clear dev.omalauncher

# View logs
adb logcat | grep omalauncher

# View crashes
adb logcat -b crash | grep omalauncher
```

### Gradle Commands
```bash
# Full build + tests
./gradlew :owl:test :app:testFossDebugUnitTest :app:assembleFossDebug

# Build OWL checker JAR
./gradlew :owl:owlJar

# Install on device
./gradlew :app:installFossDebug

# Run instrumentation tests
./gradlew :app:connectedFossDebugAndroidTest

# Run lint
./gradlew :app:lintFossDebug

# Clean build
./gradlew clean
```

---

## Troubleshooting Post-Installation

### App Won't Launch
- **Check**: Is Omalauncher set as default launcher?
- **Fix**: Settings → Apps → Default apps → Home app → Omalauncher

### Linux Not Working
- **Check**: Is Linux installed?
  - Settings → Linux → Check status
- **Fix**: Settings → Linux → Install

### Widgets Not Showing
- **Check**: Are widgets enabled?
  - Settings → Widgets → Enable widget store
- **Fix**: Pull to refresh in widget store

### ADB Not Detecting Device
- **Check**: USB debugging enabled?
  - Settings → Developer options → USB debugging
- **Fix**: Revoke USB debugging authorizations and reconnect

### Build Failures
- **Check**: proot fetched?
  - `ls app/src/main/jniLibs/arm64-v8a/libproot.so`
- **Fix**: Run `./scripts/fetch-proot.sh`

---

## Next Steps

After completing post-installation:

1. **For Users**: Explore the widget store and install useful widgets
2. **For Developers**: 
   - Read the [Developer Guide](DEVELOPER_GUIDE.md)
   - Start with a simple widget
   - Contribute to the project

---

*Last updated: $(date +%Y-%m-%d)*
*See also: [Developer Guide](DEVELOPER_GUIDE.md), [README](README.md)*
