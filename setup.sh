#!/bin/bash

# ANSI Color Codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Characters
SPINNER=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

spinner() {
  local pid=$!
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %8 ))
    printf "\r[${SPINNER[$i]}] $1"
    sleep 0.1
  done
  printf "\r[✓] $1\n"
}

# Device repo
echo -e "${BLUE}🌀 Cloning ${YELLOW}Device Tree${BLUE}...${RESET}"
git clone https://github.com/RealN00B/device_xiaomi_redwood_new.git device/xiaomi/redwood --branch 15-final & spinner "Cloning Device Tree"

# Kernel repo
echo -e "${BLUE}🌀 Cloning ${YELLOW}Kernel${BLUE}...${RESET}"
git clone https://github.com/RealN00B/Kernel_KT.git kernel/xiaomi/redwood --branch V12 & spinner "Cloning Kernel"

echo -e "${GREEN}⚙️ Initializing kernel submodules...${RESET}"
(cd kernel/xiaomi/redwood && git submodule init & spinner "Init submodules")
(cd kernel/xiaomi/redwood && git submodule update & spinner "Update submodules")

# Vendor repos
echo -e "${BLUE}🌀 Cloning ${YELLOW}Vendor${BLUE}...${RESET}"
git clone https://github.com/RealN00B/vendor_xiaomi_redwood_new.git vendor/xiaomi/redwood --branch 15-final & spinner "Cloning Vendor"

echo -e "${BLUE}🌀 Cloning ${YELLOW}MIUI Camera${BLUE}...${RESET}"
git clone https://codeberg.org/AnupamADDas/redwood-miuicamera vendor/xiaomi/redwood-miuicamera --depth 1 & spinner "Cloning MIUI Camera"

# Connectivity module
echo -e "${RED}♻️ Replacing Connectivity module...${RESET}"
rm -rf packages/modules/Connectivity & spinner "Removing old Connectivity"
echo -e "${BLUE}🌀 Cloning ${YELLOW}Connectivity${BLUE}...${RESET}"
git clone https://android.googlesource.com/platform/packages/modules/Connectivity packages/modules/Connectivity --branch android-15.0.0_r36 --depth 1 & spinner "Cloning Connectivity"

# Netd replacement
echo -e "${RED}♻️ Replacing netd...${RESET}"
rm -rf system/netd & spinner "Removing old netd"
echo -e "${BLUE}🌀 Cloning ${YELLOW}netd${BLUE}...${RESET}"
git clone https://android.googlesource.com/platform/system/netd system/netd --branch android-15.0.0_r36 --depth 1 & spinner "Cloning netd"

# Framework replacements
echo -e "${MAGENTA}🔄 Replacing frameworks...${RESET}"
rm -rf frameworks/base & spinner "Removing old frameworks/base"
echo -e "${BLUE}🌀 Cloning ${YELLOW}frameworks/base${BLUE}...${RESET}"
git clone https://github.com/RealN00B/framework_b.git frameworks/base --branch 15-Final & spinner "Cloning frameworks/base"

rm -rf frameworks/native & spinner "Removing old frameworks/native"
echo -e "${BLUE}🌀 Cloning ${YELLOW}frameworks/native${BLUE}...${RESET}"
git clone https://github.com/RealN00B/frameworks_native.git frameworks/native --branch 15-QPR2 --depth 1 & spinner "Cloning frameworks/native"

# App replacements
echo -e "${CYAN}📱 Replacing apps...${RESET}"
rm -rf packages/apps/Settings & spinner "Removing old Settings"
echo -e "${BLUE}🌀 Cloning ${YELLOW}Settings${BLUE}...${RESET}"
git clone https://github.com/RealN00B/sett.git packages/apps/Settings --branch 15-QPR2 --depth 1 & spinner "Cloning Settings"

rm -rf packages/apps/InfinitySuite & spinner "Removing old InfinitySuite"
echo -e "${BLUE}🌀 Cloning ${YELLOW}InfinitySuite${BLUE}...${RESET}"
git clone https://github.com/RealN00B/packages_apps_InfinitySuite.git packages/apps/InfinitySuite --branch 15-Final & spinner "Cloning InfinitySuite"

rm -rf packages/apps/Launcher3 & spinner "Removing old Launcher3"
echo -e "${BLUE}🌀 Cloning ${YELLOW}Launcher3${BLUE}...${RESET}"
git clone https://github.com/RealN00B/launcher.git packages/apps/Launcher3 --branch 15-QPR2 --depth 1 & spinner "Cloning Launcher3"

rm -rf packages/overlays/Themes & spinner "Removing old Themes"
echo -e "${BLUE}🌀 Cloning ${YELLOW}Themes${BLUE}...${RESET}"
git clone https://github.com/RealN00B/android_packages_overlays_Themes.git packages/overlays/Themes --branch 15-QPR2 --depth 1 & spinner "Cloning Themes"

# Vendor additions
echo -e "${GREEN}🔑 Adding vendor components...${RESET}"
echo -e "${BLUE}🌀 Cloning ${YELLOW}Vendor Keys${BLUE}...${RESET}"
git clone https://github.com/ProjectInfinity-X/vendor_infinity-priv_keys.git vendor/infinity-priv/keys & spinner "Cloning Vendor Keys"

rm -rf vendor/infinity & spinner "Removing old vendor/infinity"
echo -e "${BLUE}🌀 Cloning ${YELLOW}Infinity Vendor${BLUE}...${RESET}"
git clone https://github.com/RealN00B/vendor_infinity.git vendor/infinity --branch 15-QPR2 & spinner "Cloning Infinity Vendor"

rm -rf vendor/extras & spinner "Removing old vendor/extras"
echo -e "${BLUE}🌀 Cloning ${YELLOW}Infinity extras${BLUE}...${RESET}"
git clone https://github.com/RealN00B/vendor_extras.git vendor/extras --branch 15 & spinner "Cloning Infinity extras"

# Core system replacements
echo -e "${YELLOW}⚙️ Updating core system components...${RESET}"
rm -rf art & spinner "Removing old art"
echo -e "${BLUE}🌀 Cloning ${YELLOW}ART${BLUE}...${RESET}"
git clone https://github.com/RealN00B/art.git art --depth 1 & spinner "Cloning ART"

rm -rf bionic & spinner "Removing old bionic"
echo -e "${BLUE}🌀 Cloning ${YELLOW}BIONIC${BLUE}...${RESET}"
git clone https://github.com/RealN00B/bionic.git bionic -b 15-QPR2 --depth 1 & spinner "Cloning BIONIC"

rm -rf system/core & spinner "Removing old system/core"
echo -e "${BLUE}🌀 Cloning ${YELLOW}System Core${BLUE}...${RESET}"
git clone https://github.com/RealN00B/system_core.git system/core --branch 15-QPR2 --depth 1 & spinner "Cloning System Core"

# Hardware addition
echo -e "${CYAN}📌 Adding Sony Timekeep hardware...${RESET}"
git clone https://github.com/LineageOS/android_hardware_sony_timekeep.git hardware/sony/timekeep & spinner "Cloning Sony Timekeep"

rm -rf hardware/xiaomi & spinner "Removing old hardware_xiaomi"
echo -e "${BLUE}🌀 Cloning ${YELLOW}Xiaomi hardware${BLUE}...${RESET}"
git clone https://github.com/RealN00B/hardware_xiaomi.git hardware/xiaomi --branch 15-QPR2 & spinner "Cloning xiaomi hardware"

echo -e "${CYAN}🚀 Starting build process...${RESET}"
echo -e "${YELLOW}⏳ This may take a while, grab some coffee!${RESET}"

sleep 3
