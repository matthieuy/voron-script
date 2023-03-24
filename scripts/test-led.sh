#!/usr/bin/env bash
#
# Test des LED
# Si 1er paramètre à "boot" : Test des led rapide

LED_RED=4
LED_GREEN=5
LED_EXTRACT=21
TIMEOUT=1
REPEAT=5

gpio mode ${LED_RED} out
gpio mode ${LED_GREEN} out
gpio mode ${LED_EXTRACT} out

# Fonction de test pour la bicolor
_test_led() {
    # Vert
    gpio write ${LED_RED} 0
    gpio write ${LED_GREEN} 1
    sleep ${TIMEOUT}
    
    # Jaune (rouge+vert)
    gpio write ${LED_RED} 1
    gpio write ${LED_GREEN} 1
    sleep ${TIMEOUT}

    # Rouge
    gpio write ${LED_RED} 1
    gpio write ${LED_GREEN} 0
    sleep ${TIMEOUT}
}

# Boot : test des leds : 
if [ "$1" == "boot" ]; then
    gpio write ${LED_EXTRACT} 1
    _test_led
    gpio write ${LED_EXTRACT} 0
else
    # Sinon on clignote plusieurs fois
    for ((i=0; i<${REPEAT}; i++)); do
        _test_led
    done

    # Led extract
    for ((i=0; i<${REPEAT}; i++)); do
        gpio write ${LED_EXTRACT} 1
        sleep ${TIMEOUT}

        gpio write ${LED_EXTRACT} 0
        sleep ${TIMEOUT}
    done
fi


# Extinction
gpio write ${LED_RED} 0
gpio write ${LED_GREEN} 0
gpio write ${LED_EXTRACT} 0
exit 0
