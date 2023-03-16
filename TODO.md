TODO
====

* [ ] Premier boot :
    * [ ] Mettre à jour les scripts via git
    * [ ] Klipper :
        * [ ] Mettre à jour les sources
        * [ ] Compiler
        * [ ] Copier le firmware pour pouvoir le récupérer via l'interface octoprint
    * [ ] Configurer octoprint :
        * [ ] (TODO à rédiger)
    * [ ] Splashscreen :
        * [ ] Installation du splashscreen
        * [ ] Configuration systemd
        * [ ] L'image du splashscreen
    * [ ] OctoDash :
        * [ ] Installation
        * [ ] Configuration du module
        * [ ] Lancement auto au démarrage
        * [ ] Configuration du screen :
            * [ ] Voron 1
            * [ ] Voron 2
        * [ ] Script de mise à jour auto
    * [ ] ADXL (Accéléromètre) :
        * [ ] Récupération des sources
        * [ ] Compilation
        * [ ] Configuration
    * [ ] Fin du premier boot :
        * [ ] Nettoyage des dépôts
        * [ ] Suppression des paquets inutiles
* [ ] Scripts :
    * [X] Bouton à l'arrière :
        * [X] Refaire le script
        * [X] Intégrer la led bicolor
        * [X] Lancement au boot
    * [ ] Klipper :
        * [ ] Redémarrer klipper
        * [ ] Mettre à jour klipper :
            * [ ] Mettre à jour les sources
            * [ ] Compiler
            * [ ] Copier le firmware dans le dossier de partage
            * [ ] Tester via [l'outil utilisé par Jermtek](https://github.com/th33xitus/kiauh)
    * [X] Test des leds :
        * [X] Classique
        * [X] Lors du boot pour check les LED
* [ ] Crontab (tâches planifiées) :
    * [ ] Synchro des fichiers entre dossier de partage/système
    * [ ] Backup des fichiers custom (avant le backup système) :
        * [ ] Faire le script
        * [ ] Planifier juste avant
        * [ ] Fichiers à backup :
            * [ ] Conf octodash
* [ ] Màj :
    * [ ] Script pour mettre à jour le RPI
    * [ ] Script pour OZH
    * [ ] Script pour octodash
    * [ ] Script pour octoprint
    * [ ] Script pour mettre à jour les scripts git custom :
        * [ ] En utilisateur "pi"
        * [ ] En root lors du boot
        * [ ] Fichier dans le partage pour savoir la version actuelle
* [ ] Divers :
    * [ ] Mettre en place un CHANGELOG
    * [ ] Compiler image pour réinstallation direct :
        * [ ] Redimenssionner les partitions
    * [ ] Serveur nodejs GPIO :
        * [ ] Configuration des sources
        * [ ] Installation
        * [ ] Bouton/script pour activer/désactiver le serveur
    * [ ] Compléter la doc