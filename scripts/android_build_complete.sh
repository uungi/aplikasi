#!/bin/bash

# 🚀 AI Resume Generator - Complete Android Build Script
# =====================================================

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Emojis for better UX
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
PHONE="📱"
GEAR="⚙️"
PACKAGE="📦"

# Function to print colored output
print_header() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${PURPLE}================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}${SUCCESS} $1${NC}"
}

print_error() {
    echo -e "${RED}${ERROR} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

print_info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

print_step() {
    echo -e "\n${CYAN}${GEAR} $1${NC}"
}

# Start build process
clear
print_header "${ROCKET} AI RESUME GENERATOR - ANDROID BUILD"

echo -e "${WHITE}Selamat datang di automated build script!${NC}"
echo -e "${BLUE}Script ini akan membantu Anda build aplikasi Android secara otomatis.${NC}\n"

# Step 1: Environment Check
print_step "Step 1: Environment Check"
echo "Checking Flutter installation..."

if ! command -v flutter &> /dev/null; then
    print_error "Flutter tidak ditemukan! Silakan install Flutter terlebih dahulu."
    echo -e "${BLUE}Download Flutter: https://flutter.dev/docs/get-started/install${NC}"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -n 1)
print_success "Flutter ditemukan: $FLUTTER_VERSION"

# Check Android SDK
if [ -z "$ANDROID_HOME" ]; then
    print_warning "ANDROID_HOME tidak di-set. Pastikan Android SDK sudah terinstall."
else
    print_success "Android SDK ditemukan: $ANDROID_HOME"
fi

# Step 2: Flutter Doctor
print_step "Step 2: Flutter Doctor Check"
echo "Running flutter doctor..."
flutter doctor

echo -e "\n${YELLOW}Apakah semua check marks hijau? (y/n)${NC}"
read -r doctor_ok
if [[ $doctor_ok != "y" && $doctor_ok != "Y" ]]; then
    print_warning "Silakan perbaiki issues di flutter doctor terlebih dahulu."
    exit 1
fi

# Step 3: API Key Check
print_step "Step 3: API Key Configuration"
if [ ! -f ".env" ]; then
    print_warning "File .env tidak ditemukan!"
    echo -e "${BLUE}Membuat template .env file...${NC}"
    
    cat > .env << EOF
# OpenAI API Key (WAJIB)
OPENAI_API_KEY=sk-your-openai-api-key-here

# AdMob Configuration (Optional untuk testing)
ADMOB_PUBLISHER_ID=pub-your-publisher-id
ANDROID_BANNER_AD_UNIT=ca-app-pub-your-id/banner-unit
ANDROID_INTERSTITIAL_AD_UNIT=ca-app-pub-your-id/interstitial-unit
ANDROID_REWARDED_AD_UNIT=ca-app-pub-your-id/rewarded-unit

# App Configuration
APP_NAME=AI Resume Generator
PACKAGE_NAME=com.visha.airesume
EOF

    print_info "Template .env file telah dibuat. Silakan edit dengan API key Anda."
    echo -e "${YELLOW}Edit file .env dengan API key yang benar, lalu jalankan script ini lagi.${NC}"
    exit 1
fi

print_success "File .env ditemukan"

# Check if OpenAI API key is set
if grep -q "sk-your-openai-api-key-here" .env; then
    print_warning "OpenAI API key belum di-set di file .env"
    echo -e "${BLUE}Silakan edit .env file dan masukkan API key yang benar.${NC}"
    exit 1
fi

print_success "OpenAI API key sudah dikonfigurasi"

# Step 4: Keystore Check
print_step "Step 4: Keystore Configuration"
if [ ! -f "android/key.properties" ]; then
    print_warning "Keystore belum dikonfigurasi!"
    echo -e "${BLUE}Apakah Anda ingin membuat keystore baru? (y/n)${NC}"
    read -r create_keystore
    
    if [[ $create_keystore == "y" || $create_keystore == "Y" ]]; then
        echo -e "${BLUE}Membuat keystore baru...${NC}"
        
        # Create keystore
        keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
        
        if [ $? -eq 0 ]; then
            print_success "Keystore berhasil dibuat"
            
            # Create key.properties
            echo -e "${BLUE}Masukkan password keystore:${NC}"
            read -s keystore_password
            echo -e "${BLUE}Masukkan password key:${NC}"
            read -s key_password
            
            cat > android/key.properties << EOF
storePassword=$keystore_password
keyPassword=$key_password
keyAlias=upload
storeFile=upload-keystore.jks
EOF
            
            print_success "key.properties berhasil dibuat"
        else
            print_error "Gagal membuat keystore"
            exit 1
        fi
    else
        print_info "Silakan buat keystore manual dan konfigurasi key.properties"
        exit 1
    fi
