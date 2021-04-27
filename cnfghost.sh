#! /bin/bash
mkdir /home/$SUDO_USER/artlivecustom
cp -r * /home/$SUDO_USER/artlivecustom/
cd /home/$SUDO_USER
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
cd /home/$SUDO_USER
mkdir artools-workspace
cp -r /usr/share/artools/iso-profiles artools-workspace/
echo "Select ur profile:"
select profile in "base" "cinnamon" "common" "community" "community-gtk" "community-qt" "linexa" "lxde" "lxqt" "mate" "plasma" "xfce"
do
    echo "U select " $profile
    break
done
sed -i 's/midori/qtox/' /home/$SUDO_USER/artools-workspace/iso-profiles/$profile/Packages-Root
sed -i 's/gparted//' /home/$SUDO_USER/artools-workspace/iso-profiles/$profile/Packages-Live
buildiso -p $profile -q
sleep 3
buildiso -p $profile
cd /home/$SUDO_USER/artlivecustom/
cat pkgyay.conf | sed s/' '//g | sudo --user=$SUDO_USER yay -S - --noanswerclean --noanswerdiff --noansweredit --noeditmenu --nodiffmenu --noremovemake --noconfirm 

mkdir /var/lib/artools/buildiso/xfce/artix/rootfs/home/pkgs
find /home/$SUDO_USER/.cache/yay/ -name "*.zst" -exec cp '{}' /var/lib/artools/buildiso/xfce/artix/rootfs/home/pkgs/ \;
cp /home/$SUDO_USER/artlivecustom/artin.sh /var/lib/artools/buildiso/xfce/artix/rootfs/
cp /home/$SUDO_USER/artlivecustom/.post /var/lib/artools/buildiso/xfce/artix/rootfs/
artix-chroot /var/lib/artools/buildiso/xfce/artix/rootfs


