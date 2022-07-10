#!/usr/bin/env bash
#
# Test des LED

LED_RED=4
LED_GREEN=5
LED_EXTRACT=21
TIMEOUT=1
REPEAT=5

gpio mode ${LED_RED} out
gpio mode ${LED_GREEN} out
gpio mode ${LED_EXTRACT} out


for ((i=0; i<${REPEAT}; i++)); do
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
done

# Led extract
for ((i=0; i<${REPEAT}; i++)); do
    gpio write ${LED_EXTRACT} 1
    sleep ${TIMEOUT}

    gpio write ${LED_EXTRACT} 0
    sleep ${TIMEOUT}
done

# Extinction
gpio write ${LED_RED} 0
gpio write ${LED_GREEN} 0
gpio write ${LED_EXTRACT} 1
exit 0