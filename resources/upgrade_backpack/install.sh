#!/bin/bash

# Upgrade Backpack Resource Installation Script
# Author: Nam-codengu

echo "======================================"
echo "UPGRADE BACKPACK RESOURCE INSTALLER"
echo "======================================"
echo ""

# Check if we're in the correct directory
if [ ! -f "fxmanifest.lua" ]; then
    echo "❌ Error: fxmanifest.lua not found!"
    echo "Please run this script from the upgrade_backpack resource directory."
    exit 1
fi

echo "✅ Found fxmanifest.lua - Validating resource structure..."

# Check required files
required_files=(
    "shared/config_backpacks.lua"
    "server/main.lua"
    "client/main.lua"
    "web/build/index.html"
    "web/build/style.css"
    "web/build/app.js"
)

missing_files=()

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -ne 0 ]; then
    echo "❌ Missing required files:"
    printf '   - %s\n' "${missing_files[@]}"
    exit 1
fi

echo "✅ All required files found!"

# Check file sizes (basic validation)
echo ""
echo "📊 File validation:"
echo "   fxmanifest.lua: $(wc -l < fxmanifest.lua) lines"
echo "   config_backpacks.lua: $(wc -l < shared/config_backpacks.lua) lines"
echo "   server/main.lua: $(wc -l < server/main.lua) lines"
echo "   client/main.lua: $(wc -l < client/main.lua) lines"
echo "   web/build/index.html: $(wc -l < web/build/index.html) lines"
echo "   web/build/style.css: $(wc -l < web/build/style.css) lines"
echo "   web/build/app.js: $(wc -l < web/build/app.js) lines"

echo ""
echo "🎯 Installation Instructions:"
echo ""
echo "1. Copy this entire 'upgrade_backpack' folder to your server's resources/ directory"
echo "2. Add to your server.cfg:"
echo "   ensure upgrade_backpack"
echo ""
echo "3. Required dependencies (ensure these are loaded BEFORE upgrade_backpack):"
echo "   - ox_inventory"
echo "   - oxmysql"
echo "   - ox_lib"
echo ""
echo "4. Restart your server or use: restart upgrade_backpack"
echo ""
echo "🎮 Usage:"
echo "   - Press F6 to open upgrade menu"
echo "   - Or use command: /upgrade_backpack"
echo ""
echo "📖 For detailed configuration, see README.md"
echo ""
echo "✅ Resource validation completed successfully!"
echo "✅ Ready for installation!"