#!/bin/bash

echo "🍎 Building iOS Release"
echo "====================="

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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ iOS builds require macOS"
    exit 1
fi

# Step 1: Pre-build checks
echo -e "\n${BLUE}📋 Pre-build Checks${NC}"
print_info "Checking Xcode installation..."
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found! Please install Xcode."
    exit 1
fi

# Step 2: Build iOS
echo -e "\n${BLUE}📱 Building iOS${NC}"
print_info "Building iOS release..."
flutter build ios --release --verbose

if [ $? -eq 0 ]; then
    print_status "iOS build successful!"
    print_info "iOS app built at: build/ios/iphoneos/Runner.app"
else
    echo "❌ iOS build failed!"
    exit 1
fi

# Step 3: Instructions for App Store
echo -e "\n${BLUE}📦 App Store Preparation${NC}"
print_info "To submit to App Store:"
print_info "1. Open ios/Runner.xcworkspace in Xcode"
print_info "2. Select 'Any iOS Device' as target"
print_info "3. Product → Archive"
print_info "4. Upload to App Store Connect"

echo -e "\n${GREEN}🎉 iOS Build Complete!${NC}"
print_status "Ready for App Store submission!"
