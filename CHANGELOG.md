CHANGELOG
=========

* version actuelle (non versionné pour le moment) :
  * En cours...

----------------------------------------------------
* 2023042900 :
  * Mise en place du système de MàJ des scripts
  * Configuration de la rotation de l'écran dès le boot
  * Script pour faire des appel API
  * Reboot klipper : Attente de octoprint pour lancer un FIRMWARE_RESTART
* 2023040100 :
  * Correction de plusieurs bug lors du 1er boot :
    * Compilation Kilpper qui stop le script
    * ADXL : Mise à jour vers python3
    * Octodash : Problème de lien systemd + mise à jour des scripts
* 2023032500 :
  * Klipper : 
    * Configuration du /etc/default/klipper
    * Ajout du fichier "variables" pour le stockage 
    * Installation et configuration du plugins lors du 1er boot
  * Octodash :
    * Installation des pré-requis + octodash
    * Configuration de l'API KEY et du thème
    * Configuration des interpréteurs : xinit + bash + zsh
    * Autologin
  * Installation :
    * wiringpi via le code source
    * nodejs
* 2023031600 :
  * Réécriture des scripts from scratch