else
    print_success "Keystore sudah dikonfigurasi"
fi

# Step 5: Project Cleanup
print_step "Step 5: Project Cleanup"
print_info "Membersihkan project..."
flutter clean
print_success "Project berhasil dibersihkan"

# Step 6: Dependencies
print_step "Step 6: Getting Dependencies"
print_info "Mengunduh dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    print_success "Dependencies berhasil diunduh"
else
    print_error "Gagal mengunduh dependencies"
    exit 1
fi

# Step 7: Code Analysis
print_step "Step 7: Code Analysis"
print_info "Menganalisis kode..."
flutter analyze
if [ $? -eq 0 ]; then
    print_success "Code analysis passed"
else
    print_warning "Code analysis menemukan issues. Lanjutkan? (y/n)"
    read -r continue_build
    if [[ $continue_build != "y" && $continue_build != "Y" ]]; then
        exit 1
    fi
fi

# Step 8: Running Tests
print_step "Step 8: Running Tests"
print_info "Menjalankan tests..."
flutter test
if [ $? -eq 0 ]; then
    print_success "Semua tests passed"
else
    print_warning "Beberapa tests gagal. Lanjutkan? (y/n)"
    read -r continue_build
    if [[ $continue_build != "y" && $continue_build != "Y" ]]; then
        exit 1
    fi
fi

# Step 9: Build Selection
print_step "Step 9: Build Selection"
echo -e "${WHITE}Pilih jenis build:${NC}"
echo -e "${BLUE}1) APK (untuk testing/sideload)${NC}"
echo -e "${BLUE}2) App Bundle (untuk Play Store)${NC}"
echo -e "${BLUE}3) Keduanya${NC}"
read -r build_choice

# Step 10: Building
print_step "Step 10: Building Application"

case $build_choice in
    1)
        print_info "Building APK..."
        flutter build apk --release --verbose
        if [ $? -eq 0 ]; then
            APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
            APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
            print_success "APK build berhasil!"
            print_info "Location: $APK_PATH"
            print_info "Size: $APK_SIZE"
        else
            print_error "APK build gagal!"
            exit 1
        fi
        ;;
    2)
        print_info "Building App Bundle..."
        flutter build appbundle --release --verbose
        if [ $? -eq 0 ]; then
            AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
            AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
            print_success "App Bundle build berhasil!"
            print_info "Location: $AAB_PATH"
            print_info "Size: $AAB_SIZE"
        else
            print_error "App Bundle build gagal!"
            exit 1
        fi
        ;;
    3)
        print_info "Building APK..."
        flutter build apk --release --verbose
        if [ $? -eq 0 ]; then
            APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
            APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
            print_success "APK build berhasil!"
        else
            print_error "APK build gagal!"
            exit 1
        fi
        
        print_info "Building App Bundle..."
        flutter build appbundle --release --verbose
        if [ $? -eq 0 ]; then
            AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
            AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
            print_success "App Bundle build berhasil!"
        else
            print_error "App Bundle build gagal!"
            exit 1
        fi
        ;;
    *)
        print_error "Pilihan tidak valid!"
        exit 1
        ;;
esac

# Step 11: Build Summary
print_header "${SUCCESS} BUILD COMPLETED SUCCESSFULLY!"

echo -e "${WHITE}📊 Build Summary:${NC}"
if [ ! -z "$APK_PATH" ]; then
    echo -e "${GREEN}${PHONE} APK: $APK_PATH ($APK_SIZE)${NC}"
fi
if [ ! -z "$AAB_PATH" ]; then
    echo -e "${GREEN}${PACKAGE} App Bundle: $AAB_PATH ($AAB_SIZE)${NC}"
fi

echo -e "\n${WHITE}🎯 Next Steps:${NC}"
echo -e "${BLUE}1. Test APK di device Android${NC}"
echo -e "${BLUE}2. Upload App Bundle ke Google Play Console${NC}"
echo -e "${BLUE}3. Complete store listing${NC}"
echo -e "${BLUE}4. Submit untuk review${NC}"

echo -e "\n${WHITE}📱 Install APK ke device:${NC}"
if [ ! -z "$APK_PATH" ]; then
    echo -e "${CYAN}adb install $APK_PATH${NC}"
fi

echo -e "\n${GREEN}${ROCKET} Selamat! Aplikasi Android Anda siap untuk distribusi!${NC}"

# Optional: Open build folder
echo -e "\n${YELLOW}Buka folder build? (y/n)${NC}"
read -r open_folder
if [[ $open_folder == "y" || $open_folder == "Y" ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open build/app/outputs/
    elif command -v open &> /dev/null; then
        open build/app/outputs/
    else
        print_info "Folder build: build/app/outputs/"
    fi
fi

print_success "Build script selesai!"
