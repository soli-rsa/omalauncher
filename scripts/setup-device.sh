#!/usr/bin/env bash
# Omalauncher Device Setup Script
#
# Automates the setup of a device for Omalauncher testing and development.
# This script installs Omalauncher on a connected device, grants permissions,
# and configures it for testing.
#
# Usage: ./scripts/setup-device.sh [apk-path] [serial]
#
# Arguments:
#   apk-path    Path to APK to install (default: app/build/outputs/apk/foss/debug/app-foss-debug.apk)
#   serial      ADB serial number (optional, for multiple devices)

set -euo pipefail

# Default values
APK="${1:-app/build/outputs/apk/foss/debug/app-foss-debug.apk}"
SERIAL="${2:-}"

# Package name
PKG="dev.omalauncher"

# ADB command
ADB_CMD="adb"
if [ -n "$SERIAL" ]; then
    ADB_CMD="adb -s $SERIAL"
fi

echo "=========================================="
echo "  Omalauncher Device Setup"
echo "=========================================="
echo ""
echo "APK: $APK"
if [ -n "$SERIAL" ]; then
    echo "Device: $SERIAL"
fi
echo ""

# Function to print status
status() {
    echo "  [$1] $2"
}

# Function to print error
error() {
    echo "  [✗] $1" >&2
}

# Function to print success
success() {
    echo "  [✓] $2"
}

# 1. Check if APK exists
echo "1. Checking APK..."
if [ ! -f "$APK" ]; then
    error "APK not found: $APK"
    echo ""
    echo "Please build the APK first:"
    echo "  ./gradlew :app:assembleFossDebug"
    exit 1
fi

APK_SIZE=$(stat -f%z "$APK" 2>/dev/null || stat -c%s "$APK")
echo "   APK size: $((APK_SIZE / 1024 / 1024)) MB"
success "APK found"
echo ""

# 2. Check device connection
echo "2. Checking device connection..."
DEVICES=$($ADB_CMD devices | grep -c device || true)
if [ "$DEVICES" -eq 0 ]; then
    error "No device connected"
    echo ""
    echo "Please connect a device via USB and enable USB debugging"
    exit 1
fi

DEVICE_MODEL=$($ADB_CMD shell getprop ro.product.model | tr -d '\r')
DEVICE_SERIAL=$($ADB_CMD shell getprop ro.serialno | tr -d '\r')
success "Device connected: $DEVICE_MODEL ($DEVICE_SERIAL)"
echo ""

# 3. Check if Omalauncher is already installed
echo "3. Checking Omalauncher installation..."
INSTALLED=$($ADB_CMD shell pm list packages | grep -c "$PKG" || true)

if [ "$INSTALLED" -eq 1 ]; then
    CURRENT_VERSION=$($ADB_CMD shell dumpsys package $PKG | grep versionName | awk '{print $NF}' | tr -d '\r')
    status "INFO" "Omalauncher already installed (version: $CURRENT_VERSION)"
else
    status "INFO" "Omalauncher not installed"
fi
echo ""

# 4. Uninstall existing version (keeps data)
echo "4. Uninstalling existing version..."
$ADB_CMD uninstall $PKG 2>/dev/null || true
success "Uninstalled (data preserved)"
echo ""

# 5. Install new version
echo "5. Installing Omalauncher..."
if ! $ADB_CMD install -r "$APK"; then
    error "Failed to install APK"
    echo ""
    echo "Possible issues:"
    echo "  - Device storage full"
    echo "  - APK is corrupted"
    echo "  - Incompatible device architecture"
    exit 1
fi

# Wait for installation to complete
sleep 3

# Verify installation
INSTALLED=$($ADB_CMD shell pm list packages | grep -c "$PKG" || true)
if [ "$INSTALLED" -eq 0 ]; then
    error "Installation verification failed"
    exit 1
fi

INSTALLED_VERSION=$($ADB_CMD shell dumpsys package $PKG | grep versionName | awk '{print $NF}' | tr -d '\r')
success "Omalauncher installed (version: $INSTALLED_VERSION)"
echo ""

# 6. Grant permissions
echo "6. Granting permissions..."

# Storage permissions (for Files feature)
$ADB_CMD shell pm grant $PKG android.permission.READ_EXTERNAL_STORAGE 2>/dev/null || true
$ADB_CMD shell pm grant $PKG android.permission.WRITE_EXTERNAL_STORAGE 2>/dev/null || true
success "Storage permissions granted"

# Microphone permission (for Voice feature)
$ADB_CMD shell pm grant $PKG android.permission.RECORD_AUDIO 2>/dev/null || true
success "Microphone permission granted"

# Notification permission
$ADB_CMD shell pm grant $PKG android.permission.POST_NOTIFICATIONS 2>/dev/null || true
success "Notification permission granted"

echo ""

# 7. Set as default launcher
echo "7. Setting as default launcher..."
if ! $ADB_CMD shell cmd package set-home-activity $PKG/.MainActivity; then
    error "Failed to set as default launcher"
    echo "   You may need to set it manually:"
    echo "   Settings → Apps → Default apps → Home app → Omalauncher"
else
    success "Set as default launcher"
fi
echo ""

# 8. Clear cache (optional, for fresh start)
echo "8. Clearing cache..."
$ADB_CMD shell pm clear $PKG 2>/dev/null || true
success "Cache cleared"
echo ""

# 9. Launch Omalauncher
echo "9. Launching Omalauncher..."
$ADB_CMD shell am start -n $PKG/.MainActivity
success "Omalauncher launched"
echo ""

# 10. Wait for app to initialize
echo "10. Waiting for initialization..."
sleep 5

# Check if app is running
PID=$($ADB_CMD shell pidof $PKG | tr -d '\r')
if [ -n "$PID" ]; then
    success "Omalauncher is running (PID: $PID)"
else
    error "Omalauncher is not running"
    echo "   Try launching it manually from the app drawer"
fi
echo ""

# 11. Summary
echo "=========================================="
echo "  Device Setup Complete!"
echo "=========================================="
echo ""

echo "Omalauncher is now installed on your device."
echo ""

echo "What's next:"
echo ""
echo "1. Complete first-run setup on your device"
echo "   - Set as default launcher (if not already)"
echo "   - Grant any additional permissions"
echo "   - Select language"
echo ""
echo "2. Optional: Install Linux (for widgets that need it)"
echo "   - Open Omalauncher settings"
echo "   - Go to Linux → Install"
echo "   - This downloads Arch Linux (~800MB)"
echo ""
echo "3. Add widgets to your home screen"
echo "   - Long-press on home screen"
echo "   - Tap 'Add widget'"
echo "   - Browse and install widgets from store"
echo ""
echo "4. Test development widgets"
echo "   - Push widget.owl to /sdcard/Download/"
echo "   - Long-press → Add widget → Import"
echo ""

echo "Useful ADB commands:"
echo "  adb logcat | grep omalauncher    # View logs"
echo "  adb shell am force-stop $PKG     # Force stop"
echo "  adb shell am start -n $PKG/.MainActivity  # Launch"
echo "  adb shell dumpsys package $PKG    # Package info"
echo ""

exit 0
