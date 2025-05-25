#!/bin/bash

# 🔐 Keystore Creation Script for AI Resume Generator
# ==================================================

# Colors for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}🔐 KEYSTORE CREATION WIZARD${NC}"
echo -e "${BLUE}=============================${NC}\n"

echo -e "${CYAN}Selamat datang di Keystore Creation Wizard!${NC}"
echo -e "${YELLOW}Keystore adalah file yang berisi kunci digital untuk menandatangani aplikasi Android.${NC}"
echo -e "${YELLOW}File ini WAJIB untuk upload ke Google Play Store.${NC}\n"

echo -e "${PURPLE}📋 Yang akan kita buat:${NC}"
echo -e "   • File keystore (.jks)"
echo -e "   • File key.properties"
echo -e "   • Backup instructions"
echo -e "   • Security guidelines\n"

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}❌ keytool tidak ditemukan!${NC}"
    echo -e "${YELLOW}Install Java JDK terlebih dahulu.${NC}"
    exit 1
fi

# Check if keystore already exists
if [ -f "android/upload-keystore.jks" ]; then
    echo -e "${YELLOW}⚠️  Keystore sudah ada!${NC}"
    read -p "Apakah Anda ingin membuat keystore baru? (y/N): " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}✅ Menggunakan keystore yang sudah ada.${NC}"
        exit 0
    fi
    echo -e "${YELLOW}🗑️  Menghapus keystore lama...${NC}"
    rm -f android/upload-keystore.jks android/key.properties
fi

# Create android directory if not exists
mkdir -p android

echo -e "${BLUE}📝 INFORMASI DEVELOPER${NC}"
echo -e "${BLUE}=====================${NC}\n"

# Get developer information with defaults
read -p "Nama lengkap Anda [Visha Developer]: " full_name
full_name=${full_name:-"Visha Developer"}

read -p "Nama perusahaan/organisasi [Visha Tech]: " organization
organization=${organization:-"Visha Tech"}

read -p "Kota [Jakarta]: " city
city=${city:-"Jakarta"}

read -p "Provinsi/State [DKI Jakarta]: " state
state=${state:-"DKI Jakarta"}

read -p "Kode negara [ID]: " country
country=${country:-"ID"}

echo -e "\n${BLUE}🔒 KONFIGURASI PASSWORD${NC}"
echo -e "${BLUE}=======================${NC}\n"

echo -e "${YELLOW}PENTING: Simpan password ini dengan aman!${NC}"
echo -e "${YELLOW}Jika hilang, Anda tidak bisa update aplikasi di Play Store.${NC}\n"

