#!/bin/bash

echo -e "Redémarrage du service klipper : "
sudo service klipper restart
echo "OK"
echo -e "Redémarrage du firmware : "
python3 /home/pi/scripts/send_gcode.py --gcode "FIRMWARE_RESTART" --reconnect
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "OK"
else
    echo "NOK (exit code : ${EXIT_CODE})"
fi
exit 0
