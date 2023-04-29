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
        * [X] Installation
        * [ ] Configuration du module
        * [ ] Lancement auto au démarrage
        * [ ] Configuration du screen :
            * [ ] Voron 1
            * [ ] Voron 2
        * [ ] Script de mise à jour auto
    * [ ] Rajouter le script https://github.com/KiloQubit/probe_accuracy
* [ ] Scripts :
* [ ] Màj :
    * [ ] Script pour octodash
    * [ ] Script pour octoprint :
        * [ ] A refaire en python pour vérifier l'état d'octoprint (ready) avant
    * [ ] Script pour mettre à jour les scripts git custom :
        * [ ] En utilisateur "pi"
        * [ ] En root lors du boot
        * [ ] Fichier dans le partage pour savoir la version actuelle
* [ ] Divers :
    * [ ] Compiler image pour réinstallation direct :
        * [ ] Redimenssionner les partitions
    * [ ] Serveur nodejs GPIO :
        * [ ] Configuration des sources
        * [ ] Installation
        * [ ] Bouton/script pour activer/désactiver le serveur
    * [ ] Compléter la doc



Bug first boot
==============

ADXL :
```
E: Package 'python-numpy' has no installation candidate
E: Package 'python-matplotlib' has no installation candidate
```
