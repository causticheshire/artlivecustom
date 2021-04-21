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
echo "Available profiles"
    echo "________________"
    echo "1. base"
    echo "2. cinnamon"
    echo "3. common"
    echo "4. community"
    echo "5. community-gtk"
    echo "6. community-qt"
    echo "7. linexa"
    echo "8. lxde"
    echo "9. lxqt"
    echo "10. mate"
    echo "11. plasma"
    echo "12. xfce"
    echo "________________"
read -r -p "Select ur profile: " -e -i $profile xfce
select profile in "base" "cinnamon" "common" "community" "community-gtk" "community-qt" "linexa" "lxde" "lxqt" "mate" "plasma" "xfce"
do
    echo "U select " $profile
done


buildiso -p $profile -q
sleep 5
buildiso -p $profile
cd /home/$SUDO_USER/artlivecustom/
YPCKGS=`cat pkgyay.conf | tr -s '\r\n' ' '`
artix-chroot /var/lib/artools/buildiso/xfce/artix/rootfs