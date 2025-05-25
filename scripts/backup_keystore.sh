#!/bin/bash

# 🔐 Keystore Backup Script
# =========================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔐 KEYSTORE BACKUP UTILITY${NC}"
echo -e "${BLUE}==========================${NC}\n"

# Check if keystore exists
if [ ! -f "android/upload-keystore.jks" ]; then
    echo -e "${YELLOW}⚠️  Keystore not found! Create keystore first.${NC}"
    exit 1
fi

# Create backup directory with timestamp
backup_dir="keystore_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

echo -e "${CYAN}📦 Creating backup in: $backup_dir${NC}"

# Copy keystore files
cp android/upload-keystore.jks "$backup_dir/"
cp android/key.properties "$backup_dir/"

# Create README
cat > "$backup_dir/README.txt" << EOF
KEYSTORE BACKUP - AI Resume Generator
====================================

Files in this backup:
- upload-keystore.jks: The keystore file (KEEP SECURE!)
- key.properties: Password configuration (KEEP SECURE!)

CRITICAL INFORMATION:
- These files are required to update your app on Google Play Store
- If lost, you cannot update your app - only publish a new one
- Store in multiple secure locations (cloud storage, external drive)
- Never share publicly or commit to version control

App: AI Resume Generator
Package: com.visha.airesume
Backup created: $(date)
Keystore validity: 10000 days (~27 years)

BACKUP LOCATIONS RECOMMENDED:
1. Google Drive / Dropbox / OneDrive
2. External USB drive
3. Email to yourself
4. Password manager vault
5. Physical printout (for passwords)

RECOVERY INSTRUCTIONS:
If you need to restore:
1. Copy upload-keystore.jks to android/ folder
2. Copy key.properties to android/ folder
3. Verify with: keytool -list -v -keystore android/upload-keystore.jks
EOF

# Create verification script
cat > "$backup_dir/verify_keystore.sh" << 'EOF'
#!/bin/bash
echo "🔍 Verifying keystore..."
if [ -f "upload-keystore.jks" ]; then
    keytool -list -v -keystore upload-keystore.jks
else
    echo "❌ Keystore file not found!"
fi
EOF

chmod +x "$backup_dir/verify_keystore.sh"

# Show backup summary
echo -e "${GREEN}✅ Backup completed successfully!${NC}\n"

echo -e "${BLUE}📊 BACKUP SUMMARY:${NC}"
echo -e "   📁 Location: ${CYAN}$backup_dir${NC}"
echo -e "   📦 Files: ${CYAN}$(ls -1 $backup_dir | wc -l) files${NC}"
echo -e "   💾 Size: ${CYAN}$(du -sh $backup_dir | cut -f1)${NC}"

echo -e "\n${BLUE}📋 FILES BACKED UP:${NC}"
ls -la "$backup_dir"

echo -e "\n${YELLOW}🚨 IMPORTANT NEXT STEPS:${NC}"
echo -e "   1. 📧 Email backup to yourself"
echo -e "   2. ☁️  Upload to cloud storage (Google Drive, Dropbox)"
echo -e "   3. 💾 Copy to external USB drive"
echo -e "   4. 🔒 Save passwords in password manager"
echo -e "   5. 🖨️  Print passwords and store securely"

echo -e "\n${CYAN}💡 TIP: Set calendar reminder to backup keystore monthly!${NC}"
