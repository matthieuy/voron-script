#!/usr/bin/env bash
#
# Lancer en SSH après le 1er boot

#################
### VARIABLES ###
#################
source /home/pi/voron/modules/_common.sh

# Globale
HOSTNAME_DEFAULT="voron-test"         # Hostname
HOSTNAME=${HOSTNAME_DEFAULT}          # Hostname
PI_PASSWORD_DEFAULT="raspberry"       # Mot de passe
PI_PASSWORD=${PI_PASSWORD_DEFAULT}    # Mot de passe


# Check utilisateur
if [ "$(whoami)" == "root" ]; then
    _log "${RED}Ne lancez pas ce script en super-admin"
    exit 2
elif [ "$(whoami)" != "pi" ]; then
    _log "${RED}Lancez ce script avec l'utilisateur par défaut : pi"
    exit 2
fi

# Check dossier
if [ "$(pwd)" != "${SCRIPT_DIR}" ]; then
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
  echo -ne "\n${RED}C'est le bon moment pour changer le mot de passe par défaut !\n${NC}Nouveau mot de passe : "
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


# Création du compte de backup
if [ -e conf/rescue-mdp ]; then
  _log "=> Ajout d'un compte \"rescue\""
  MDP_RESCUE=$(cat conf/rescue-mdp)
  sudo useradd -m -p $(openssl passwd -1 ${MDP_RESCUE}) -s /bin/bash -G sudo rescue
fi

# Couper octoprint
_log "=> Octoprint : coupure du service durant la màj"
sudo service octoprint stop

# Timezone
_log "  => Timezone"
echo "Europe/Paris" | sudo tee /etc/timezone > /dev/null
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Génération du support clavier
_log "=> Passage en français"
sudo sed -i 's/^XKBLAYOUT="gb"$/XKBLAYOUT="fr"/' /etc/default/keyboard
sudo sed -i 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen

# Update script avec github
_log "=> MàJ github des scripts"
git -C ${SCRIPT_DIR} branch --set-upstream-to=origin/master master
git -C ${SCRIPT_DIR} reset --hard
chmod +x ${SCRIPT_DIR}/scripts/*
chmod +x ${SCRIPT_DIR}/modules/*


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
sudo apt --fix-broken install -y

# Installation globale
_log "=> Installation de paquets de base"
sudo apt install -y tree zsh autojump fbi rsync hdparm sysbench ncdu
sudo apt install -y --no-install-recommends nodejs npm
sudo npm i npm@latest forever -g
npm install --suppess-warnings

# wiringPI
_log "=> WiringPI"
wget https://project-downloads.drogon.net/wiringpi-latest.deb -O /tmp/wiringpi.deb
sudo dpkg -i /tmp/wiringpi.deb
rm -f /tmp/wiringpi.deb

# Oh my ZSH
_log "=> Oh my ZSH"
sudo chsh -s /usr/bin/zsh $(whoami)

# Led IDE
_log "=> LED IDE"
echo mmc0 | sudo tee /sys/class/leds/led0/trigger > /dev/null # cpu0 (charge CPU) ou mmc0 (lecture carte SD)

# Crontab
_log "  => Crontab"
sudo cp -f ${SCRIPT_DIR}/conf/etc/cron.d/voron-cron /etc/cron.d/voron-cron
sudo chown root: /etc/cron.d/voron-cron
sudo chmod +x /etc/cron.d/voron-cron

# Klipper
_log "=> Klipper"
. ${SCRIPT_DIR}/scripts/update-klipper.sh
_plugins "Klipper" "https://github.com/AliceGrey/OctoprintKlipperPlugin/archive/master.zip"
_config plugins.klipper.configuration.reload_command FIRMWARE_RESTART
_config plugins.klipper.connection.replace_connection_panel false

# Configurer octoprint
. ${SCRIPT_DIR}/modules/conf-octoprint.sh

# Splashscreen
_log "=> SplashScreen"
mkdir -p /etc/systemd/system/
sudo cp ${SCRIPT_DIR}/conf/etc/systemd/system/splashscreen.service /etc/systemd/system/splashscreen.service
cp ${SCRIPT_DIR}/conf/splashscreen/splashscreen.png ${SHARE_DIR}/splashscreen.png
sudo systemctl disable getty@tty3
sudo systemctl enable splashscreen

# Octodash
. ${SCRIPT_DIR}/modules/octodash.sh
sleep 5

# ADXL
. ${SCRIPT_DIR}/modules/adxl.sh

# Redémarrage d'octo
_log "=> Octoprint : redémarrage"
sudo service octoprint restart
sleep 30

# Update octoprint
. ${SCRIPT_DIR}/scripts/update-octoprint.sh

_log "=> Backup post-installation"
${CMD_OCTO} plugins backup:backup

# Fin de l'installation => Nettoyage
_log "=> Fin de l'installation : Nettoyage"
sudo apt autoremove -y
sudo apt clean
exit 0