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

# Remove directory and clone new repository
replace_repo() {
  local path="$1"
  local url="$2"
  local branch="${3:-}"
  
  echo -e "${YELLOW}🗑️ Removing $path...${RESET}"
  rm -rf "$path" & spinner "Removing $path"
  
  clone_repo "$url" "$path" "$branch"
}

# Main script
main() {
  # ========== Device Components ==========
  clone_repo "https://github.com/RealN00B/device_xiaomi_redwood_new.git" "device/xiaomi/redwood" "A16"
  clone_repo "https://github.com/RealN00B/vendor_xiaomi_redwood_new.git" "vendor/xiaomi/redwood" "A16"
  clone_repo "https://codeberg.org/AnupamADDas/redwood-miuicamera" "vendor/xiaomi/redwood-miuicamera" "" "1"
  clone_repo "https://github.com/RealN00B/Kernel_KT.git" "kernel/xiaomi/redwood" "V19"
  
  # Initialize kernel submodules
  echo -e "${GREEN}⚙️ Initializing kernel submodules...${RESET}"
  (cd kernel/xiaomi/redwood && git submodule init & spinner "Init submodules")
  (cd kernel/xiaomi/redwood && git submodule update & spinner "Update submodules")

  # ========== Framework and Apps Replacement ==========
  replace_repo "frameworks/base" "https://github.com/RealN00B/framework_b.git" "16-QPR0"
  replace_repo "packages/apps/Settings" "https://github.com/RealN00B/sett.git" "A16"
  replace_repo "packages/apps/PixelParts" "https://github.com/PixelCore-OS/packages_apps_PixelParts.git" "16-staging"
  replace_repo "vendor/gms" "https://codeberg.org/AnupamADDas/vendor_google_gms" "" "1"

  echo -e "${GREEN}✅ All repositories cloned successfully!${RESET}"
  echo -e "${CYAN}🚀 Starting build process...${RESET}"
  echo -e "${YELLOW}⏳ This may take a while, grab some coffee!${RESET}"
}

main
