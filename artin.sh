#! /bin/bash
pacman-key --init
pacman-key --populate
pacman-ley --populate artix
pacman-key --refresh-keys
pacman -Syyu --noconfirm
pacman -S linux-hardened fakeroot git curl wget tor-openrc qtox gcc make firefox-developer-edition electrum telegram-desktop qbittorrent veracrypt keepassxc monero-gui bleachbit dnscrypt-proxy-openrc go base-devel --noconfirm --needed

git clone https://github.com/causticheshire/Proxybound.git
cd Proxybound
./configure
make
make install
cp src/proxybound.conf /etc/
sed -i 's/socks4  127.0.0.1 9050/socks5\t192.168.8.1\t9050/' /etc/proxybound.conf
cd /home/$SUDO_USER
echo 'alias pme="export PROXYBOUND_QUIET_MODE="1" && export LD_PRELOAD=/usr/local/lib/libproxybound.so && export PROXYBOUND_CONF_FILE=/etc/proxybound.conf && curl ipinfo.io"' >> .bashrc
