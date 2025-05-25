#!/bin/bash

echo "🔍 COMPREHENSIVE BUILD AUDIT - AI Resume Generator"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    case $2 in
        "SUCCESS") echo -e "${GREEN}✅ $1${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $1${NC}" ;;
        "ERROR") echo -e "${RED}❌ $1${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $1${NC}" ;;
    esac
}

# Initialize counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
CRITICAL_ISSUES=0

# Function to run check
run_check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if eval "$1"; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        print_status "$2" "SUCCESS"
        return 0
    else
        if [ "$3" = "CRITICAL" ]; then
            CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            print_status "$2" "ERROR"
        else
            print_status "$2" "WARNING"
        fi
        return 1
    fi
}

echo ""
echo "🔧 1. ENVIRONMENT CHECKS"
echo "========================"

# Check Flutter installation
run_check "flutter --version > /dev/null 2>&1" "Flutter installation detected" "CRITICAL"

# Check Flutter version
if flutter --version 2>/dev/null | grep -E "Flutter 3\.(1[6-9]|2[0-4])" > /dev/null; then
    run_check "true" "Flutter version is compatible (3.16+)" "CRITICAL"
else
    run_check "false" "Flutter version compatibility" "CRITICAL"
fi

# Check for fake Flutter version
if flutter --version 2>/dev/null | grep "3.32" > /dev/null; then
    run_check "false" "FAKE Flutter version detected!" "CRITICAL"
    print_status "Please install official Flutter from flutter.dev" "ERROR"
else
    run_check "true" "No fake Flutter version detected" "CRITICAL"
fi

# Check Dart SDK
run_check "dart --version > /dev/null 2>&1" "Dart SDK available" "CRITICAL"

echo ""
echo "📦 2. DEPENDENCY CHECKS"
echo "======================="

# Check pubspec.yaml exists
run_check "[ -f pubspec.yaml ]" "pubspec.yaml exists" "CRITICAL"

# Check pubspec.lock exists
run_check "[ -f pubspec.lock ]" "pubspec.lock exists (dependencies resolved)" "CRITICAL"

# Run pub get
print_status "Running flutter pub get..." "INFO"
if flutter pub get > /dev/null 2>&1; then
    run_check "true" "Dependencies resolved successfully" "CRITICAL"
else
    run_check "false" "Dependency resolution failed" "CRITICAL"
fi

# Check for dependency conflicts
if flutter pub deps > /dev/null 2>&1; then
    run_check "true" "No dependency conflicts detected" "CRITICAL"
else
    run_check "false" "Dependency conflicts detected" "CRITICAL"
fi

echo ""
echo "📁 3. ASSET CHECKS"
echo "=================="

# Check required assets
run_check "[ -f .env ]" ".env file exists" "CRITICAL"
run_check "[ -d assets ]" "assets directory exists" "CRITICAL"
run_check "[ -d assets/images ]" "assets/images directory exists" "CRITICAL"

# Check asset sizes
if [ -d assets ]; then
    LARGE_ASSETS=$(find assets -type f -size +1M 2>/dev/null | wc -l)
    if [ "$LARGE_ASSETS" -gt 0 ]; then
        run_check "false" "Found $LARGE_ASSETS large assets (>1MB)" "WARNING"
        print_status "Consider optimizing large assets for better performance" "WARNING"
    else
        run_check "true" "No large assets detected" "WARNING"
    fi
fi

echo ""
echo "🔧 4. CONFIGURATION CHECKS"
echo "=========================="

# Check Android configuration
run_check "[ -f android/app/build.gradle ]" "Android build.gradle exists" "CRITICAL"
run_check "[ -f android/build.gradle ]" "Android root build.gradle exists" "CRITICAL"

# Check for proper Android configuration
if [ -f android/app/build.gradle ]; then
    if grep -q "compileSdkVersion" android/app/build.gradle && grep -q "minSdkVersion" android/app/build.gradle; then
        run_check "true" "Android SDK versions configured" "CRITICAL"
    else
        run_check "false" "Android SDK versions not properly configured" "CRITICAL"
    fi
fi

# Check iOS configuration (if exists)
if [ -d ios ]; then
    run_check "[ -f ios/Runner/Info.plist ]" "iOS Info.plist exists" "WARNING"
    run_check "[ -f ios/Podfile ]" "iOS Podfile exists" "WARNING"
else
    print_status "iOS configuration not found (Android-only build)" "INFO"
fi

