#!/usr/bin/env bash
#
# Update des scripts custom

source /home/pi/voron/modules/_common.sh


# Check current version
mkdir -p ${SCRIPT_DIR}
if [ -e ${VERSION_FILE} ]; then
	let CURRENT_VERSION=0
	let "CURRENT_VERSION += $(cat ${VERSION_FILE})"
else
	CURRENT_VERSION=${VERSION_SCRIPT}
	echo ${CURRENT_VERSION} > ${VERSION_FILE}
fi
echo "Version actuelle : v${CURRENT_VERSION}"


# Update des sources
cd ${SCRIPT_DIR}
git pull -q origin main
git log -n1 --oneline


# Comparaison des versions
NEW_VERSION_SCRIPT=$(cat /home/pi/voron/modules/_common.sh|grep VERSION_SCRIPT|cut -d= -f2)
if [ ${CURRENT_VERSION} -ge ${NEW_VERSION_SCRIPT} ]; then
	echo "Aucune mise à jour disponible"
	exit 0
fi
echo "Mise à jour : v${CURRENT_VERSION} => v${NEW_VERSION_SCRIPT}"
echo ${NEW_VERSION_SCRIPT} > ${VERSION_FILE}


# On écrase les scripts
echo "  => Scripts"
cp -rf ${SCRIPT_DIR}/scripts/* ${HOME_DIR}/scripts/
chmod +x ${HOME_DIR}/scripts/*

# Synchro des fichiers
echo "  => Configuration klipper"

# Lancement des scripts d'upgrade
for FILE in $(ls upgrade); do
    UPGRADE_VERSION=$(basename $FILE .sh)
    if [ ${UPGRADE_VERSION} = "_template" ]; then
        continue
    fi
    if [ ${UPGRADE_VERSION} -ge ${CURRENT_VERSION} ]; then
		echo "  => Lancement script v${UPGRADE_VERSION}"
        sudo /home/pi/scripts/upgrade/${UPGRADE_VERSION}.sh
    fi
done


# Fin
echo ${NEW_VERSION_SCRIPT} > ${VERSION_FILE}
echo "Mise à jour terminée"

