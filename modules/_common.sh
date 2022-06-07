#!/usr/bin/env bash
#
# Configuration commune
#

#################
### VARIABLES ###
#################
# Globale
HOSTNAME_DEFAULT="voron"
HOSTNAME=${HOSTNAME_DEFAULT}
USERNAME=${HOSTNAME_DEFAULT}
PI_PASSWORD_DEFAULT="raspberry"
PI_PASSWORD=${PI_PASSWORD_DEFAULT}
GIT_REPO="https://github.com/matthieuy/voron-script.git"

# Versions
VERSION_SCRIPT=2022060700
YQ_VERSION="3.4.0"		         # Version de Yaml parser
KLIPPER_CONF_VERSION="20220601"  # Fichier de configuration klipper


# Flash
DEVICE="/dev/sdb"
IMG="/home/matthieu/Temp/voron-backup/octopi-0.18.0-1.8.0-20220517112637.img"
MOUNT_DIR="out/mount"
BOOT_DIR="${MOUNT_DIR}/boot"
ROOT_DIR="${MOUNT_DIR}/root"
HOME_DIR="/home/pi"

# Directory
SCRIPT_DIR="/home/pi/voron"
SHARE_DIR="/home/pi/.octoprint/uploads/system"
KLIPPER_DIR="/home/pi/klipper"
DASH_DIR="/home/pi/.config/octodash"
CONF_OCTO="/home/pi/.octoprint/config.yaml"
CMD_OCTO="/home/pi/oprint/bin/octoprint"
PIP_BIN="/home/pi/oprint/bin/pip"
VERSION_FILE="${SCRIPT_DIR}/out/CURRENT_VERSION.txt"
VERSION_FILE_ROOT="${SCRIPT_DIR}/out/CURRENT_VERSION_ROOT.txt"
GPIO_DIR="${SCRIPT_DIR}/gpio"


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

# Configuration octoprint.yml (parametre, valeur, [texte log])
_config() {
  if [ ! -z "$3" ]; then
    _log "  => $3"
  fi
  yq3 w -i ${CONF_OCTO} $1 "$2"
}

# Idem mais en preinstall
_preconfig() {
  if [ ! -z "$3" ]; then
    _log "  => $3"
  fi
  yq w -i ${ROOT_DIR}${CONF_OCTO} $1 "$2"
}

# Installation d'un plugin
_plugins() {
    _log "  => $1"
    $PIP_BIN install -q --disable-pip-version-check $2
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
