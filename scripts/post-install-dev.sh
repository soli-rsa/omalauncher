#!/usr/bin/env bash
# Omalauncher Post-Installation Development Setup Script
# 
# This script automates the setup of your development environment after cloning
# the Omalauncher repository. It installs dependencies, builds the project,
# and runs tests.
#
# Usage: ./scripts/post-install-dev.sh [options]
#
# Options:
#   --skip-tests    Skip running tests (faster setup)
#   --skip-build    Skip building the app (only fetch dependencies)
#   --help          Show this help message

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Parse options
SKIP_TESTS=false
SKIP_BUILD=false

for ARG in "$@"; do
    case "$ARG" in
        --skip-tests)
            SKIP_TESTS=true
            ;;
        --skip-build)
            SKIP_BUILD=true
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --skip-tests    Skip running tests (faster setup)"
            echo "  --skip-build    Skip building the app (only fetch dependencies)"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $ARG"
            exit 1
            ;;
    esac
done

echo "=========================================="
echo "  Omalauncher Post-Installation Setup"
echo "=========================================="
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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
    echo "  [✓] $1"
}

# 1. Check Java
echo "1. Checking Java..."
if ! command_exists java; then
    error "Java is not installed"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
JAVA_MAJOR=$(echo "$JAVA_VERSION" | cut -d'.' -f1)

if [ "$JAVA_MAJOR" -lt 21 ]; then
    error "Java 21+ is required (found: $JAVA_VERSION)"
    exit 1
fi

success "Java $JAVA_VERSION"
echo ""

# 2. Check Android SDK
echo "2. Checking Android SDK..."
if [ -z "${ANDROID_HOME:-}" ]; then
    error "ANDROID_HOME is not set"
    echo "   Please set ANDROID_HOME to your Android SDK path"
    exit 1
fi

if [ ! -d "$ANDROID_HOME" ]; then
    error "Android SDK not found at $ANDROID_HOME"
    exit 1
fi

success "Android SDK: $ANDROID_HOME"
echo ""

# 3. Check Android NDK
echo "3. Checking Android NDK..."
NDK_VERSION=$(sed -n 's/^NDK_VERSION=//p' "$SCRIPT_DIR/fetch-proot.sh")

# Check if NDK is installed
NDK_PATH="${ANDROID_HOME}/ndk/${NDK_VERSION}"
if [ ! -d "$NDK_PATH" ]; then
    status "WARN" "NDK $NDK_VERSION not found at $NDK_PATH"
    echo "   This will be installed automatically during build if needed"
else
    success "Android NDK: $NDK_VERSION"
fi
echo ""

# 4. Check Gradle
echo "4. Checking Gradle..."
cd "$PROJECT_DIR"

if ! command_exists gradle; then
    if [ -f "gradlew" ]; then
        success "Using gradlew wrapper"
    else
        error "Gradle is not installed and gradlew not found"
        exit 1
    fi
else
    success "Gradle: $(gradle --version | head -1)"
fi
echo ""

# 5. Fetch proot
echo "5. Fetching proot..."
if [ ! -f "app/src/main/jniLibs/arm64-v8a/libproot.so" ]; then
    echo "   Running fetch-proot.sh..."
    if ! "$SCRIPT_DIR/fetch-proot.sh"; then
        error "Failed to fetch proot"
        echo "   Make sure bsdtar is installed"
        exit 1
    fi
    success "proot fetched successfully"
else
    success "proot already present"
fi
echo ""

# 6. Check local.properties
echo "6. Checking local.properties..."
if [ ! -f "local.properties" ]; then
    status "INFO" "local.properties not found"
    echo "   It will be created automatically during build"
else
    success "local.properties exists"
fi
echo ""

# 7. Build owl.jar
echo "7. Building OWL compiler..."
if ! "$PROJECT_DIR/gradlew" :owl:owlJar; then
    error "Failed to build owl.jar"
    exit 1
fi
success "OWL compiler built successfully"
echo ""

# 8. Run tests (unless skipped)
if [ "$SKIP_TESTS" = false ]; then
    echo "8. Running tests..."
    if ! "$PROJECT_DIR/gradlew" :owl:test :app:testFossDebugUnitTest; then
        error "Tests failed"
        exit 1
    fi
    success "All tests passed"
    echo ""
fi

# 9. Build app (unless skipped)
if [ "$SKIP_BUILD" = false ]; then
    echo "9. Building debug APK..."
    if ! "$PROJECT_DIR/gradlew" :app:assembleFossDebug; then
        error "Build failed"
        exit 1
    fi
    success "Debug APK built successfully"
    
    # Show APK location
    APK_PATH="$PROJECT_DIR/app/build/outputs/apk/foss/debug/app-foss-debug.apk"
    if [ -f "$APK_PATH" ]; then
        APK_SIZE=$(stat -f%z "$APK_PATH" 2>/dev/null || stat -c%s "$APK_PATH")
        echo "   APK location: $APK_PATH"
        echo "   APK size: $((APK_SIZE / 1024 / 1024)) MB"
    fi
    echo ""
fi

# 10. Summary
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""

echo "Next steps:"
echo ""

if [ "$SKIP_BUILD" = false ]; then
    echo "1. Connect an Android device via USB"
    echo "   - Enable USB debugging in Developer options"
    echo ""
    echo "2. Install on device:"
    echo "   ./gradlew :app:installFossDebug"
    echo "   or"
    echo "   adb install -r app/build/outputs/apk/foss/debug/app-foss-debug.apk"
    echo ""
fi

echo "3. Start developing:"
echo "   - Read DEVELOPER_GUIDE.md for development workflow"
echo "   - Read POST_INSTALL_GUIDE.md for post-installation steps"
echo ""

echo "4. Useful commands:"
echo "   - ./gradlew :app:installFossDebug  # Install on device"
echo "   - adb logcat | grep omalauncher    # View logs"
echo "   - ./scripts/fetch-proot.sh           # Re-fetch proot"
echo ""

echo "Need help?"
echo "   - Check README.md for project overview"
echo "   - Check docs/ARCHITECTURE.md for system design"
echo "   - Check DEVELOPER_GUIDE.md for development"
echo "   - Check POST_INSTALL_GUIDE.md for post-installation"
echo ""

exit 0
