#!/bin/bash

echo "🔍 Flutter Compatibility Check"
echo "=============================="

# Check Flutter version
echo "📱 Current Flutter Version:"
flutter --version

echo ""
echo "📦 Checking Dependencies:"
flutter pub deps

echo ""
echo "🔧 Running Flutter Doctor:"
flutter doctor -v

echo ""
echo "🧪 Running Tests:"
flutter test

echo ""
echo "🏗️ Testing Build (Android):"
flutter build apk --debug --verbose

echo ""
echo "✅ Compatibility Check Complete!"
