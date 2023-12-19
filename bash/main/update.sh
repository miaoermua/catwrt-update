#!/bin/bash
###
# @Author: timochan
# @Date: 2023-02-03 19:45:22
 # @LastEditors: 2860950766@qq.com
 # @LastEditTime: 2023-10-17 00:41:42
 # @FilePath: \undefinedd:\Git\catwrt-update\bash\main\update.sh
###

API_URL="https://api.miaoer.xyz/api/v2/snippets/catwrt/update"
VERSION_FILE="/etc/catwrt_release"
links=""

remote_error() {
    echo "Remote $1 get failed for arch: $arch_self, please check your network!"
    exit 1
}
local_error() {
    echo "Local $1 get failed, please check your /etc/catwrt-release!"
    exit 1
}
get_remote_hash() {
    arch_self=$1
    version_remote=$(curl -s "$API_URL" | jq -r ".$arch_self.version")
    hash_remote=$(curl -s "$API_URL" | jq -r ".$arch_self.hash")

    if [ $? -ne 0 ] || [ -z "$version_remote" ] || [ -z "$hash_remote" ]; then
        remote_error "version or hash"
    fi
}
init() {
    if [ ! -f "$VERSION_FILE" ]; then
        local_error "version file"
    fi

    version_local=$(grep 'version' "$VERSION_FILE" | cut -d '=' -f 2)
    hash_local=$(grep 'hash' "$VERSION_FILE" | cut -d '=' -f 2)
    source_local=$(grep 'source' "$VERSION_FILE" | cut -d '=' -f 2)
    arch_local=$(grep 'arch' "$VERSION_FILE" | cut -d '=' -f 2)
}
contrast_version() {
    if [ "$version_remote" == "$version_local" ] && [ "$hash_remote" == "$hash_local" ]; then
        echo "================================"
        echo "Your CatWrt is up to date!"
        echo "================================"
    else
        echo "================================"
        echo "Your CatWrt is out of date, you should upgrade it!"
        echo "You can visit 'https://www.miaoer.xyz/posts/network/catwrt' to get more information!"
        echo "================================"
    fi
}
print_version() {
    echo "Local  Version : $version_local"
    echo "Remote Version : $version_remote"
    echo "Local  Hash    : $hash_local"
    echo "Remote Hash    : $hash_remote"
    echo "================================"

    if [ "$arch_local" = "amd64" ]; then
         links=$(curl -s $API_URL | jq -r '.amd64.links')
         echo x86_64 Latest: $links
        elif [ "$arch_local" = "mt798x" ]; then
            links=$(curl -s $API_URL | jq -r '.mt798x.links')
            echo x86_64 Latest: $links
        fi
}
sysupgrade() {
if [ "$arch_local" = "amd64" ]; then

  amd64_sysup=$(curl -s $API_URL | jq -r '.amd64.sysup')

  if fdisk -l | grep -q sda128; then
    # EFI Boot
    echo "EFI Boot detected. Recommend upgrade command:" 
    echo $amd64_sysup

  elif fdisk -l | grep -q mmcblk0p; then
    # eMMC boot  
    echo "eMMC Boot detected. sysupgrade is not supported currently."
    echo "Please visit https://www.miaoer.xyz for other upgrade solutions."
  
  else
    # Legacy BIOS Boot
    amd64_sysup_legacy=$(curl -s $API_URL | jq -r '.amd64.sysuplegacy')
    echo "Legacy BIOS Boot detected. Recommend upgrade command:"
    echo $amd64_sysup_legacy
  fi

fi
}
main() {
    init
    get_remote_hash "$arch_local"
    contrast_version
    print_version
    sysupgrade
}
main
