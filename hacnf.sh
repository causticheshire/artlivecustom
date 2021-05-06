#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi
artsh_dir=$(pwd)
# install requirements
pacman-key --init
pacman-key --populate
#pacman-key --populate artix
pacman-key --refresh-keys
pacman -Syyu --noconfirm
modprobe loop
modprobe overlay
pacman -S artools iso-profiles git base-devel go --needed --noconfirm
sudo --user=$SUDO_USER git clone https://aur.archlinux.org/yay.git
cd yay
sudo --user=$SUDO_USER makepkg -si --noconfirm
cd $artsh_dir
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
echo "#!/bin/bash
profile=$profile
rtfs_dir=/var/lib/artools/buildiso/$profile/artix/rootfs
export artsh_dir profile rtfs_dir
" > $artsh_dir/conf.sh
chmod +x $artsh_dir/conf.sh
#test profile
buildiso -p $profile