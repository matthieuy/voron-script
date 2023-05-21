#!/usr/bin/env bash
#
# Test de l'extracteur
# A couper manuellement car sinon en boucle


EXTRACTEUR=8
INTERVAL_START=30
INTERVAL_STOP=15

gpio mode ${EXTRACTEUR} out

while true; do
    echo "Start ${INTERVAL_START}sec"
    gpio write ${EXTRACTEUR} 1
    sleep ${INTERVAL_START}
    echo "Stop ${INTERVAL_STOP}sec"
    gpio write ${EXTRACTEUR} 0
    sleep ${INTERVAL_STOP}
done

exit 0