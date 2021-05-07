#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi
artsh_dir=$(pwd)
profile=$(cat $artsh_dir/.profile)
rtfs_dir=$(cat $artsh_dir/.rtfs)
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
echo "/home/$SUDO_USER/artools-workspace/iso/$profile" > $artsh_dir/.iso
chmod +x $artsh_dir/write.sh
#build live system
buildiso -p $profile -xc
buildiso -p $profile -sc
buildiso -p $profile -bc
buildiso -p $profile -zc
