#!/bin/bash
###
 # @Author: timochan
 # @Date: 2023-02-03 19:45:22
 # @LastEditors: timochan,miaoermua
 # @LastEditTime: 2023-4-17 14:05:21
 # @FilePath: /miaoermua/catwrt-update/bash/catwrt-update_6.1.sh
### 
remote_error() {
    echo "Remote $1 get failed, please check your network!"
    exit 1
}
local_error() {
    echo "Local $1 get failed, please check your /etc/catwrt_release!"
    exit 1
}
get_remote_version(){
    arch_self=$1
    if [ $arch_self == "x86_64" ]; then
    version_remote=`curl https://api.miaoer.xyz/api/v2/snippets/catwrt/check_update_DEV | jq -r '.version_amd64'`
    elif [ $arch_self == "aarch64" ]; then
    version_remote=`curl https://api.miaoer.xyz/api/v2/snippets/catwrt/check_update_DEV | jq -r '.version_rkarm'`
    elif [ $arch_self == "mips" ]; then
    version_remote=`curl https://api.miaoer.xyz/api/v2/snippets/catwrt/check_update_DEV | jq -r '.version_wireless'`
    fi

    if [ $arch_self == "x86_64" ]; then
        hash_remote=`curl https://api.miaoer.xyz/api/v2/snippets/catwrt/check_update_DEV | jq -r '.hash_amd64'`
    elif [ $arch_self == "aarch64" ]; then
        hash_remote=`curl https://api.miaoer.xyz/api/v2/snippets/catwrt/check_update_DEV | jq -r '.hash_rkarm'`
    elif [ $arch_self == "mips" ]; then
        hash_remote=`curl https://api.miaoer.xyz/api/v2/snippets/catwrt/check_update_DEV | jq -r '.hash_wireless'`
    else 
        echo "Your system is not supported!"
        exit 1
    fi

    if [ $? -ne 0 ] || [ -z $hash_remote ]; then
        remote_error "hash"
        exit 1
    fi
}
get_arch_and_remote_version() {
    arch=`uname -m`
    if [ $? -ne 0 ] || [ -z $arch ]; then
        echo "Arch get failed, Please contact the firmware author!"
        exit 1
    fi

    get_remote_version $arch

}
get_local_version(){

    if [ ! -f /etc/catwrt-release ]; then
        local_error "version file"
        exit 1
    fi
    version_local=`cat /etc/catwrt_release | grep 'ver' | cut -d '=' -f 2`
    hash_local=`cat /etc/catwrt_release | grep 'hash' | cut -d '=' -f 2`


}
contrast_version(){
    if [ $version_remote == $version_local ] && [ $hash_remote == $hash_local ]; then
        echo "======================================"
        echo "Your CatWrt is up to date!"
        echo "======================================"
    else
        echo "======================================"
        echo "Your CatWrt is not up to date, You should upgrade it!"
        echo "You can visit 'https://www.miaoer.xyz/posts/network/catwrt' to get more information!"
        echo "======================================"
    fi
}
print_version(){
        echo "Local  Version : $version_local"
        echo "Remote Version : $version_remote"
        echo "Local  Hash : $hash_local"
        echo "Remote Hash : $hash_remote"
        echo "======================================"
}
main(){
    get_arch_and_remote_version
    get_local_version
    contrast_version
    print_version
}
main