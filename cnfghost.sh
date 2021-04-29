#! /bin/bash
artsh_dir=$(pwd)
# install requirements
pacman-key --init
pacman-key --populate
pacman-key --populate artix
pacman-key --refresh-keys
pacman -Syyu --noconfirm
modprobe loop
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
    sleep 1
    break
done
#change autologin live system
read -r -p "Enable autologin - [Y/n]: " -e -i $auto Y
if [[ "$auto" == "Y" ]] || [[ "$auto" == "y" ]]; then
    echo "ENABLE AUTOLOGIN"
    sleep 2
    sed -i 's/AUTOLOGIN="true"/AUTOLOGIN="true"/' $work_dir$profile/profile.conf
else
    echo "DISABLE AUTOLOGIN"
    sleep 2
    sed -i 's/AUTOLOGIN="true"/AUTOLOGIN="false"/' $work_dir$profile/profile.conf
fi
#change live system password
read -r -p "Enter password for live system: " -e -i $pasw artix
sed -i 's/# PASSWORD="artix"/PASSWORD="$pasw"/' $work_dir$profile/profile.conf
#change pre-installed packages
#need more work
sed -i 's/connman-gtk//' $work_dir$profile/Packages-Root
sed -i 's/midori/qtox/' $work_dir$profile/Packages-Root
sed -i 's/gparted/#gparted/' $work_dir$profile/Packages-Live
#test profile
buildiso -p $profile -q
sleep 3
#prebuild rootfs live system
buildiso -p $profile
rtfs_dir=/var/lib/artools/buildiso/$profile/artix/rootfs
#install aur packages for integration to live system
cat $artsh_dir/pkgyay.conf | sed s/' '//g | sudo --user=$SUDO_USER yay -S - --noanswerclean --noanswerdiff --noansweredit --noeditmenu --nodiffmenu --noremovemake --noconfirm 

mkdir $rtfs_dir/home/pkgs
find /home/$SUDO_USER/.cache/yay/ -name "*.zst" -exec cp '{}' $rtfs_dir/home/pkgs/ \;
cp $artsh_dir/artin.sh $rtfs_dir
cp $artsh_dir/.post $rtfs_dir
#chroot to rootfs live system
artix-chroot $rtfs_dir