echo ""
echo "🧪 5. CODE QUALITY CHECKS"
echo "========================="

# Run Flutter analyze
print_status "Running flutter analyze..." "INFO"
if flutter analyze > /dev/null 2>&1; then
    run_check "true" "Code analysis passed" "WARNING"
else
    run_check "false" "Code analysis found issues" "WARNING"
    print_status "Run 'flutter analyze' to see detailed issues" "WARNING"
fi

# Check for TODO/FIXME comments
TODO_COUNT=$(find lib -name "*.dart" -exec grep -l "TODO\|FIXME" {} \; 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
    run_check "false" "Found $TODO_COUNT files with TODO/FIXME comments" "WARNING"
else
    run_check "true" "No TODO/FIXME comments found" "WARNING"
fi

echo ""
echo "🔒 6. SECURITY CHECKS"
echo "===================="

# Check for hardcoded secrets
SECRET_PATTERNS=("password" "secret" "key" "token" "api_key")
SECRETS_FOUND=0

for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -r -i "$pattern.*=" lib/ 2>/dev/null | grep -v "// " | grep -v "/// " > /dev/null; then
        SECRETS_FOUND=$((SECRETS_FOUND + 1))
    fi
done

if [ "$SECRETS_FOUND" -gt 0 ]; then
    run_check "false" "Potential hardcoded secrets found" "CRITICAL"
    print_status "Review code for hardcoded secrets and use environment variables" "ERROR"
else
    run_check "true" "No hardcoded secrets detected" "CRITICAL"
fi

# Check .env file security
if [ -f .env ]; then
    if grep -q "OPENAI_API_KEY" .env; then
        run_check "true" "Environment variables properly configured" "WARNING"
    else
        run_check "false" "Required environment variables missing" "WARNING"
    fi
fi

echo ""
echo "🚀 7. BUILD PREPARATION"
echo "======================"

# Clean previous builds
print_status "Cleaning previous builds..." "INFO"
if flutter clean > /dev/null 2>&1; then
    run_check "true" "Previous builds cleaned successfully" "WARNING"
else
    run_check "false" "Failed to clean previous builds" "WARNING"
fi

# Test build preparation
print_status "Testing build preparation..." "INFO"
if flutter build apk --debug --no-pub > /dev/null 2>&1; then
    run_check "true" "Debug build preparation successful" "CRITICAL"
else
    run_check "false" "Debug build preparation failed" "CRITICAL"
fi

echo ""
echo "📊 AUDIT SUMMARY"
echo "================"

SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo "Total Checks: $TOTAL_CHECKS"
echo "Passed Checks: $PASSED_CHECKS"
echo "Critical Issues: $CRITICAL_ISSUES"
echo "Score: $SCORE%"

if [ "$SCORE" -ge 95 ] && [ "$CRITICAL_ISSUES" -eq 0 ]; then
    print_status "BUILD READY! Score: $SCORE% (Grade A+)" "SUCCESS"
    echo ""
    echo "🎉 Your app is ready for production build!"
    echo "Recommended build commands:"
    echo "  • flutter build apk --release"
    echo "  • flutter build appbundle --release"
elif [ "$SCORE" -ge 85 ] && [ "$CRITICAL_ISSUES" -eq 0 ]; then
    print_status "BUILD SAFE! Score: $SCORE% (Grade A)" "SUCCESS"
    echo ""
    echo "✅ Your app is safe to build with minor warnings"
elif [ "$CRITICAL_ISSUES" -eq 0 ]; then
    print_status "BUILD WITH CAUTION! Score: $SCORE% (Grade B)" "WARNING"
    echo ""
    echo "⚠️ Consider fixing warnings before production build"
else
    print_status "BUILD NOT SAFE! Score: $SCORE% (Grade F)" "ERROR"
    echo ""
    echo "❌ Fix critical issues before attempting to build"
    echo "Critical issues found: $CRITICAL_ISSUES"
fi

echo ""
echo "🔧 RECOMMENDED ACTIONS:"
echo "======================"

if [ "$CRITICAL_ISSUES" -gt 0 ]; then
    echo "1. Fix all critical issues listed above"
    echo "2. Re-run this audit script"
fi

echo "• Run 'flutter doctor' to check Flutter installation"
echo "• Run 'flutter analyze' to check code quality"
echo "• Run 'flutter test' to ensure all tests pass"
echo "• Test on physical devices before release"

exit $CRITICAL_ISSUES