# Get passwords with validation
while true; do
    read -s -p "Password keystore (min 8 karakter): " store_password
    echo
    if [ ${#store_password} -lt 8 ]; then
        echo -e "${RED}❌ Password harus minimal 8 karakter!${NC}"
        continue
    fi
    read -s -p "Konfirmasi password keystore: " store_password_confirm
    echo
    if [ "$store_password" != "$store_password_confirm" ]; then
        echo -e "${RED}❌ Password tidak cocok!${NC}"
        continue
    fi
    break
done

while true; do
    read -s -p "Password key (min 8 karakter): " key_password
    echo
    if [ ${#key_password} -lt 8 ]; then
        echo -e "${RED}❌ Password harus minimal 8 karakter!${NC}"
        continue
    fi
    read -s -p "Konfirmasi password key: " key_password_confirm
    echo
    if [ "$key_password" != "$key_password_confirm" ]; then
        echo -e "${RED}❌ Password tidak cocok!${NC}"
        continue
    fi
    break
done

echo -e "\n${BLUE}🔧 MEMBUAT KEYSTORE...${NC}"
echo -e "${BLUE}=====================${NC}\n"

# Create keystore with progress
echo -e "${CYAN}📦 Generating RSA key pair...${NC}"
keytool -genkey -v \
    -keystore android/upload-keystore.jks \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias upload \
    -dname "CN=$full_name, OU=$organization, L=$city, ST=$state, C=$country" \
    -storepass "$store_password" \
    -keypass "$key_password" \
    2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Keystore berhasil dibuat!${NC}"
    
    # Create key.properties
    echo -e "${CYAN}📝 Creating key.properties...${NC}"
    cat > android/key.properties << EOF
storePassword=$store_password
keyPassword=$key_password
keyAlias=upload
storeFile=upload-keystore.jks
EOF
    
    echo -e "${GREEN}✅ key.properties berhasil dibuat!${NC}"
    
    # Show keystore info
    echo -e "\n${BLUE}📊 INFORMASI KEYSTORE${NC}"
    echo -e "${BLUE}====================${NC}\n"
    
    keystore_info=$(keytool -list -v -keystore android/upload-keystore.jks -storepass "$store_password" 2>/dev/null)
    
    echo -e "${CYAN}📁 File Location:${NC} android/upload-keystore.jks"
    echo -e "${CYAN}🔑 Alias:${NC} upload"
    echo -e "${CYAN}🔐 Algorithm:${NC} RSA"
    echo -e "${CYAN}📏 Key Size:${NC} 2048 bits"
    echo -e "${CYAN}⏰ Validity:${NC} 10000 days (~27 years)"
    echo -e "${CYAN}👤 Owner:${NC} $full_name"
    echo -e "${CYAN}🏢 Organization:${NC} $organization"
    
    # Get file size
    keystore_size=$(ls -lh android/upload-keystore.jks | awk '{print $5}')
    echo -e "${CYAN}📦 File Size:${NC} $keystore_size"
    
    # Security instructions
    echo -e "\n${YELLOW}🛡️  INSTRUKSI KEAMANAN PENTING${NC}"
    echo -e "${YELLOW}===============================${NC}\n"
    
    echo -e "${RED}⚠️  BACKUP WAJIB:${NC}"
    echo -e "   1. 📁 Backup file: ${CYAN}android/upload-keystore.jks${NC}"
    echo -e "   2. 📄 Backup file: ${CYAN}android/key.properties${NC}"
    echo -e "   3. 💾 Simpan di cloud storage (Google Drive, Dropbox)"
    echo -e "   4. 📧 Email ke diri sendiri sebagai backup"
    echo -e "   5. 🔒 Simpan password di password manager\n"
    
    echo -e "${RED}❌ JANGAN LAKUKAN:${NC}"
    echo -e "   • Commit keystore ke Git repository"
    echo -e "   • Share keystore di public forum"
    echo -e "   • Simpan password di plain text"
    echo -e "   • Lupa backup keystore\n"
    
    # Create backup script
    echo -e "${CYAN}📦 Creating backup script...${NC}"
    cat > scripts/backup_keystore.sh << 'EOF'
#!/bin/bash

# Keystore Backup Script
echo "🔐 Backing up keystore files..."

# Create backup directory with timestamp
backup_dir="keystore_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Copy keystore files
cp android/upload-keystore.jks "$backup_dir/"
cp android/key.properties "$backup_dir/"

# Create README
cat > "$backup_dir/README.txt" << 'BACKUP_EOF'
KEYSTORE BACKUP
===============

Files in this backup:
- upload-keystore.jks: The keystore file (KEEP SECURE!)
- key.properties: Password configuration (KEEP SECURE!)

IMPORTANT:
- These files are required to update your app on Google Play Store
- If lost, you cannot update your app - only publish a new one
- Store in multiple secure locations
- Never share publicly

Backup created: $(date)
BACKUP_EOF

echo "✅ Backup created in: $backup_dir"
echo "📧 Consider uploading to cloud storage!"
EOF
    
    chmod +x scripts/backup_keystore.sh
    echo -e "${GREEN}✅ Backup script created: scripts/backup_keystore.sh${NC}"
    
    # Update .gitignore
    echo -e "${CYAN}🔒 Updating .gitignore...${NC}"
    if ! grep -q "upload-keystore.jks" .gitignore 2>/dev/null; then
        echo -e "\n# Keystore files (NEVER commit these!)" >> .gitignore
        echo "android/upload-keystore.jks" >> .gitignore
        echo "android/key.properties" >> .gitignore
        echo "keystore_backup_*/" >> .gitignore
    fi
    echo -e "${GREEN}✅ .gitignore updated${NC}"
    
    # Final success message
    echo -e "\n${GREEN}🎉 KEYSTORE CREATION COMPLETED!${NC}"
    echo -e "${GREEN}================================${NC}\n"
    
    echo -e "${BLUE}📋 NEXT STEPS:${NC}"
    echo -e "   1. 💾 Run backup script: ${CYAN}./scripts/backup_keystore.sh${NC}"
    echo -e "   2. ☁️  Upload backup to cloud storage"
    echo -e "   3. 🔒 Save passwords in password manager"
    echo -e "   4. 🚀 Ready to build release APK!"
    
    echo -e "\n${BLUE}🔧 BUILD COMMANDS:${NC}"
    echo -e "   • Debug APK: ${CYAN}flutter build apk --debug${NC}"
    echo -e "   • Release APK: ${CYAN}flutter build apk --release${NC}"
    echo -e "   • App Bundle: ${CYAN}flutter build appbundle --release${NC}"
    
else
    echo -e "${RED}❌ Gagal membuat keystore!${NC}"
    echo -e "${YELLOW}Periksa instalasi Java JDK dan coba lagi.${NC}"
    exit 1
fi
