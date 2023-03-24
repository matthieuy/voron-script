#!/usr/bin/env bash
#
# Creer une image neuve d'octoprint sur la SD

#################
### VARIABLES ###
#################
NEED_IMG="YES"
source ./build-img/_build-common.sh 

# Demande des droits sudo
sudo echo "" > /dev/null

# Confirmation
echo "=> Source : ${IMG}"
echo "=> Destination : ${DEVICE}"
read -p "Confirmation [Y/n] ?" ANSWER
if [ "${ANSWER}" == "n" ]; then
    exit 2
fi
echo ""

# Demontage des partitions
_umount_device

# Flash de la SD
echo "=> Lancement du flash de la microSD"
sudo dd if=${IMG} of=${DEVICE} status=progress
echo " => Synchro"
sudo sync
echo "Flash terminé !"

# Lancer la preparation de la carte
echo "Ejectez et réinserez la carte microSD. Appuyez sur entree une fois la carte bien détectée par le PC"
read -p "" PAUSE
bash $(pwd)/build-img/02-prepare.sh ${DEVICE}

# Fin
echo "Fin du flash"
exit 0