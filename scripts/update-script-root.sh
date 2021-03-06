#!/usr/bin/env bash
#
# Update des scripts custom (lancer en root)

source /home/pi/voron/modules/_common.sh

# Check current version
mkdir -p ${SCRIPT_DIR}/out
if [ -e ${VERSION_FILE_ROOT} ]; then
	let CURRENT_VERSION=0
	let "CURRENT_VERSION += $(cat ${VERSION_FILE_ROOT})"
else
	CURRENT_VERSION=${VERSION_SCRIPT}
	echo ${CURRENT_VERSION} > ${VERSION_FILE_ROOT}
fi
echo "Version actuelle : v${CURRENT_VERSION}"

# Suppression du fichier de reboot nécessaire (il pourra être remis dans les scripts unitaires)
rm -f ${SCRIPT_DIR}/out/NEED_REBOOT

# Mise a jour crontab
VORON_CRON="/etc/cron.d/voron-cron"
if _md5Compare ${SCRIPT_DIR}/conf/${VORON_CRON} ${VORON_CRON} -eq 1; then
    rm ${VORON_CRON}
    cp -f ${SCRIPT_DIR}/conf/${VORON_CRON} ${VORON_CRON}
    chown root: ${VORON_CRON}
fi


# Comparaison des versions
NEW_VERSION_SCRIPT=$(cat /home/pi/voron/modules/_common.sh|grep VERSION_SCRIPT|cut -d= -f2)
if [ ${CURRENT_VERSION} -ge ${NEW_VERSION_SCRIPT} ]; then
	echo "Aucune mise à jour disponible"
	exit 0
fi
echo "Mise à jour : v${CURRENT_VERSION} => v${NEW_VERSION_SCRIPT}"
echo ${NEW_VERSION_SCRIPT} > ${VERSION_FILE_ROOT}

# Lancement des scripts d'upgrade
let NB_UPGRADE=0
for FILE in $(ls upgrade); do
    UPGRADE_VERSION=$(basename $FILE .sh)
    if [ "${UPGRADE_VERSION}" == "_template" ] || [ "${UPGRADE_VERSION}" == "UPGRADE_LIST.md" ]; then
        continue
    fi
    if [ $(echo ${UPGRADE_VERSION}) -ge $(echo ${CURRENT_VERSION}) ]; then
        UPGRADE_SCRIPT="/home/pi/scripts/upgrade/${UPGRADE_VERSION}.sh"
        echo "  => Lancement script v${UPGRADE_VERSION}"
        _logUpgrade "Lancement du script ${UPGRADE_SCRIPT} en utilisateur root"
        bash ${UPGRADE_SCRIPT}
        let "NB_UPGRADE += 1"
    fi
done


# Fin
echo ${NEW_VERSION_SCRIPT} > ${VERSION_FILE_ROOT}
if [ ${NB_UPGRADE} -ge 0 ]; then
    _logUpgrade "MàJ root terminée"
fi
echo "Mise à jour terminée"

