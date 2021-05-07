#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi
artsh_dir=$(pwd)
write_sc=$artsh_dir/write.sh
bash $write_sc
local date_now=$(date +'%Y%m%d')
read -n 1 -s -r -p "Pls connect device and press any button to continue"
read -r -p "Use ventoy? - [Y/n]: " -e -i "Y" vtny
if [[ "$vtny" == "Y" ]] || [[ "$vtny" == "y" ]]; then
    echo "Select device - use only device name (not partition) from NAME column"
    echo "ALL DATA WILL BE CLEARED"
    lsblk -f
    read -r -p "Select a disk (sdX): " -e -i "/dev/sd" sdxx
    echo "Create label for device, dnt use system names"
    read -r -p "Create label: " -e -i "ART" lbl
    ventoy -s -g -I $sdxx -L $lbl
    mkdir /mnt/$lbl
    local sdxa=${sdxx}1
    mount $sdxa /mnt/$lbl
    echo "Wait - copy iso to device"
    rsync $iso_dir/artix-$profile-openrc-$date_now-x86_64.iso /mnt/$lbl/xfce.iso
    local sum0=$(md5sum $iso_dir/artix-$profile-openrc-$date_now-x86_64.iso | cut -c1-32)
    local sum1=$(md5sum /mnt/$lbl/xfce.iso | cut -c1-32)
    if [[ "$sum0" == "$sum1" ]]; then
        umount $sdxa
        eject $sdxx
        echo "Successful"
    else
        echo "Iso corrupted, pls contact with administrator"
    fi
else
    echo "Select device - use only device name (not partition) from NAME column"
    echo "ALL DATA WILL BE CLEARED"
    lsblk -f
    read -r -p "Select a disk (sdX): " -e -i "/dev/sd" sdxx
    echo "Writing..."
    dd if=$iso_dir/artix-$profile-openrc-$date_now-x86_64.iso of=$sdxx bs=1M status=progress
    echo "Successful"
    eject $sdxx
fi
exit 1