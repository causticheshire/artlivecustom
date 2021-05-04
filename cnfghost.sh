#!/bin/bash
start=$(date +%M%s)
artsh_dir=$(pwd)
function prehost {
    # install requirements
    pacman-key --init
    pacman-key --populate
    #pacman-key --populate artix
    pacman-key --refresh-keys
    pacman -Syyu --noconfirm
    modprobe loop
    pacman -S artools iso-profiles git base-devel go --needed --noconfirm
    sudo --user=$SUDO_USER git clone https://aur.archlinux.org/yay.git
    cd yay
    sudo --user=$SUDO_USER makepkg -si --noconfirm
    cd $artsh_dir
}
function profiling {
    # copy iso profiles configs
    mkdir /home/$SUDO_USER/artools-workspace
    cp -r /usr/share/artools/iso-profiles /home/$SUDO_USER/artools-workspace/
    work_dir=/home/$SUDO_USER/artools-workspace/iso-profiles/
    #select profile live system
    echo "Select ur profile:"
    select profile in "base" "cinnamon" "common" "community" "community-gtk" "community-qt" "linexa" "lxde" "lxqt" "mate" "plasma" "xfce"
    do
        echo "U select " $profile
        break
    done
    #change autologin live system
    read -r -p "Enable autologin - [Y/n]: " -e -i "Y" auto
    if [[ "$auto" == "Y" ]] || [[ "$auto" == "y" ]]; then
        echo "ENABLE AUTOLOGIN"
        sed -i 's/AUTOLOGIN="true"/AUTOLOGIN="true"/' $work_dir$profile/profile.conf
    else
        echo "DISABLE AUTOLOGIN"
        sed -i 's/AUTOLOGIN="true"/AUTOLOGIN="false"/' $work_dir$profile/profile.conf
    fi
    #change live system password
    read -r -p "Enter password for live system: " -e -i "artix" pasw
    echo 'PASSWORD="'$pasw'"' >> $work_dir$profile/profile.conf
    #change pre-installed packages
    #need more work
    sed -i 's/connman-gtk//' $work_dir$profile/Packages-Root
    sed -i 's/midori/qtox/' $work_dir$profile/Packages-Root
    sed -i 's/gparted/#gparted/' $work_dir$profile/Packages-Live
}
function ptest {
    #test profile
    buildiso -p $profile -q
}
function prebuild {
#prebuild rootfs live system
    buildiso -p $profile
    rtfs_dir=/var/lib/artools/buildiso/$profile/artix/rootfs
}
function pconf {
#chell audio drivers
read -r -p "Install audio drivers HP Chromebook? - [Y/n]: " -e -i "n" audio
if [[ "$audio" == "Y" ]] || [[ "$audio" == "y" ]]; then
    echo "Wait for installing audio drivers"
    git clone --recurse-submodules https://github.com/causticheshire/chell_audio.git
    cp chell_audio/galliumos-skylake/lib/firmware/* $rtfs_dir/lib/firmware
    cp chell_audio/firmware/intel/* $rtfs_dir/lib/firmware/intel/
    cp -r chell_audio/ucm2/* $rtfs_dir/usr/share/alsa/ucm2
    cp -r chell_audio/galliumos-skylake/etc/* $rtfs_dir/etc
    echo "Audio drivers successfully installed"
else
    echo "Drivers will not be installed"
fi
#install aur packages for integration to live system
cat $artsh_dir/pkgyay.conf | sed s/' '//g | sudo --user=$SUDO_USER yay -S - --noanswerclean --noanswerdiff --noansweredit --noeditmenu --nodiffmenu --noremovemake --noconfirm 
#cp aur packages to rootfs
mkdir $rtfs_dir/pkgs
find /home/$SUDO_USER/.cache/yay/ -name "*.zst" -exec cp '{}' $rtfs_dir/pkgs/ \;
#cp scripts for work in chroot
#cp $artsh_dir/artin.sh $rtfs_dir
cp $artsh_dir/.post $rtfs_dir
#chroot to rootfs live system
artix-chroot $rtfs_dir <<EOF
pacman-key --init
pacman-key --populate
pacman-key --refresh-keys
pacman -Syyu --noconfirm
pacman -S linux-hardened fakeroot git curl wget tor-openrc qtox gcc make firefox-developer-edition electrum telegram-desktop qbittorrent veracrypt keepassxc monero-gui bleachbit dnscrypt-proxy-openrc go base-devel --noconfirm --needed
git clone https://github.com/causticheshire/Proxybound.git
cd Proxybound
./configure
make
make install
cp src/proxybound.conf /etc/
cd /
rm -rf Proxybound
pacman -U /home/pkgs/*.zst --noconfirm --needed
sed -i 's/socks4  127.0.0.1 9050/socks5\t192.168.8.1\t9050/' /etc/proxybound.conf
EOF
}
function isobuild {
    #build live system
    buildiso -p $profile -xc
    buildiso -p $profile -sc
    buildiso -p $profile -bc
    buildiso -p $profile -zc
    iso_dir=/home/$SUDO_USER/artools-workspace/iso/$profile
}
function isowrite {
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
}
end=$(date +%M%s)
diff=$($end - $start)
echo $diff


