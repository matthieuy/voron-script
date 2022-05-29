#!/usr/bin/env bash
#
# Lancer en SSH après le 1er boot

#################
### VARIABLES ###
#################
source /home/pi/voron/modules/_common.sh


# Check utilisateur
if [ `whoami` == 'root' ]; then
  _log "${RED}Ne lancez pas ce script en super-admin"
  exit 2
elif [ `whoami` != 'pi' ]; then
  _log "${RED}Lancez ce script avec l'utilisateur par défaut : pi"
  exit 2
fi

# Check dossier
if [ ! -d conf ]; then
  _log "${RED}Lancez ce script depuis ${SCRIPT_DIR}"
  exit 2
fi

# Demande du mdp
echo -ne "${CYAN}Votre mot de passe est necessaire pour l'installation : ${NC}"
read -s PI_PASSWORD
echo -e "${PI_PASSWORD}" | sudo -S ls /tmp > /dev/null
if [ $? -ne 0 ]; then
	echo "Mauvais MDP"
	exit 2
fi

# Changement du mdp
if [ "${PI_PASSWORD}" == "${PI_PASSWORD_DEFAULT}" ]; then
until [ "${PI_PASSWORD}" != "${PI_PASSWORD_DEFAULT}" ]; do
  echo -ne "\n${RED}C'est le bon moment pour changer le mot de passe par défaut !\n${NC}Mot de passe : "
  read -s PI_PASSWORD
done
echo -e "${NC}"
echo -e "${PI_PASSWORD}\n${PI_PASSWORD}" | sudo passwd pi > /dev/null
echo -e "${PI_PASSWORD}\n${PI_PASSWORD}" | sudo passwd > /dev/null
echo -e "${CYAN}Changement du mot de passe par défaut : OK${NC}"
fi
echo -e "\n${RED}/!\ NE VOUS CONNECTEZ PAS SUR OCTOPRINT AVANT LA FIN DE L'INSTALLATION !${NC}"


# Configuration du hostname
read -p "Hostname [${HOSTNAME_DEFAULT}] : " HOSTNAME
if [ "${HOSTNAME}" = "" ]; then
	HOSTNAME=${HOSTNAME_DEFAULT}
fi
echo -ne "${CYAN}=> Change du nom du systeme : ${RED}${HOSTNAME}${NC}"
echo "${HOSTNAME}" | sudo tee /etc/hostname > /dev/null
echo -e "${NC}"
sudo cp -f conf/etc/hosts /etc/hosts
sudo sed -i "s/octopi/${HOSTNAME} octopi/" /etc/hosts


# Création d'un utilisateur octprint
_log "=> Ajout d'un utilisateur ${USERNAME}"
${CMD_OCTO} user add --password "${USERNAME}" --admin ${USERNAME} > /dev/null


# Création du compte de backup
if [ -e conf/rescue-mdp ]; then
  _log "=> Ajout d'un compte \"rescue\""
  MDP_RESCUE=$(cat conf/rescue-mdp)
  sudo useradd -m -p $(openssl passwd -1 ${MDP_RESCUE}) -s /bin/bash -G sudo rescue
  sudo adduser rescue sudo
fi

###############
### UPGRADE ###
###############
_log "=> Upgrade"
_log "  => Suppression logiciels inutiles"
sudo apt remove --purge -y -q bluez-firmware bluez libraspberrypi-doc
_log "  => Dépôt"
sudo apt update -q -y
_log "  => Système"
sudo apt full-upgrade -y

# Génération du support clavier
_log "=> Passage en français"
sudo locale-gen


# Installation globale
_log "=> Installation de paquets de base"
sudo apt install -y tree zsh autojump fbi rsync

# NPM (GPIO serveur)
_log" => NodeJS"
sudo apt install -y --no-install-recommends nodejs npm


# Crontab
_log "  => Crontab"
sudo cp -f ${SCRIPT_DIR}/conf/etc/cron.d/voron-cron /etc/cron.d/voron-cron
sudo chmod +x /etc/cron.d/voron-cron


# wiringPI
_log "=> WiringPI"
wget https://project-downloads.drogon.net/wiringpi-latest.deb -O /tmp/wiringpi.deb
sudo dpkg -i /tmp/wiringpi.deb
rm -f /tmp/wiringpi.deb


# Oh my ZSH
_log "=> Oh my ZSH"
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc
sed -i 's/# ENABLE_CORRECTION/ENABLE_CORRECTION/' ~/.zshrc
sed -i 's/plugins=(/plugins=(autojump command-not-found sudo common-aliases debian /' ~/.zshrc
sudo chsh -s /usr/bin/zsh $(whoami)


# Klipper
_log "=> Klipper"
. ${SCRIPT_DIR}/scripts/update-klipper.sh

# Led IDE
echo mmc0 | sudo tee /sys/class/leds/led0/trigger > /dev/null # cpu0 (charge CPU) ou mmc0 (lecture carte SD)


# Octoprint
_log "=> Octoprint"
# Configuration octoprint de base
_log "  => Configuration de l'API"
API_KEY=$(head -c16 </dev/urandom|xxd -p -u)
echo -e "${CYAN}  => Génération d'une clé : ${RED}${API_KEY}${NC}"
_config api.enabled true "Activation"
_config api.allowCrossOrigin true
_config api.key ${API_KEY}
_config accessControl.salt $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
_config server.secretKey $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
mkdir -p ${HOME_DIR}/.octoprint/printerProfiles
cp -f conf/voron.profile ${HOME_DIR}/.octoprint/printerProfiles/_default.profile

#/oprint/bin/octoprint config effective
_log "=> Configuration octoprint"
_config appearance.name $(cat /etc/hostname)
_config feature.sdSupport false "Désactivation de la carte SD"
_config plugins.tracking.enabled true "Tracking"
_config server.firstRun false "Désactivation de l'assistance"
_config server.pluginBlacklist.enabled true "Blacklist"
_config appearance.components.disabled.usersettings[0] plugin_appkeys
_config appearance.components.disabled.navbar[0] login
_log "  => Online check"
_config server.onlineCheck.enabled true
_config server.onlineCheck.host "185.121.177.177"
_log "  => Désactivation des plugins inutiles"
_config plugins._disabled[0] errortracking "ErrorTracking"
_config plugins._disabled[1] cura "Cura"


# Splashscreen
_log "=> SplashScreen"
mkdir -p /etc/systemd/system/
sudo cp ${SCRIPT_DIR}/conf/etc/systemd/system/splashscreen.service /etc/systemd/system/splashscreen.service
cp ${SCRIPT_DIR}/conf/share/splashscreen.png ${SHARE_DIR}/splashscreen.png

sudo systemctl disable getty@tty3
sudo systemctl enable splashscreen

# OctoDash
. ${SCRIPT_DIR}/modules/octodash.sh

# ADXL
. ${SCRIPT_DIR}/modules/adxl.sh

_log "=> Fin de l'installation : Nettoyage"
sudo apt autoremove -y
sudo apt clean
