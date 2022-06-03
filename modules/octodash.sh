#!/usr/bin/env bash
#
# Script d'installation d'octodash
#
source /home/pi/voron/modules/_common.sh

sudo echo "" > /dev/null
_log "=> OctoDash"


##################
### PRE-REQUIS ###
##################
_log "  => Pré-requis"
sudo apt install -q -y gir1.2-gnomekeyring-1.0 libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libuuid1 libappindicator3-1 libsecret-1-0 xserver-xorg ratpoison x11-xserver-utils xinit libgtk-3-0 bc desktop-file-utils libavahi-compat-libdnssd1 libpam0g-dev libx11-dev


##################
### PAQUET DEB ###
##################
arch=$(uname -m)
if [[ $arch == x86_64 ]]; then
    releaseURL=$(curl -s "https://api.github.com/repos/UnchartedBull/OctoDash/releases/latest" | grep "browser_download_url.*amd64.deb" | cut -d '"' -f 4)
elif [[ $arch == aarch64 ]]; then
    releaseURL=$(curl -s "https://api.github.com/repos/UnchartedBull/OctoDash/releases/latest" | grep "browser_download_url.*arm64.deb" | cut -d '"' -f 4)
elif  [[ $arch == arm* ]]; then
    releaseURL=$(curl -s "https://api.github.com/repos/UnchartedBull/OctoDash/releases/latest" | grep "browser_download_url.*armv7l.deb" | cut -d '"' -f 4)
fi

# Download deb
_log "  => Téléchargement"
wget -O /tmp/octodash.deb $releaseURL -q --show-progress

# Installation du deb
_log "  => Installation"
sudo dpkg -i /tmp/octodash.deb
rm /tmp/octodash.deb


#####################
### CONFIGURATION ###
#####################
# API
_log "  => Configuration"
_log "    => API"
mkdir -p ${DASH_DIR}
cp -f ${SCRIPT_DIR}/conf/octodash/octodash.json.tpl ${DASH_DIR}/octodash.json
API_KEY=$(yq3 r ${CONF_OCTO} api.key)
if [ "$API_KEY" != "" ]; then
  sed -i "s/API_KEY/${API_KEY}/g" ${DASH_DIR}/octodash.json
fi

_log "    => Theme"
mkdir -p ${SHARE_DIR}
cp -f ${SCRIPT_DIR}/conf/octodash/octodash.css ${DASH_DIR}/octodash.css
cp -f ${SCRIPT_DIR}/conf/octodash/octodash.css ${SHARE_DIR}/octodash-theme.txt

# Config de l'autostart
_log "    => Autostart"
_log "       => Xinit"
cat ${SCRIPT_DIR}/conf/octodash/dot.xinitrc > ${HOME_DIR}/.xinitrc
chmod +x ${HOME_DIR}/.xinitrc
_log "       => Bash"
cat ${SCRIPT_DIR}/conf/octodash/dot.bashrc >> ${HOME_DIR}/.bashrc
_log "       => ZSH"
cat ${SCRIPT_DIR}/conf/octodash/dot.zshrc >> ${HOME_DIR}/.zshrc

# Autologin
_log "    => Autologin"
sudo systemctl set-default multi-user.target
sudo ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
sudo cp -f ${SCRIPT_DIR}/conf/etc/systemd/system/getty@tty1.service.d/autologin.conf /etc/systemd/system/getty@tty1.service.d/autologin.conf
sudo chmod ug+s /usr/lib/xorg/Xorg

# Update
_log "    => Auto-update"
sudo cp -f ${SCRIPT_DIR}/conf/etc/sudoers.d/update-octodash /etc/sudoers.d/update-octodash

# Redémarrage des services
_log "    => Redémarrage des services"
sudo systemctl daemon-reload
sudo service getty@tty1 restart
sleep 5

# Rotation de l'écran
_log "=> Rotation de l'écran"
DISPLAY=:0 xrandr --output HDMI-1 --rotate inverted
DISPLAY=:0 xrandr --output HDMI-2 --rotate normal
XORG_CONF="/usr/share/X11/xorg.conf.d/40-libinput.conf"
if [ -e ${XORG_CONF} ]; then
	sudo cp -f ${XORG_CONF} ${XORG_CONF}.origin
	sudo sed -i "s/MatchIsTouchscreen \"on\"/MatchIsTouchscreen \"on\"\r\n\tOption \"TransformationMatrix\" \"-1 0 1 0 -1 1 0 0 1\"/g" /usr/share/X11/xorg.conf.d/40-libinput.conf
fi
sed -i "s/#DISPLAY/DISPLAY/g" ~/.xinitrc
