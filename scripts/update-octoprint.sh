#!/usr/bin/env bash
#
# Vérification des MàJ
#
source /home/pi/voron/modules/_common.sh

_log "=> Vérification des mises à jour"
_log "  => Octoprint"
RESULT=$(${CMD_OCTO} plugins softwareupdate:check --only-new octoprint)
echo $RESULT
NB_UPDATE=$(echo ${RESULT}|grep 'Update available'|wc -l)
if [ "${NB_UPDATE}" != "0" ]; then
	_log "    => Mise à jour"
	${CMD_OCTO} plugins softwareupdate:update octoprint
fi

_log "  => Plugins"
RESULT=$(${CMD_OCTO} plugins softwareupdate:check --only-new)
NB_UPDATE=$(echo ${RESULT}|grep 'Update available'|wc -l)
if [ "${NB_UPDATE}" != "0" ]; then
	_log "    => Mise à jour"
	${CMD_OCTO} plugins softwareupdate:update
fi
