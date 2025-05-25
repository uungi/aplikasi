#!/bin/bash

echo "🪟 Building Windows Release"
echo "========================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Step 1: Build Windows
echo -e "\n${BLUE}🪟 Building Windows${NC}"
print_info "Building Windows release..."
flutter build windows --release --verbose

if [ $? -eq 0 ]; then
    print_status "Windows build successful!"
    print_info "Windows app built at: build/windows/runner/Release/"
    
    # Get build size
    BUILD_SIZE=$(du -sh build/windows/runner/Release/ | cut -f1)
    print_info "Build Size: $BUILD_SIZE"
else
    echo "❌ Windows build failed!"
    exit 1
fi

echo -e "\n${GREEN}🎉 Windows Build Complete!${NC}"
print_status "Ready for distribution!"
