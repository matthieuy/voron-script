#!/usr/bin/env bash
#
# Ajout du fichier de config octodash

source /home/pi/voron/modules/_common.sh

# Upgrade en root
if [ '${whoami}' == 'root' ]; then

else 
    # Upgrade en user "pi"

    # Copie du fichier de conf octodash
    mkdir -p ${DASH_DIR}
    cp -f ${SCRIPT_DIR}/conf/octodash/octodash.json.tpl ${DASH_DIR}/config.json
    
    # Remplacement du fichier octodash
    echo "Remplacement du fichier octodash"
    API_KEY=$(yq3 r ${CONF_OCTO} api.key)
    if [ "$API_KEY" != "" ]; then
    sed -i "s/API_KEY/${API_KEY}/g" ${DASH_DIR}/config.json
    fi
fi