LISEZ-MOI
=========


## Préparation

### Wifi

Copier le fichier `conf/octopi-wpa-supplicant.sample` en `octopi-wpa-supplicant.txt` avant de lancer le script  ou à placer dans la partition `/boot` de la carte microSD.


### Compte de secours

Copier le fichier `conf/rescue-mdp.sample` en `rescue-mdp` avant de lancer le script pour configurer le mot de passe du compte `rescue`



## Installation de base (à partir d'une SD vierge):


Il faut lancer le script suivant pour préparer la microSD : `./build-script/octoprint-image.sh`.

Une fois fait :
* Booter le Rpi sur cette microSD
* Se connecter en SSH via le compte `pi`
* Lancer le script : `cd voron && ./03-first-boot.sh` (en compte `pi` et non root)



## Arborescence

Voici les dossiers essentiels dans ce dépot :

* `/home/pi/voron` : Les scripts de ce dépôt
* `/home/pi/voron/scripts` : Les scripts (synchro à chaque boot)
* `{DEPOT}/conf/octopi-wpa-supplicant.txt` : Fichier Wifi a appliquer lors de la création d'une image octoprint
* `/home/pi/klipper` : Source de klipper
* `/home/pi/.octoprint/uploads/system` : Dossier partagé (et synchro)
  * `klipper.bin` : Le firmware compilé à flasher
  * `klipper-makeconfig.txt` : Le fichier de configuration de compilation de Klipper
  * `klipper-macro.txt` : Les macros custom de klipper
  * `octodash-theme.txt` : Le theme CSS de dashboard
  * `splashscreen.png` : Le splashscreen lors du boot

  