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
sudo apt install -q -y libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libuuid1 libappindicator3-1 libsecret-1-0 xserver-xorg ratpoison x11-xserver-utils xinit libgtk-3-0 bc desktop-file-utils libavahi-compat-libdnssd1 libpam0g-dev libx11-dev


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
cp -f ${SCRIPT_DIR}/conf/octodash/config.json ${DASH_DIR}/config.json
_config api.allowCrossOrigin true
API_KEY=$(yq3 r ${CONF_OCTO} api.key)
if [ "$API_KEY" != "" ]; then
  sed -i "s/API_KEY/${API_KEY}/g" ${DASH_DIR}/config.json
else
    _log "${RED}Impossible de trouve l'API_KEY pour octodash${NC}"
fi

# Theme
_log "    => Theme"
cp -f ${SCRIPT_DIR}/conf/octodash/octodash.css ${DASH_DIR}/custom-styles.css
cp -f ${SCRIPT_DIR}/conf/octodash/octodash.css ${SHARE_DIR}/octodash-theme.txt


# Autostart
_log "    => Autostart"
_log "      => Xinit"
cp -f ${SCRIPT_DIR}/conf/octodash/dot.xinitrc ~/.xinitrc
sudo chmod +x ~/.xinitrc
_log "      => Bash"
 if [ $(cat ~/.bashrc | grep "# Octodash" | wc -l) -eq 0 ]; then
    cat ${SCRIPT_DIR}/conf/octodash/dot.bashrc >> ~/.bashrc
fi
_log "      => ZSH"
 if [ $(cat ~/.zshrc | grep "# Octodash" | wc -l) -eq 0 ]; then
    cat ${SCRIPT_DIR}/conf/octodash/dot.zshrc >> ~/.zshrc
fi

# Autologin
_log "    => Autologin"
sudo systemctl set-default multi-user.target
sudo mkdir -p /etc/systemd/system/getty.target.wants
sudo ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo cp -f ${SCRIPT_DIR}/conf/etc/systemd/getty@tty1.service.d/autologin.conf /etc/systemd/system/getty@tty1.service.d/autologin.conf
if [ -e /usr/lib/xorg/Xorg ]; then
    sudo chmod ug+s /usr/lib/xorg/Xorg
fi

# Rotation écran
_log "=> Rotation de l'écran"
DISPLAY=:0 xrandr --output HDMI-1 --rotate normal
DISPLAY=:0 xrandr --output HDMI-2 --rotate inverted
#sudo sed -i "s/rootwait/rootwait fbcon=rotate:2/" /boot/cmdline.txt

# Rotation touchscreen
_log "=> Rotation touchscreen"
sudo sed -i "s/MatchIsTouchscreen \"on\"/MatchIsTouchscreen \"on\"\r\n\tOption \"TransformationMatrix\" \"-1 0 1 0 -1 1 0 0 1\"/g" /usr/share/X11/xorg.conf.d/40-libinput.conf

# Plugins
_plugins "Plugins" "https://github.com/jneilliii/OctoPrint-OctoDashCompanion/archive/master.zip"

# Restart service
sudo systemctl daemon-reload
sudo service getty@tty1 restart
