#!/usr/bin/env bash
#
# Configuration commune
#

#################
### VARIABLES ###
#################
# Dossiers/Fichiers
HOME_DIR="/home/pi"
SCRIPT_DIR="${HOME_DIR}/voron"
KLIPPER_DIR="${HOME_DIR}/klipper"
SHARE_DIR="${HOME_DIR}/.octoprint/uploads/system"
DASH_DIR="${HOME_DIR}/home/pi/.config/octodash"

# Version
VERSION_SCRIPT=2023031600
VERSION_FILE="${SCRIPT_DIR}/out/CURRENT_VERSION.txt"
VERSION_FILE_ROOT="${SCRIPT_DIR}/out/CURRENT_VERSION_ROOT.txt"


# Couleurs
CYAN="\033[1;36m"
NC="\033[0m"
RED="\033[1;31m"

#################
### FONCTIONS ###
#################
# Afficher d'un texte (texte à afficher)
_log() {
  echo -e "${CYAN}$1${NC}"
}

# Copier un fichier (fichier1, fichier2)
# Si le fichier 1 est + récent que le 2 : écrasement
_synchroFile() {
    if [ "$1" -nt "$2" ];then
        cp -f "$1" "$2"
    else
        cp -f "$2" "$1"
    fi
}