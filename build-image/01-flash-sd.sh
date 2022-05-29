#!/usr/bin/env bash
#
# Créer une image neuve d'octoprint sur la SD
# Ne fait que le flashage

#################
### VARIABLES ###
#################
source ./modules/_common.sh


# Params
if [ "$1" = "-h" ]; then
    echo "Usage : $0 [Image] [Device]"
    exit 1
fi
if [ -z "$1" ]; then
    read -p "Image [${IMG}] :" IMG_TMP
    if [ ! -z ${IMG_TMP} ]; then
        IMG=${IMG_TMP}
    fi
fi
if [ -z "$2" ]; then
    read -p "Device [${DEVICE}] :" DEVICE_TMP
    if [ ! -z ${DEVICE_TMP} ]; then
        DEVICE=${DEVICE_TMP}
    fi
fi


# Check périphérique
if [ ! -f ${IMG} ]; then
    echo "Image introuvable"
    exit 2
elif [ ! -e ${DEVICE} ]; then
    echo "Périphérique introuvable"
    exit 2
fi

# Demande des droits sudo
echo "=> Préparation du flash de ${IMG} => ${DEVICE}"
sudo echo "" > /dev/null

# Démontage des partitions
NB_MOUNT=$(mount | grep ^${DEVICE} | wc -l)
if [ ${NB_MOUNT} -eq 0 ]; then
	echo -e "=> Aucun montage en cours : ${CYAN}OK${NC}"
else
	echo -e "=> Démontage des ${CYAN}${NB_MOUNT}${NC} partitions"
	mount | grep ^${DEVICE} | awk '{ print $1 }'|xargs sudo umount
fi

# Lancement du flash
echo -e "=> Source : ${CYAN}${IMG}${NC}"
echo -e "=> Destination : ${CYAN}${DEVICE}${NC}"
read -p "Flash [Y/n] ?" CONFIRM
if [ "${CONFIRM}" != "n" ] && [ "${CONFIRM}" != "N" ]; then
	# Flash
    sudo dd if=${IMG} of=${DEVICE} status=progress
    sudo sync
fi

exit 0
