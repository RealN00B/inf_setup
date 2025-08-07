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

# Spinner
spinner() {
  local pid=$!
  local i=0
  local delay=0.1
  local msg="$1"
  
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %8 ))
    printf "\r[${SPINNER[$i]}] ${msg}"
    sleep $delay
  done
  
  if wait $pid; then
    printf "\r[✓] ${msg}\n"
  else
    printf "\r[✗] ${msg} - Failed!\n"
    exit 1
  fi
}

# Clone
clone_repo() {
  local url="$1"
  local path="$2"
  local branch="${3:-}"
  local depth="${4:-}"
  
  local cmd="git clone"
  [ -n "$branch" ] && cmd+=" --branch $branch"
  [ -n "$depth" ] && cmd+=" --depth $depth"
  cmd+=" $url $path"
  
  if [ -d "$path" ]; then
    echo -e "${YELLOW}⚠️ Directory $path already exists. Removing...${RESET}"
    rm -rf "$path" & spinner "Removing old $path"
  fi
  
  echo -e "${BLUE}🌀 Cloning ${YELLOW}${path}${BLUE}...${RESET}"
  eval "$cmd" & spinner "Cloning $path"
}

# Main script
main() {
  # ========== Device Components ==========
  clone_repo "https://github.com/RealN00B/device_xiaomi_redwood_new.git" "device/xiaomi/redwood" "15-final"
  clone_repo "https://github.com/RealN00B/vendor_xiaomi_redwood_new.git" "vendor/xiaomi/redwood" "15-final"
  clone_repo "https://codeberg.org/AnupamADDas/redwood-miuicamera" "vendor/xiaomi/redwood-miuicamera" "" "1"
  clone_repo "https://github.com/RealN00B/Kernel_KT.git" "kernel/xiaomi/redwood" "V13"
  
  # Initialize kernel submodules
  echo -e "${GREEN}⚙️ Initializing kernel submodules...${RESET}"
  (cd kernel/xiaomi/redwood && git submodule init & spinner "Init submodules")
  (cd kernel/xiaomi/redwood && git submodule update & spinner "Update submodules")

  # ========== Vendor Components ==========
  clone_repo "https://github.com/ProjectInfinity-X/vendor_infinity-priv_keys.git" "vendor/infinity-priv/keys"
  clone_repo "https://github.com/RealN00B/vendor_infinity.git" "vendor/infinity" "15-QPR2"
  clone_repo "https://github.com/RealN00B/vendor_extras.git" "vendor/extras" "15"

  # ========== Frameworks ==========
  clone_repo "https://github.com/RealN00B/framework_b.git" "frameworks/base" "15-Final"
  clone_repo "https://github.com/RealN00B/frameworks_native.git" "frameworks/native" "15-QPR2" "1"
  clone_repo "https://github.com/RealN00B/frameworks_av.git" "frameworks/av" "15-QPR2"

  # ========== System Components ==========
  clone_repo "https://android.googlesource.com/platform/packages/modules/Connectivity" "packages/modules/Connectivity" "android-15.0.0_r36" "1"
  clone_repo "https://android.googlesource.com/platform/system/netd" "system/netd" "android-15.0.0_r36" "1"
  clone_repo "https://github.com/RealN00B/art.git" "art" "15-QPR2" "1"
  clone_repo "https://github.com/RealN00B/bionic.git" "bionic" "15-QPR2" "1"
  clone_repo "https://github.com/RealN00B/system_core.git" "system/core" "15-QPR2" "1"

  # ========== Apps ==========
  clone_repo "https://github.com/RealN00B/sett.git" "packages/apps/Settings" "15-QPR2" "1"
  clone_repo "https://github.com/RealN00B/packages_apps_InfinitySuite.git" "packages/apps/InfinitySuite" "15-Final"
  clone_repo "https://github.com/RealN00B/launcher.git" "packages/apps/Launcher3" "15-QPR2" "1"
  clone_repo "https://github.com/RealN00B/android_packages_overlays_Themes.git" "packages/overlays/Themes" "15-QPR2" "1"

  # ========== Build System ==========
  clone_repo "https://github.com/RealN00B/build.git" "build/make" "15-QPR2"
  clone_repo "https://github.com/RealN00B/build_soong.git" "build/soong" "15-QPR2"

  # ========== Hardware ==========
  clone_repo "https://github.com/LineageOS/android_hardware_sony_timekeep.git" "hardware/sony/timekeep"
  clone_repo "https://github.com/RealN00B/hardware_xiaomi.git" "hardware/xiaomi" "15-QPR2"
  
  # ========== External Libraries ==========
  clone_repo "https://github.com/RealN00B/external_arm-optimized-routines.git" "external/arm-optimized-routines" "15-QPR2"
  clone_repo "https://github.com/RealN00B/external_jemalloc_new.git" "external/jemalloc_new" "15-QPR2"
  clone_repo "https://github.com/yaap/external_lz4.git" "external/lz4" "fifteen"

  echo -e "${GREEN}✅ All repositories cloned successfully!${RESET}"
  echo -e "${CYAN}🚀 Starting build process...${RESET}"
  echo -e "${YELLOW}⏳ This may take a while, grab some coffee!${RESET}"
}

main
