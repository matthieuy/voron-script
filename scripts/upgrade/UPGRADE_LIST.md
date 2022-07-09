Liste des upgrades
==================


## Fichiers

Quelques infos sur les Màj :
* Le dossier "scripts" et son contenu est écrasé à chaque fois (Màj ou non disponible)
* Le crontab "voron-cron" est un lien symbolique vers le dépôt donc un simple reboot suffit
* Les MàJ avec les droits roots sont faite lors du reboot (prendre en compte un reboot long)
* Niveau log de Màj :
    * La version actuelle appliquée avec l'utilisateur PI est dispo dans : /home/pi/voron/out/CURRENT_VERSION.txt
    * La version actuelle appliquée par l'utilisateur root est dispo dans : /home/pi/voron/out/CURRENT_VERSION_ROOT.txt
    * Les logs de MàJ sont dispo dans /home/pi/.octoprint/uploads/system/upgrade-scripts.txt (le dossier partagé)

## Versions

* 2022060700 :
    * Copie du fichier de conf octodash
    * Configuration d'octodash avec l'API key
