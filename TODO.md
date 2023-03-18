TODO
====

* [ ] Premier boot :
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
        * [X] Récupération des sources
        * [X] Compilation
        * [ ] Configuration
* [ ] Scripts :
    * [ ] Klipper :
        * [X] Redémarrer klipper
        * [ ] Mettre à jour klipper :
            * [X] Mettre à jour les sources
            * [X] Compiler
            * [X] Copier le firmware dans le dossier de partage
            * [ ] Tester via [l'outil utilisé par Jermtek](https://github.com/th33xitus/kiauh)
* [ ] Màj :
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