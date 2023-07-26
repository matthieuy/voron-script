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
  rm conf/rescue-mdp
fi

# Couper octoprint
_log "=> Octoprint : coupure du service durant la màj"
sudo service octoprint stop

# Timezone
_log "  => Timezone"
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Génération du support clavier
_log "=> Passage en français"
sudo locale-gen

# Update script avec github
_log "=> MàJ github des scripts"
git config --global pull.rebase false
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
_log "  => Fix install"
sudo apt --fix-broken install -y

# Installation globale
_log "=> Installation de paquets de base"
sudo apt install -y tree zsh autojump fbi rsync hdparm sysbench ncdu python3-rpi.gpio

# Création du dossier de share
mkdir -p ${SHARE_DIR}

# Node
_log "NodeJS"
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
sudo apt install -y --no-install-recommends nodejs
sudo npm i npm@latest forever -g


# wiringPI
_log "=> WiringPI"
_log "  => Récupération des sources"
git clone https://github.com/WiringPi/WiringPi.git ~/wiringpi
_log "  => Compilation"
cd ~/wiringpi && sudo ./build && cd ~
rm -rf ~/wiringpi


# Oh my ZSH
_log "=> Oh my ZSH"
sudo chsh -s /usr/bin/zsh $(whoami)
zstyle ':omz:update' mode auto

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
git -C ${KLIPPER_DIR} config pull.rebase false
. ${SCRIPT_DIR}/scripts/update-klipper.sh
_plugins "Klipper" "https://github.com/AliceGrey/OctoprintKlipperPlugin/archive/master.zip"
_config plugins.klipper.configuration.reload_command FIRMWARE_RESTART
_config plugins.klipper.connection.replace_connection_panel false
cp -f ${SCRIPT_DIR}/conf/klipper/PIS.cfg ${HOME_DIR}/PIS.cfg
cp -f ${SCRIPT_DIR}/conf/klipper/klipper-static.txt ${SHARE_DIR}/klipper-static.txt

# Installation pip
_log "=> Librairies python"
python3 -m pip install python-environ requests argparse

# Configurer octoprint
_log "=> Configuration octoprint de base"
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
#. ${SCRIPT_DIR}/modules/adxl.sh

# Redémarrage d'octo
_log "=> Octoprint : redémarrage"
sudo service octoprint restart
python3 ${SCRIPT_DIR}/scripts/wait-octoprint.py --timeout 45 --interval 1 --debug

# Update octoprint
. ${SCRIPT_DIR}/scripts/update-octoprint.sh

_log "=> Backup post-installation"
${CMD_OCTO} plugins backup:backup

# Fin de l'installation => Nettoyage
_log "=> Fin de l'installation : Nettoyage"
sudo apt autoremove -y
sudo apt clean

# Exit
_log "Vous pouvez maintenant redémarrer le raspberry avec \"sudo reboot\" puis vous connecter sur http://${HOSTNAME}"
exit 0