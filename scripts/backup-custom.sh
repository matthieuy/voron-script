#!/usr/bin/env bash
#
# Copie des fichiers indispensables/custom avant le backup schedule

source /home/pi/voron/modules/_common.sh

# Octodash
OCTODASH_DIR_BACKUP="/home/pi/.octoprint/data/octodashcompanion"
mkdir -p ${OCTODASH_DIR_BACKUP}
cp -f ${DASH_DIR}/config.json ${OCTODASH_DIR_BACKUP}
cp -f ${DASH_DIR}/custom-styles.css ${OCTODASH_DIR_BACKUP}

# Uploaded file system
UPLOADED_SYSTEM="/home/pi/.octoprint/data/uploaded_system"
rm -rf ${UPLOADED_SYSTEM}
cp -rf ${SHARE_DIR} ${UPLOADED_SYSTEM}

