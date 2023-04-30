#!/usr/bin/env bash
#
# Update des scripts custom (lancer en utilisateur pi)

source /home/pi/voron/modules/_common.sh

# Check current version
mkdir -p ${SCRIPT_DIR}/out
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
git reset --hard -q
git pull -q
git log -n1 --oneline

# On écrase les scripts
echo "  => Scripts"
cp -rf ${SCRIPT_DIR}/scripts/* ${HOME_DIR}/scripts/
chmod +x ${HOME_DIR}/scripts/*
chmod +x ${SCRIPT_DIR}/scripts/upgrade/*

# Comparaison des versions
NEW_VERSION_SCRIPT=$(cat /home/pi/voron/modules/_common.sh|grep VERSION_SCRIPT|cut -d= -f2)
if [ ${CURRENT_VERSION} -ge ${NEW_VERSION_SCRIPT} ]; then
	echo "Aucune mise à jour disponible"
    _logUpgrade "Check upgrade : Aucune (${CURRENT_VERSION} / ${NEW_VERSION_SCRIPT})"
    if [ -e ${NEED_REBOOT_UPGRADE} ]; then
        echo "Un reboot du Rpi est nécessaire !"
    fi

	exit 0
fi
echo "Mise à jour : v${CURRENT_VERSION} => v${NEW_VERSION_SCRIPT}"
echo ${NEW_VERSION_SCRIPT} > ${VERSION_FILE}
_logUpgrade "Check upgrade : Dispo :${CURRENT_VERSION} => ${NEW_VERSION_SCRIPT}"

# Lancement des scripts d'upgrade
for FILE in $(ls ${SCRIPT_DIR}/scripts/upgrade); do
    UPGRADE_VERSION=$(basename $FILE .sh)
    if [ ${UPGRADE_VERSION} = "_template" ]; then
        continue
    fi
    if [ ${UPGRADE_VERSION} -ge ${CURRENT_VERSION} ]; then
        UPGRADE_SCRIPT="${SCRIPT_DIR}/scripts/upgrade/${UPGRADE_VERSION}.sh"
		echo "  => Lancement script v${UPGRADE_VERSION}"
        _logUpgrade "Lancement du script ${UPGRADE_SCRIPT} en utilisateur standard"
        bash ${UPGRADE_SCRIPT}
    fi
done

# Fin
echo ${NEW_VERSION_SCRIPT} > ${VERSION_FILE}
if [ -e ${NEED_REBOOT_UPGRADE} ]; then
    echo "Mise à jour terminée : un reboot du Rpi est nécessaire !"
    _logUpgrade "MàJ terminée : reboot nécessaire"
else
    echo "Mise à jour terminée"
    _logUpgrade "MàJ terminée"
fi
