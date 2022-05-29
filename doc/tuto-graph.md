Configuration d'OctoPrint pour les graphs communs
=================================================

## Informations

Cette documentation est menée à changer (en cours de test). La dernière modification date du `13/08/2021`.  
Pour le moment, les informations récoltées sont assez larges (nom des fichier gcode, durée de print, statut de l'imprimante,...).  
Elles seront affinées avec le temps pour récupérer que ce qui est pertinant pour réaliser des graphs et des stats.

## Installation

* Sur l'interface d'octoprint, allez dans la configuration
* Dans la section à gauche, "Plugin Manager" => Bouton "Get More" en haut à droite
* Recherchez "webhook" pour trouver le plugin "OctoPrint-Webhooks" ou installez le via l'URL `https://github.com/2blane/OctoPrint-Webhooks/archive/master.zip`
* Installez le plugin et rechargez octoprint


## Authentification

Demandez à Obi un couple "login/mot de passe" (sans ceci, les stats ne seront pas prisent en comptes).

## Configuration

Dans l'interface d'octoprint, dans la configuration puis dans la section à gauche "Webhooks".
Supprimez les webhooks existants (si besoin) et cliquez sur le bouton "New Hook"

Appliquez la configuration suivante :

* Général : 
    * ENABLED : Coché
    * URL : `https://geekariom.com/print.php`
    * Testing : Merci de ne pas utiliser car ceci peut fausser les stats.
* Templates :
    * Aucune modification et merci ne de pas utiliser.
* Webhook Parameters :
    * HTTP METHOD : `POST`
    * CONTENT TYPE : `JSON`
    * API SECRET : `le mot de passe fourni dans l'étape "authentification"`
    * DEVICE IDENTIFIER : `le login qui correspond à votre imprimante fourni dans l'étape "authentification"`
* Events :
    * PRINT STARTED :
        * Coché
        * Message : `start`
    * PRINT DONE :
        * Coché
        * Message : `done`
    * PRINT FAILED :
        * Coché
        * Message : `failed`
    * PRINT PAUSED :
        * Coché
        * Message : `paused`
    * USER ACTION NEEDED :
        * Décoché
    * ERROR :
        * Coché
        * Message : `error`
    * PRINT PROGRESS :
        * Décoché
* Advanced (aucune importance si le texte est sur une seule ligne):
    * HEADERS : `{"Content-Type": "application/json", "X-Api-key": "@apiSecret"}`
    * DATA : `{"deviceIdentifier": "@deviceIdentifier", "topic": "@topic", "message": "@message", "extra": "@extra", "state": "@state", "job": "@job", "progress": "@progress", "offsets": "@offsets", "meta": "@meta", "currentTime": "@currentTime"}`
* OAuth :
    * OAUTH ENABLED :
        * Décoché
