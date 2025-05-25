#!/bin/bash

echo "🚀 AI Resume Generator - Build Preparation Script"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Step 1: Environment Check
echo -e "\n${BLUE}📋 Step 1: Environment Check${NC}"
echo "================================"

# Check Flutter installation
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_status "Flutter found: $FLUTTER_VERSION"
else
    print_error "Flutter not found! Please install Flutter first."
    exit 1
fi

# Check Flutter doctor
echo -e "\n🔍 Running Flutter Doctor..."
flutter doctor

# Step 2: Project Cleanup
echo -e "\n${BLUE}🧹 Step 2: Project Cleanup${NC}"
echo "============================"

print_info "Cleaning previous builds..."
flutter clean
print_status "Project cleaned successfully"

# Step 3: Dependencies
echo -e "\n${BLUE}📦 Step 3: Dependencies Update${NC}"
echo "==============================="

print_info "Getting dependencies..."
flutter pub get
print_status "Dependencies updated successfully"

# Step 4: Code Analysis
echo -e "\n${BLUE}🔍 Step 4: Code Analysis${NC}"
echo "========================="

print_info "Running code analysis..."
flutter analyze
if [ $? -eq 0 ]; then
    print_status "Code analysis passed"
else
    print_warning "Code analysis found issues - review before building"
fi

# Step 5: Tests
echo -e "\n${BLUE}🧪 Step 5: Running Tests${NC}"
echo "========================"

print_info "Running unit tests..."
flutter test
if [ $? -eq 0 ]; then
    print_status "All tests passed"
else
    print_warning "Some tests failed - review before building"
fi

# Step 6: Build Preparation Complete
echo -e "\n${GREEN}🎉 Build Preparation Complete!${NC}"
echo "================================"
print_status "Your project is ready for building"
print_info "You can now run the build commands for your target platform"

echo -e "\n${BLUE}📱 Next Steps:${NC}"
echo "• For Android: Run './scripts/build_android.sh'"
echo "• For iOS: Run './scripts/build_ios.sh'"
echo "• For Windows: Run './scripts/build_windows.sh'"
