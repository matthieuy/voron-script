#!/usr/bin/env bash
#
# Script d'installation d'octodash
#
source /home/pi/voron/modules/_common.sh

# Octoprint
_log "=> Octoprint"

# Configuration octoprint de base
_log "  => Configuration de l'API"
API_KEY=$(head -c16 </dev/urandom|xxd -p -u)
echo -e "${CYAN}  => Génération d'une clé : ${RED}${API_KEY}${NC}"

if [ -e ${HOME_DIR}/scripts/.env ]; then
    rm -f ${HOME_DIR}/scripts/.env
fi
cp ${SCRIPT_DIR}/scripts/.env.dist ${HOME_DIR}/scripts/.env
sed -i "s/DEFAULT_OCTOPRINT_API_KEY/${API_KEY}/g" ${HOME_DIR}/scripts/.env

_config api.enabled true "Activation"
_config api.allowCrossOrigin true
_config api.key ${API_KEY}
_config accessControl.salt $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
_config server.secretKey $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
mkdir -p ${HOME_DIR}/.octoprint/printerProfiles
cp -f ${SCRIPT_DIR}/conf/voron.profile ${HOME_DIR}/.octoprint/printerProfiles/_default.profile

#/oprint/bin/octoprint config effective
_log "=> Configuration octoprint"
_config appearance.name $(cat /etc/hostname)
_config feature.sdSupport false "Désactivation de la carte SD"
_config plugins.tracking.enabled true "Tracking"
_config server.firstRun false "Désactivation de l'assistance"
_config server.pluginBlacklist.enabled true "Blacklist"
_config appearance.components.disabled.usersettings[0] plugin_appkeys
_config appearance.components.disabled.navbar[0] login
_log "  => Online check"
_config server.onlineCheck.enabled true
_config server.onlineCheck.host "80.67.169.12"
_log "  => Désactivation des plugins inutiles"
_config plugins._disabled[0] errortracking "ErrorTracking"
_config plugins._disabled[1] cura "Cura"

_log "  => Connexion automatique de l'imprimante"
_config serial.autoconnect true
_config serial.baudrate 250000
_config serial.port /tmp/printer

# Création d'un utilisateur octprint
_log "=> Ajout d'un utilisateur ${USERNAME}"
${CMD_OCTO} user add --password "${USERNAME}" --admin ${USERNAME} > /dev/null