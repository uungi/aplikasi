#!/bin/bash

echo "🤖 Building Android Release"
echo "=========================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Step 1: Pre-build checks
echo -e "\n${BLUE}📋 Pre-build Checks${NC}"
print_info "Checking Android SDK..."
if [ -z "$ANDROID_HOME" ]; then
    print_warning "ANDROID_HOME not set. Please set your Android SDK path."
fi

# Step 2: Build APK
echo -e "\n${BLUE}📱 Building APK${NC}"
print_info "Building release APK..."
flutter build apk --release --verbose

if [ $? -eq 0 ]; then
    print_status "APK build successful!"
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    print_info "APK Location: $APK_PATH"
    print_info "APK Size: $APK_SIZE"
else
    echo "❌ APK build failed!"
    exit 1
fi

# Step 3: Build App Bundle (for Play Store)
echo -e "\n${BLUE}📦 Building App Bundle${NC}"
print_info "Building release App Bundle for Play Store..."
flutter build appbundle --release --verbose

if [ $? -eq 0 ]; then
    print_status "App Bundle build successful!"
    AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    print_info "App Bundle Location: $AAB_PATH"
    print_info "App Bundle Size: $AAB_SIZE"
else
    echo "❌ App Bundle build failed!"
    exit 1
fi

# Step 4: Build Summary
echo -e "\n${GREEN}🎉 Android Build Complete!${NC}"
echo "=========================="
print_status "APK: $APK_PATH ($APK_SIZE)"
print_status "App Bundle: $AAB_PATH ($AAB_SIZE)"
print_info "Ready for distribution!"
