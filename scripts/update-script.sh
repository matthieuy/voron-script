#!/usr/bin/env bash
#
# Update des scripts custom

source /home/pi/voron/modules/_common.sh


# Check current version
if [ -e ${VERSION_FILE} ]; then
	let CURRENT_VERSION=0
	let "CURRENT_VERSION += $(cat ${VERSION_FILE})"
else
	CURRENT_VERSION=${VERSION_SCRIPT}
	echo ${CURRENT_VERSION} > ${VERSION_FILE}
fi
echo "Version actuelle : ${CURRENT_VERSION}"


