Input shaper (via un accéléromètre)
===================================

Voici un tuto pour utiliser l'accéléromètre et configurer les fonctionnalités de l'input shaper de klipper.  

## Sommaire

* [Pré-requis](#pré-requis)
* [Principe](#principe)
* [Préparer la board portable input shaper (PIS)](#préparer-la-board-portable-input-shaper-pis)
    * [Compiler klipper sur la PIS](#compiler-klipper-sur-la-pis)
    * [Flasher la PIS](#flasher-la-pis)
* [Configuration de klipper (de l'imprimante)](#configuration-de-klipper-de-limprimante)
    * [Trouver la board](#trouver-la-board)
    * [Modifier la configuration klipper](#modifier-la-configuration-klipper)
* [Lancer les tests de résonance](#lancer-les-tests-de-résonance)
    * [Lancer](#lancer)
    * [Analyser les résultats](#analyser-les-résultats)
    * [Appliquer les nouvelles valeurs](#appliquer-les-nouvelles-valeurs)
* [Obtenir des graphs de la résonance](#obtenir-des-graphs-de-la-résonance)


----------------------------------------------------------------------------------------------------



## Pré-requis

Pour optimiser les vitesses et réduire le ghosting via l'input shaper, il faut :
* Klipper (à jour de préférence)
* La board PIS "portable input shaper" ([lien AliExpress](https://fr.aliexpress.com/item/1005005101353169.html))
* Un câble USB type A mâle (côté Rpi et PC) => USB type C mâle (côté PIS)
* Un accès SSH sur le RPI
* La configuration "pressure advance" dans klipper doit être désactivée (le pressure advance doit être fait après l'input shaper)


## Principe

Nous allons compiler puis flasher la board PIS avec klipper. Cette board contient le même chipset qu'un RPI (RP2040).  
Cette opération est à faire qu'une fois. Il n'est pas nécessaire de recompiler/flasher à chaque mise à jour klipper de l'imprimante.  

Nous allons ensuite configurer klipper de l'imprimante pour se connecter sur le klipper du PCB puis lancer les tests de résonances.  
Une fois les résultats obtenus, nous optimiserons les vitesses d'accélérations de l'imprimante et l'input shaper (compensation de résonance).



## Préparer la board portable input shaper (PIS)

Une fois de plus, ces opérations ne sont pas nécessaires si klipper est déjà flashé sur la board PIS.


### Compiler klipper sur la PIS


Avant de compiler klipper pour la board PIS, il est préférable de faire un backup de la configuration de compilation de l'imprimante :
```bash
cd ~/klipper
cp .config .config.bak
```

Nous préparons la configuration de compilation :
```bash
make menuconfig
```
Modifiez la configuration comme ceci :
* Micro-controller Architecture => Raspberry Pi RP2040
* Communication interface => USB

Il reste juste à quitter (avec la touche "Q" puis "Y" pour confirmer).

Nous pouvons lancer la compilation :
```bash
make
```

Une fois la compilation terminée, il faut maintenant récupérer le binaire compilé `~/klipper/out/klipper.uf2` sur son PC via SCP ou tout autre moyens (exemple, sur octoprint en le déplaçant dans `~/.octoprint/uploads`).


Après ces opérations, il est préférable de remettre la configuration de l'imprimante (sauvegardé plus haut) et recompiler pour cette dernière :
```bash
mv .config.bak .config
make clean
make
```



### Flasher la PIS

Pour brancher la board en mode flashboot sur votre PC, il faut :
1. Brancher le câble USB-C sur la PIS
2. Laisser le doigt appuyer sur le bouton présent sur la board PIS
3. Brancher l'autre extrémité du câble USB (type A) sur votre PC
4. Relâcher le bouton

Normalement le PC détecte un nouveau périphérique de type clé USB (nommé `RPI-RP2`).  
Il ne reste qu'à copier le fichier `klipper.uf2` sur ce périphérique. Après quelques secondes, le périphérique USB est automatiquement éjecté, c'est que le flash est terminé.




## Configuration de klipper (de l'imprimante)

### Installation du module pour klipper

En SSH, nous allons déjà installer les outils nécessaires (principalement pour faire les graphs) :
```bash
sudo apt update
sudo apt install python3-numpy python3-matplotlib libatlas-base-dev
~/klippy-env/bin/pip install -v numpy
```

La compilation de numpy prend quelques minutes (ne faites pas attention aux éventuelles warnings).



### Trouver la board

Branchez la board en USB sur le RPI.
En ligne de commande (via SSH), trouvez le chemin de la board RP2040 :
```bash
ls -l /dev/serial/by-id/
``` 
ou (si cela ne fonctionne pas) :
```bash
ls -l /dev/serial/by-path/
```

Notez bien le chemin complet de la board.


### Modifier la configuration klipper

Dans un nouveau fichier sur le RPI (`~/PIS.cfg`), collez le contenu suivant :
```yaml
[mcu PIS]
serial: /dev/serial/by-id/usb-Klipper_rp2040_E66118F5D7107436-if00

[adxl345]
cs_pin: PIS:gpio13
spi_software_sclk_pin: PIS:gpio10
spi_software_mosi_pin: PIS:gpio11
spi_software_miso_pin: PIS:gpio12
axes_map: x,-z,y

[resonance_tester]
accel_chip: adxl345
probe_points:
    175,175,20
```

Modifiez les valeurs suivantes :
* `serial` avec le chemin de la board trouvé juste avant
* `probe_points` : pour être au milieu de votre zone d'impression (ici un bed de 350x350) et à environ 2cm en Z


Dans votre fichier de configuration klipper, rajoutez la ligne suivante pour importer ce fichier :
```yaml
[include /home/pi/PIS.cfg]
```
Il faudra bien penser à la commenter une fois la board PIS débranchée.

Désactivez/supprimez toute présence du "pressure advance" dans la section `[extruder]` ou dans la configuration dynamique en bas de votre fichier `klipper.cfg` (les variables `pressure_advance` et/ou `pressure_advance_smooth_time`).

Sauvegardez et rechargez klipper.


## Lancer les tests de résonance


### Lancer

Fixez la board sur la tête.  
Elle ne doit surtout pas vibrer et être vraiment solidaire de la tête.

Faites un homing complet (un gantry ou bed leveling précis n'est pas nécessaire) :
```
G28
```

Nous pouvons lancer le test pour l'axe X avec le gcode suivant :
```
SHAPER_CALIBRATE AXIS=X
```
Le test dure 2 à 3 minutes (toutes les fréquences de 5 à 133Mhz). Notez les résultats dans un fichier texte pour les analyser après.

Même procédure pour l'axe Y (pour une cartésienne, fixez le PIS sur le bed avec du scotch) :
```
SHAPER_CALIBRATE AXIS=Y
```

Le test de résonance est bien entendu uniquement pour les axes X et Y, ne lancez jamais ce test pour le Z ou l'extrudeur !


### Analyser les résultats

Voici un exemple de résultat obtenu (issue de la doc klipper) :
```text=
Fitted shaper 'zv' frequency = 34.4 Hz (vibrations = 4.0%, smoothing ~= 0.132)
To avoid too much smoothing with 'zv', suggested max_accel <= 4500 mm/sec^2
Fitted shaper 'mzv' frequency = 34.6 Hz (vibrations = 0.0%, smoothing ~= 0.170)
To avoid too much smoothing with 'mzv', suggested max_accel <= 3500 mm/sec^2
Fitted shaper 'ei' frequency = 41.4 Hz (vibrations = 0.0%, smoothing ~= 0.188)
To avoid too much smoothing with 'ei', suggested max_accel <= 3200 mm/sec^2
Fitted shaper '2hump_ei' frequency = 51.8 Hz (vibrations = 0.0%, smoothing ~= 0.201)
To avoid too much smoothing with '2hump_ei', suggested max_accel <= 3000 mm/sec^2
Fitted shaper '3hump_ei' frequency = 61.8 Hz (vibrations = 0.0%, smoothing ~= 0.215)
To avoid too much smoothing with '3hump_ei', suggested max_accel <= 2800 mm/sec^2
Recommended shaper is mzv @ 34.6 Hz
```

Et voici comme l'analyser :
* L'algo recommandé est `mzv` (voir la dernière ligne)
* On note la fréquence, ici de `34.6 Hz`
* On recherche aussi l'accélération maximum pour l'algo recommandé. Ici `3500 mm/sec^2` car l'algo est `mzv`


### Appliquer les nouvelles valeurs

Dans la configuration klipper, vous pouvez modifier l'accélération de l'imprimante (variable `max_accel` de la section `[printer]`).  
**Attention** : il faut prendre la valeur la plus basse entre les résultats du X et du Y !  
Exemple : Si X=6500mm/sec^2 et Y=3500mm/sec^2, la valeur de `max_accel` sera de `3500`.

```
[printer]
max_accel: 3500
```

Pour les fréquences et l'algo, normalement un `SAVE_CONFIG` après les tests devrait le rajouter dans la partie dynamique de klipper (tout en bas, sous la section `SAVE_CONFIG` et en commentaire) mais vous pouvez le rajouter manuellement :

Exemple (avec l'algo et la fréquence pour l'axe X et Y) :
```yaml
[input_shaper]
shaper_freq_x: 34.6
shaper_type_x: mvz
shaper_freq_y: 47.5
shaper_type_y: ei
```

La configuration est terminée. Pensez à remettre la configuration de l'accéléromètre en commentaire à la fin puis sauvegardez :
```yaml
#[include /home/pi/PIS.cfg]
```


## Obtenir des graphs de la résonance

Cette partie est optionnelle.

Faites un home complet sur l'imprimante via le gcode `G28` (pas besoin de gantry, chauffe,...).

Lancez les gcodes/macros suivants :
```
TEST_RESONANCES AXIS=X
TEST_RESONANCES AXIS=Y
```

Puis lancez les scripts (en SSH) :
```bash
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_*.csv -o /tmp/shaper_calibrate_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_*.csv -o /tmp/shaper_calibrate_y.png
```

Reste à récupérer les images PNG (en SCP dans le dossier `/tmp`) ou les copier dans un dossier récupérable via l'interface Web.  
Exemple sur octoprint :
```bash
cp /tmp/shaper_calibrate_* ~/.octoprint/uploads/
```

Des graphs avec une grosse résonnance sur toute la durée du test sont souvent synonyme d'un problème de tension de courroie.  
Il est conseillé de relancer un test de résonance après chaque upgrade matériel de l'imprimante.

[Retour au sommaire](#sommaire)
