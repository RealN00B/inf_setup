#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

SPINNER=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')

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

# Clone with re-clone confirmation and return status
clone_repo() {
  local url="$1"
  local path="$2"
  local branch="${3:-}"
  local depth="${4:-}"
  local was_cloned=0
  
  local cmd="git clone"
  [ -n "$branch" ] && cmd+=" --branch $branch"
  [ -n "$depth" ] && cmd+=" --depth $depth"
  cmd+=" $url $path"
  
  if [ -d "$path" ]; then
    echo -e "${YELLOW}⚠️ Directory $path already exists.${RESET}"
    read -p "Do you want to re-clone it? (Y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${YELLOW}🗑️ Removing $path...${RESET}"
      rm -rf "$path" & spinner "Removing old $path"
      
      echo -e "${BLUE}🌀 Cloning ${YELLOW}${path}${BLUE}...${RESET}"
      eval "$cmd" & spinner "Cloning $path"
      was_cloned=1
    else
      echo -e "${GREEN}✅ Skipping $path - using existing directory${RESET}"
      was_cloned=0
    fi
  else
    echo -e "${BLUE}🌀 Cloning ${YELLOW}${path}${BLUE}...${RESET}"
    eval "$cmd" & spinner "Cloning $path"
    was_cloned=1
  fi
  
  return $was_cloned
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

# Update keys.mk file
update_keys_mk() {
  local keys_dir="vendor/lineage-priv/keys"
  local keys_file="$keys_dir/keys.mk"
  
  echo -e "${CYAN}🔄 Updating keys.mk file...${RESET}"
  
  if [ -f "$keys_file" ]; then
    sed -i 's/PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor\/infinity-priv\/keys\/testkey/PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor\/lineage-priv\/keys\/testkey/g' "$keys_file"
    echo -e "${GREEN}✅ Successfully updated keys.mk${RESET}"
  else
    echo -e "${RED}❌ keys.mk file not found at $keys_file${RESET}"
    exit 1
  fi
}

# Main script
main() {
  local keys_was_cloned=0
  
  # ========== Device Components ==========
  echo -e "${MAGENTA}📦 Cloning device repositories...${RESET}"
  clone_repo "https://github.com/RealN00B/device_xiaomi_redwood_new.git" "device/xiaomi/redwood" "A16-Axion"
  clone_repo "https://github.com/RealN00B/vendor_xiaomi_redwood_new.git" "vendor/xiaomi/redwood" "A16"
  clone_repo "https://codeberg.org/AnupamADDas/redwood-miuicamera" "vendor/xiaomi/redwood-miuicamera" "" "1"
  clone_repo "https://github.com/RealN00B/Kernel_KT.git" "kernel/xiaomi/redwood" "V17"
  clone_repo "https://github.com/LineageOS/android_hardware_sony_timekeep.git" "hardware/sony/timekeep"
  clone_repo "https://github.com/PixelCore-OS/hardware_xiaomi.git" "hardware/xiaomi"
  
  # Clone private keys and track if it was cloned/re-cloned
  echo -e "${MAGENTA}🔑 Cloning private keys...${RESET}"
  if clone_repo "https://github.com/ProjectInfinity-X/vendor_infinity-priv_keys.git" "vendor/lineage-priv/keys" "" ""; then
    keys_was_cloned=1
  fi
  
  # Only update keys.mk if the keys repository was just cloned or re-cloned
  if [ $keys_was_cloned -eq 1 ]; then
    update_keys_mk
  else
    echo -e "${YELLOW}⚠️ Skipping keys.mk update - using existing keys directory${RESET}"
  fi
  
  # Initialize kernel submodules only if kernel was cloned/re-cloned
  if [ -d "kernel/xiaomi/redwood" ]; then
    echo -e "${GREEN}⚙️ Initializing kernel submodules...${RESET}"
    (cd kernel/xiaomi/redwood && git submodule init & spinner "Init submodules")
    (cd kernel/xiaomi/redwood && git submodule update & spinner "Update submodules")
  else
    echo -e "${YELLOW}⚠️ Skipping kernel submodules - kernel directory not found${RESET}"
  fi

  echo -e "${GREEN}✅ All repositories processed successfully!${RESET}"
  echo -e "${CYAN}🚀 Happy building...${RESET}"
}

main
