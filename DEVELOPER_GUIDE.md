# Developer Guide

This guide covers development for **Omalauncher**. For **omarchy-widgets** (widget store) development, see the [omarchy-widgets Developer Guide](../omarchy-widgets/DEVELOPER_GUIDE.md).

This document focuses on Omalauncher development.

## Table of Contents

1. [Setup Instructions](#1-setup-instructions)
2. [Project Structure Overview](#2-project-structure-overview)
3. [Development Workflow](#3-development-workflow)
4. [Testing Approach](#4-testing-approach)
5. [Common Troubleshooting Steps](#5-common-troubleshooting-steps)

---

## 1. Setup Instructions

### 1.1 Prerequisites

**For both repositories:**
- Java JDK 21+ (Temurin recommended)
- Git
- GitHub CLI (optional but recommended)

**For Omalauncher specifically:**
- Android SDK (API 37)
- Android NDK (version specified in `scripts/fetch-proot.sh`)
- Android Build Tools
- Kotlin 1.9+
- CMake (for native builds)

**For omarchy-widgets specifically:**
- Java JDK 21+ (for running `tools/owl.jar`)
- Arch Linux (for package verification in CI)

### 1.2 Omalauncher Setup

```bash
# Clone the repository
git clone https://github.com/soli-rsa/omalauncher.git
cd omalauncher

# Fetch proot (required for Linux functionality)
# Needs bsdtar on the system
./scripts/fetch-proot.sh

# Install dependencies via Gradle
./gradlew :owl:test :app:testFossDebugUnitTest
```

**IDE Setup (Android Studio):**
1. Open the project in Android Studio
2. Wait for Gradle sync to complete
3. Ensure NDK is installed (version from `scripts/fetch-proot.sh`)
4. Select "foss" or "play" product flavor as needed

**Device Setup:**
- Minimum: Android 10 (API 29)
- Architecture: arm64-v8a
- Enable USB debugging
- For Linux testing: Ensure device has at least 2GB free storage

### 1.3 omarchy-widgets Setup

```bash
# Clone the repository
git clone https://github.com/soli-rsa/omarchy-widgets.git
cd omarchy-widgets

# Verify owl.jar is present
ls -la tools/owl.jar

# Test the checker
java -jar tools/owl.jar --help
```

**For local widget development:**
- Install Omalauncher on an Android device
- Connect device via ADB
- Widgets can be developed and tested directly on the device

### 1.4 Development Environment Recommendations

**Recommended Tools:**
- **Android Studio** (latest stable) for Omalauncher
- **VS Code** or **IntelliJ IDEA** for omarchy-widgets
- **ADB** for device testing
- **GitHub Desktop** or CLI for repository management

**Recommended Plugins:**
- Kotlin plugin
- Android plugin
- GitLens for GitHub integration

---

## 2. Project Structure Overview

### 2.1 Omalauncher Structure

```
omalauncher/
├── app/                          # Android application module
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/dev/omalauncher/  # Main Kotlin code
│   │   │   │   ├── MainActivity.kt    # Entry point
│   │   │   │   ├── Runtime.kt         # Core services
│   │   │   │   ├── linux/             # Linux subsystem
│   │   │   │   │   ├── Bootstrap.kt    # Rootfs setup
│   │   │   │   │   ├── Proot.kt        # proot integration
│   │   │   │   │   └── ...
│   │   │   │   ├── ui/                 # Jetpack Compose UI
│   │   │   │   │   ├── home/           # Home screen
│   │   │   │   │   ├── settings/       # Settings screens
│   │   │   │   │   └── ...
│   │   │   │   ├── widgets/           # Widget engine
│   │   │   │   │   ├── lang/           # OWL compiler
│   │   │   │   │   ├── render/         # Widget rendering
│   │   │   │   │   └── runtime/        # Widget runtime
│   │   │   │   ├── wayland/           # Wayland compositor
│   │   │   │   ├── voice/             # Voice assistant
│   │   │   │   └── ...
│   │   │   ├── cpp/                    # Native code (JNI)
│   │   │   │   └── wlbridge.c         # Wayland bridge
│   │   │   ├── res/                    # Resources
│   │   │   └── assets/                 # Static assets
│   │   └── test/                       # Unit tests
│   └── build.gradle.kts              # App build configuration
│
├── owl/                          # OWL language module
│   ├── src/
│   │   ├── main/kotlin/              # OWL compiler
│   │   └── test/kotlin/               # OWL tests
│   └── build.gradle.kts
│
├── scripts/                      # Build and utility scripts
│   ├── fetch-proot.sh              # Download proot
│   ├── fetch-theme-colors.sh      # Fetch Omarchy themes
│   ├── make-icons.sh               # Generate icons
│   ├── store-previews.sh           # Generate widget previews
│   └── ...
│
├── docs/                         # Documentation
│   ├── ARCHITECTURE.md             # System architecture
│   ├── RELEASING.md               # Release process
│   └── plans/                      # Design documents
│
├── fastlane/                     # Play Store deployment
├── store/                        # Play Store assets
├── art/                          # Artwork
├── patches/                      # Patches for dependencies
├── gradle/                       # Gradle configuration
├── build.gradle.kts              # Root build
├── settings.gradle.kts           # Project settings
└── README.md
```

**Key Modules:**
- **app**: Main Android application (Kotlin, Jetpack Compose)
- **owl**: OWL widget language compiler (pure Kotlin, JVM 17)

### 2.2 omarchy-widgets Structure

```
omarchy-widgets/
├── widgets/                      # Widget collection
│   └── <author>/
│       └── <widget-name>/
│           ├── widget.owl         # Widget definition
│           ├── preview.png        # Screenshot
│           └── previews/          # Theme-specific previews
│               └── <theme>.webp
│
├── faces/                        # Home screen faces
│   └── <author>/
│       └── <face-name>/
│           ├── face.owl           # Face definition
│           ├── page-2.owl         # Additional pages (optional)
│           └── screens/           # Page-specific previews
│
├── apps/                         # Full-screen apps
│   └── <author>/
│       └── <app-name>/
│           ├── app.owl            # App definition
│           ├── preview.png        # Screenshot
│           └── previews/          # Theme-specific previews
│
├── tools/                        # Development tools
│   ├── owl.jar                    # OWL checker
│   ├── rank.py                   # Widget ranking
│   ├── collage.py                # Preview generation
│   └── verify-pr.sh              # PR verification
│
├── runtimes/                     # Runtime implementations
│   └── quickshell/                # Quickshell runtime
│
├── docs/                         # Documentation
│   └── LANGUAGE.md               # OWL language reference
│
├── .github/                      # GitHub configuration
│   └── workflows/
│       ├── publish.yml           # Store publishing
│       ├── review.yml            # PR review
│       └── runtime.yml           # Runtime conformance
│
├── announcements.json            # User announcements
├── order.txt                     # Store ordering
├── owl.txt                       # Supported OWL levels
├── rank.txt                      # Widget rankings
├── rank-apps.txt                 # App rankings
└── README.md
```

### 2.3 Architecture Overview

**Omalauncher Architecture:**
- **Android Launcher**: Home screen replacement with Omarchy themes
- **Linux Subsystem**: Arch Linux ARM under proot (optional)
- **Wayland Compositor**: Manages Linux windows as Android tasks
- **Widget Engine**: Renders OWL widgets on the home screen
- **Voice Assistant**: Integrates with coding agents

**omarchy-widgets Architecture:**
- **Widget Store**: Central repository for OWL widgets, faces, and apps
- **OWL Language**: Declarative widget language (documented in `docs/LANGUAGE.md`)
- **Review System**: Automated checks for security and quality
- **Publishing Pipeline**: CI builds and publishes store catalogs

---

## 3. Development Workflow

### 3.1 Omalauncher Development

#### 3.1.1 Building

```bash
# Full build (tests + lint + assemble)
./gradlew :owl:test :app:testFossDebugUnitTest :app:assembleFossDebug :app:lintFossDebug

# Incremental build
./gradlew :app:assembleFossDebug

# Build OWL checker JAR
./gradlew :owl:owlJar

# Clean build
./gradlew clean
```

#### 3.1.2 Running

```bash
# Install debug build on connected device
./gradlew :app:installFossDebug

# Install with adb
adb install -r app/build/outputs/apk/foss/debug/app-foss-debug.apk

# Run on device with guest command (debug builds only)
adb shell am start -n dev.omalauncher/.MainActivity --es exec 'foot'
```

#### 3.1.3 Debugging

```bash
# View logs
adb logcat | grep omalauncher

# View specific tag
adb logcat Runtime:I *:S

# Connect Android Studio debugger
# Run -> Attach debugger to Android process

# Profile with Android Profiler
# Android Studio -> Profiler
```

#### 3.1.4 Code Changes

**Adding a new feature:**
1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make changes following existing patterns
3. Add tests (see Testing section)
4. Update documentation if needed
5. Commit with descriptive message
6. Push and create PR

**OWL Language Changes:**
1. Modify `owl/src/main/kotlin/dev/omalauncher/widgets/lang/`
2. Update `Compiler.LEVEL` if adding new language features
3. Update `SINCE` constant with level information
4. Update `app/src/main/assets/widgets/docs/versions.md`
5. Add tests in `owl/src/test/`
6. Run `./gradlew :owl:owlJar` to rebuild checker

#### 3.1.5 Testing on Device

```bash
# Enable developer options on device
# Settings -> About phone -> Tap Build number 7 times

# Enable USB debugging
# Settings -> Developer options -> USB debugging

# Connect device
adb devices

# Install and test
./gradlew :app:installFossDebug

# Test Linux functionality
adb shell am start -n dev.omalauncher/.MainActivity
```

### 3.2 omarchy-widgets Development

#### 3.2.1 Creating a Widget

```bash
# Create widget directory
mkdir -p widgets/myusername/my-widget

# Create widget.owl
cat > widgets/myusername/my-widget/widget.owl << 'EOF'
widget "my-widget" {
  meta { description: "My test widget"; version: "1.0"; license: "MIT"; category: "dev" }
  size: 2x2
  
  source time = clock every 1s
  
  Text {
    text: fmtTime(time, "HH:mm:ss")
    style: title
  }
}
EOF

# Validate widget
java -jar tools/owl.jar review . widgets/myusername/my-widget/widget.owl
```

#### 3.2.2 Testing a Widget

**On device:**
1. Copy widget file to device: `adb push widgets/myusername/my-widget/widget.owl /sdcard/Download/`
2. In Omalauncher: Long-press home screen -> Add widget -> Import
3. Select the widget file

**Local validation:**
```bash
# Check syntax
java -jar tools/owl.jar check widgets/myusername/my-widget/widget.owl

# Review (shows what it runs and installs)
java -jar tools/owl.jar review . widgets/myusername/my-widget/widget.owl

# Generate preview
java -jar tools/owl.jar preview widgets/myusername/my-widget/widget.owl preview.png
```

#### 3.2.3 Submitting a Widget

1. Fork the repository
2. Add widget to `widgets/<your-username>/<name>/widget.owl`
3. Add metadata (description, version, license, category)
4. Optionally add `preview.png` and theme previews
5. Validate: `java -jar tools/owl.jar review . widgets/<you>/<name>/widget.owl`
6. Commit and push
7. Open PR

**PR Process:**
- CI runs automated review (review.yml workflow)
- Checks for security issues, package dependencies
- Maintainer reviews and merges
- CI publishes to store (publish.yml workflow)

### 3.3 Common Workflows

#### 3.3.1 Updating Dependencies

**Omalauncher:**
```bash
# Update Gradle dependencies
# Edit libs.versions.toml or build.gradle.kts

# Update proot
./scripts/fetch-proot.sh

# Update sherpa-onnx
# Edit app/build.gradle.kts (sherpaVersion and sherpaSha256)
```

**omarchy-widgets:**
```bash
# Update owl.jar
# Copy from omalauncher/owl/build/cli/owl.jar
cp /path/to/omalauncher/owl/build/cli/owl.jar tools/owl.jar
```

#### 3.3.2 Version Management

**Omalauncher:**
- Version in `app/build.gradle.kts` (versionCode, versionName)
- CHANGELOG.md updated on releases
- Tag format: `v1.10.0`

**omarchy-widgets:**
- Widget version in `meta { version: "..." }`
- Store catalog version in index.json
- OWL language level in `owl.txt`

### 3.4 Branch Strategy

**Omalauncher:**
- `main`: Development branch
- `release/*`: Release preparation (rare)
- Feature branches: `feature/*` or `fix/*`

**omarchy-widgets:**
- `main`: Production branch
- PR branches: Any name (CI validates)
- No long-lived branches

---

## 4. Testing Approach

### 4.1 Omalauncher Testing

#### 4.1.1 Unit Tests

```bash
# Run all unit tests
./gradlew :owl:test :app:testFossDebugUnitTest

# Run specific test
./gradlew :app:testFossDebugUnitTest --tests "dev.omalauncher.ui.HardcodedTextTest"

# Run OWL compiler tests
./gradlew :owl:test
```

**Test Locations:**
- `owl/src/test/kotlin/` - OWL language tests
- `app/src/test/kotlin/` - Android app tests

**Key Test Files:**
- `LangTest.kt` - OWL language compiler tests
- `HardcodedTextTest.kt` - Checks for hardcoded strings
- `OmalauncherScriptTest.kt` - Verifies omalauncher command consistency
- `MarketTest.kt` - Widget store tests

#### 4.1.2 Instrumentation Tests

```bash
# Run on connected device
./gradlew :app:connectedFossDebugAndroidTest

# Run specific test
./gradlew :app:connectedFossDebugAndroidTest -P android.testInstrumentationRunnerArguments.class=dev.omalauncher.ui.home.TileLiftTest
```

#### 4.1.3 Manual Testing

**Smoke Tests:**
```bash
# Run smoke test script
./scripts/release-smoke.sh
```

**Manual Test Cases:**
1. Launch app on device
2. Test home screen navigation
3. Test widget rendering
4. Test Linux commands (if Linux installed)
5. Test voice input
6. Test settings changes

#### 4.1.4 CI Pipeline

CI runs on every PR and push to main:
- Unit tests (`:owl:test`, `:app:testFossDebugUnitTest`)
- Lint checks (`:app:lintFossDebug`, `:app:lintPlayDebug`)
- Build (`:app:assembleFossDebug`)

### 4.2 omarchy-widgets Testing

#### 4.2.1 Widget Validation

```bash
# Check all widgets
find widgets -name "*.owl" -exec java -jar tools/owl.jar check {} \;

# Review a specific widget
java -jar tools/owl.jar review . widgets/author/name/widget.owl
```

#### 4.2.2 CI Pipeline

**review.yml** (PR validation):
- Runs on PRs targeting widgets, faces, or apps
- Uses Arch Linux container
- Checks:
  - Widget syntax validation
  - Package dependencies (verifies in Arch repos)
  - Security checks (dangerous commands)
  - Generates review summary

**runtime.yml** (Runtime conformance):
- Runs on changes to runtimes or tools
- Verifies Quickshell runtime matches owl.jar
- Runs Node.js tests

**publish.yml** (Store publishing):
- Runs on main branch pushes
- Builds index.json, faces.json, apps.json
- Publishes to GitHub Pages
- Runs on every push to update store

#### 4.2.3 Manual Testing

**Widget Testing:**
1. Import widget in Omalauncher
2. Verify rendering
3. Test interactions (taps, etc.)
4. Check for errors in `.errors/<widget>.txt`

**Face Testing:**
1. Install face
2. Verify full-screen rendering
3. Test page navigation (if multi-page)

**App Testing:**
1. Launch app from drawer
2. Verify full-screen rendering
3. Test app-specific functionality

### 4.3 Testing Best Practices

**Omalauncher:**
- Add tests for new functionality
- Follow existing test patterns
- Test both foss and play flavors when relevant
- Mock external dependencies where possible

**omarchy-widgets:**
- Validate all widgets before committing
- Test with multiple OWL language levels
- Verify package dependencies exist in Arch
- Check for security issues (eval, base64 decode, etc.)

---

## 5. Common Troubleshooting Steps

### 5.1 Build Issues

#### 5.1.1 Gradle Build Failures

**Error: NDK not found**
```bash
# Install NDK
./scripts/fetch-proot.sh

# Or manually install
sdkmanager --install "ndk;<version>"
```

**Error: Java version mismatch**
```bash
# Use Java 21+
java -version
# If wrong version, install Temurin 21
```

**Error: Missing proot libraries**
```bash
# Run fetch-proot script
./scripts/fetch-proot.sh

# Or copy from another checkout
cp -r /path/to/working/checkout/app/src/main/jniLibs/* app/src/main/jniLibs/
cp /path/to/working/checkout/local.properties .
```

#### 5.1.2 Dependency Issues

**Error: Dependency resolution failed**
```bash
# Clean and rebuild
./gradlew clean
./gradlew :app:assembleFossDebug

# Or update Gradle cache
rm -rf ~/.gradle/caches/
```

**Error: sherpa-onnx AAR missing**
```bash
# Build will auto-fetch, or manually download
# Edit app/build.gradle.kts to update sherpaVersion and sherpaSha256
```

### 5.2 Runtime Issues

#### 5.2.1 App Crashes

**Error: ClassNotFoundException**
```bash
# Check if proot is properly set up
ls -la app/src/main/jniLibs/arm64-v8a/

# Verify local.properties exists
cat local.properties
```

**Error: Linux commands fail with -1**
```bash
# proot not initialized
# Run fetch-proot.sh and rebuild
./scripts/fetch-proot.sh
./gradlew clean :app:assembleFossDebug
```

#### 5.2.2 Widget Issues

**Error: Widget not rendering**
```bash
# Check widget syntax
java -jar tools/owl.jar check widgets/author/name/widget.owl

# Check for errors on device
adb shell "cat /sdcard/Android/data/dev.omalauncher/files/widgets/.errors/<widget>.txt"
```

**Error: Widget shows "needs newer launcher"**
```bash
# Widget requires newer OWL level
# Check widget's meta { owl: N }
# Check launcher's Compiler.LEVEL
# Update launcher or reduce widget's owl requirement
```

#### 5.2.3 Linux Subsystem Issues

**Error: Linux commands fail**
```bash
# Check if Linux is installed
adb shell "cat /sdcard/Android/data/dev.omalauncher/files/rootfs-steps.json"

# Reinstall Linux
# In app: Settings -> Linux -> Reinstall
```

**Error: Wayland windows not showing**
```bash
# Check Wayland server logs
adb logcat | grep -i wayland

# Verify proot is running
adb shell ps | grep proot
```

### 5.3 CI Issues

#### 5.3.1 Omalauncher CI Failures

**Error: Tests failing in CI**
```bash
# Run tests locally
./gradlew :owl:test :app:testFossDebugUnitTest

# Check test output
cat owl/build/reports/tests/test/index.html
cat app/build/reports/tests/testFossDebugUnitTest/index.html
```

**Error: Lint failures**
```bash
# Run lint locally
./gradlew :app:lintFossDebug

# Check lint report
cat app/build/reports/lint-results-fossDebug.html
```

#### 5.3.2 omarchy-widgets CI Failures

**Error: review.yml fails**
```bash
# Run review locally (needs Arch container)
docker run -it archlinux:latest bash
pacman -Syu --noconfirm git diffutils jre-openjdk-headless
# Then run verify-pr.sh
```

**Error: Package not found in Arch**
```bash
# Check package exists
pacman -Si <package-name>

# If package doesn't exist, remove from requires or find alternative
```

**Error: Security check failed**
```bash
# Review widget commands
java -jar tools/owl.jar programs widgets/author/name/widget.owl

# Look for flagged commands:
# - eval
# - base64 -d
# - rm -rf
# - wget | sh
# - curl | bash
```

### 5.4 Debugging Tools

#### 5.4.1 Log Analysis

```bash
# View all omalauncher logs
adb logcat | grep omalauncher

# View specific component
adb logcat Runtime:V *:S

# Save logs to file
adb logcat -d > omalauncher.log
```

#### 5.4.2 Device Inspection

```bash
# List installed packages
adb shell pm list packages | grep omalauncher

# View app data directory
adb shell ls -la /data/data/dev.omalauncher/

# View files directory
adb shell ls -la /sdcard/Android/data/dev.omalauncher/files/

# Check Linux rootfs
adb shell ls -la /sdcard/Android/data/dev.omalauncher/files/arch/
```

#### 5.4.3 Widget Debugging

```bash
# Check widget errors
adb shell "cat /sdcard/Android/data/dev.omalauncher/files/widgets/.errors/<widget>.txt"

# View widget source
adb shell "cat /sdcard/Android/data/dev.omalauncher/files/widgets/<author>/<name>/widget.owl"

# Force widget refresh
adb shell am broadcast -n dev.omalauncher/.WidgetRefreshReceiver
```

### 5.5 Common Solutions

**Problem: Build succeeds but app crashes on launch**
- Solution: Check proot libraries are in jniLibs
- Solution: Verify local.properties exists
- Solution: Clean and rebuild

**Problem: Widgets not showing up in store**
- Solution: Check widget has proper meta tags
- Solution: Verify widget is in correct directory structure
- Solution: Check CI published successfully

**Problem: Linux commands return -1**
- Solution: Run fetch-proot.sh
- Solution: Rebuild app
- Solution: Reinstall Linux from settings

**Problem: Tests pass locally but fail in CI**
- Solution: Check Java version (CI uses 25)
- Solution: Check NDK version
- Solution: Run with same environment as CI

**Problem: Lint errors about hardcoded text**
- Solution: Move text to strings.xml
- Solution: Add translations for all languages

---

## Additional Resources

- [Omalauncher README](README.md) - Project overview
- [Omalauncher Architecture](docs/ARCHITECTURE.md) - System design
- [Omalauncher Releasing](docs/RELEASING.md) - Release process
- [AGENTS.md](AGENTS.md) - Coding agent guidelines
- [omarchy-widgets README](https://github.com/soli-rsa/omarchy-widgets) - Widget store
- [omarchy-widgets Developer Guide](https://github.com/soli-rsa/omarchy-widgets/blob/main/DEVELOPER_GUIDE.md) - Widget development
- [OWL Language Reference](https://github.com/soli-rsa/omarchy-widgets/blob/main/docs/LANGUAGE.md) - Widget language docs

---

*Last updated: $(date +%Y-%m-%d)*
*Maintainers: Simon Schubert*
