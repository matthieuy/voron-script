#!/usr/bin/env bash

#################
### VARIABLES ###
#################
DEVICE="/dev/mmcblk0"
IMG="$(pwd)/out/octopi-source.img"
MOUNT_DIR="$(pwd)/out/mount"
ROOT_DIR="${MOUNT_DIR}/root"
BOOT_DIR="${MOUNT_DIR}/boot"
WIFI_CONF="conf/octopi-wpa-supplicant.txt"
GIT_REPO="https://github.com/matthieuy/voron-script.git"
YQ_VERSION="3.4.0/yq_linux_arm"         # Version de Yaml parser

# Check utilisateur
if [ "$(whoami)" == "root" ]; then
    echo "Ne lancez pas ce script en super-admin !"
    exit 2
fi

# Check dossier
if [ -z "$(pwd)/.voron-root" ]; then  # TODO : Change this file with a required
    echo "Lancer ce script depuis la racine du projet !"
    exit 2
fi

# Arguments du script
if [ "$1" == "-h" ]; then
    echo "Utilisation : $0 [device] [image]"
    exit 2
fi
if [ -z "$1" ]; then
    read -p "Quel est le périphérique à flasher [${DEVICE}] ? " ANSWER
    if [ ! -z ${ANSWER} ]; then
        DEVICE=${ANSWER}
    fi
else
    DEVICE="$1"
fi
if [ -n "${NEED_IMG}" ]; then
    if [ -z "$2" ]; then
        read -p "quelle est l'image octopi a utiliser [${IMG}] ? " ANSWER
        if [ ! -z ${ANSWER} ]; then
            IMG=${ANSWER}
        fi
    else
        IMG="$2"
    fi
fi

# Check
if [ -n "${NEED_IMG}" ] && [ ! -f ${IMG} ]; then
    echo "Image introuvable : ${IMG}"
    exit 2
fi
if [ ! -e ${DEVICE} ]; then
    echo "Device introuvable ; ${DEVICE}"
    exit 2
fi


#################
### FONCTIONS ###
#################
# Démonter les partitions du devices
_umount_device() {
    NB_MOUNT=$(mount | grep ^${DEVICE} | wc -l)
    if [ ${NB_MOUNT} -eq 0 ]; then
        echo "=> Aucun montage en cours : OK"
    else
        echo -e "=> Démontage des ${NB_MOUNT} partitions"
        mount | grep ^${DEVICE} | awk '{ print $1 }'|xargs sudo umount
    fi
}

_add_to_file_if_doesnt_exist() {
    if [ $(cat $1 | grep "$2" | wc -l) -eq 0 ]; then
        echo "$2" >> $1
    fi
}