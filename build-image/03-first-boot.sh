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


# Création d'un utilisateur octprint
_log "=> Ajout d'un utilisateur ${USERNAME}"
${CMD_OCTO} user add --password "${USERNAME}" --admin ${USERNAME} > /dev/null


###############
### UPGRADE ###
###############
_log "=> Upgrade"
_log "  => Suppression logiciels inutiles"
sudo apt remove --purge -y -q bluez-firmware bluez libraspberrypi-doc
_log "  => Dépôt"
sudo apt update -q -y
_log "  => Système"
if [ ${DEVMODE} -eq 0 ]; then
  sudo apt full-upgrade -y
fi

# Génération du support clavier
_log "=> Passage en français"
sudo locale-gen


# Installation globale
sudo apt install -y tree zsh autojump fbi

# NPM (GPIO serveur)
sudo apt install -y --no-install-recommends nodejs npm


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
. ~/scripts/update-klipper.sh

# Led IDE
echo mmc0 | sudo tee /sys/class/leds/led0/trigger > /dev/null # cpu0 (charge CPU) ou mmc0 (lecture carte SD)

# Splashscreen
sudo systemctl disable getty@tty3
sudo systemctl enable splashscreen

# OctoDash
./modules/octodash.sh

# ADXL
./modules/adxl.sh

_log "=> Fin de l'installation : Nettoyage"
sudo apt autoremove -y
sudo apt clean
