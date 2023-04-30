
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


# Comparaison des versions
NEW_VERSION_SCRIPT=$(cat /home/pi/voron/modules/_common.sh|grep VERSION_SCRIPT|cut -d= -f2)
if [ ${CURRENT_VERSION} -ge ${NEW_VERSION_SCRIPT} ]; then
	echo "Aucune mise à jour disponible"
	exit 0
fi
echo "Mise à jour : v${CURRENT_VERSION} => v${NEW_VERSION_SCRIPT}"
echo ${NEW_VERSION_SCRIPT} > ${VERSION_FILE_ROOT}

# Lancement des scripts d'upgrade
for FILE in $(ls ${SCRIPT_DIR}/scripts/upgrade); do
    UPGRADE_VERSION=$(basename $FILE .sh)
    if [ ${UPGRADE_VERSION} = "_template" ]; then
        continue
    fi
    if [ ${UPGRADE_VERSION} -ge ${CURRENT_VERSION} ]; then
		echo "  => Lancement script v${UPGRADE_VERSION}"
        UPGRADE_SCRIPT="${SCRIPT_DIR}/scripts/upgrade/${UPGRADE_VERSION}.sh"
        _logUpgrade "Lancement du script ${UPGRADE_SCRIPT} en utilisateur root"
        bash ${UPGRADE_SCRIPT}
    fi
done


# Fin
echo ${NEW_VERSION_SCRIPT} > ${VERSION_FILE_ROOT}
rm -f ${NEED_REBOOT_UPGRADE}
_logUpgrade "MàJ root terminée"
echo "Mise à jour terminée"

