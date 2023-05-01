Input shaper (via un accéléromètre)
===================================

Voici un tuto pour utiliser l'accéléromètre et configurer les fonctionnalités de l'input shaper de klipper.

## Sommaire

* [Pré-requis](#pré-requis)
* [Principe](#principe)
* [Préparer la board portable input shaper (PIS)](#préparer-la-board-portable-input-shaper-pis)
    * [Compiler klipper pour la PIS](#compiler-klipper-pour-la-pis)
    * [Flasher la PIS](#flasher-la-pis)
* [Configuration de klipper (de l'imprimante)](#configuration-de-klipper-de-limprimante)
    * [Trouver la board](#trouver-la-board)
    * [Modifier la configuration klipper](#modifier-la-configuration-klipper)
* [Lancer les tests de résonance](#lancer-les-tests-de-résonance)
    * [Lancer](#lancer)
    * [Analyser les résultats](#analyser-les-résultats)
    * [Appliquer les nouvelles valeurs](#appliquer-les-nouvelles-valeurs)
* [Obtenir des graphs de la résonance](#obtenir-des-graphs-de-la-résonance)



## Pré-requis

Pour optimiser les vitesses via l'input shaper, il faut :
* Klipper (à jour de préférence)
* La board "portable input shaper" (PIS)
* Un câble USB type C mâle => USB type A mâle
* Un accès SSH sur le RPI
* La configuration "pressure advance" dans klipper doit être désactivée (le pressure advance doit être fait après l'input shaper)


## Principe

Nous allons flasher la board PIS avec klipper, configurer klipper de l'imprimante pour se connecter sur le klipper du PCB puis lancer les tests de résonances.  
Une fois les résultats obtenus, nous optimiserons les vitesses d'accélérations de l'imprimante.



## Préparer la board portable input shaper (PIS)

### Compiler klipper pour la PIS

**ATTENTION** : Il faut avoir la même version du firmware klipper sur votre imprimante et sur la board PIS.


Avant de compiler klipper pour la board PIS, il est préférable de faire un backup de la configuration de compilation de l'imprimante :
```bash
cd ~/klipper
cp .config .config.bak
```

On prépare la configuration de compilation :
```bash
make menuconfig
```
Modifier la configuration comme ceci :
* Micro-controller Architecture => Raspberry Pi RP2040
* Communication interface => USB

Il reste juste à quitter (avec la touche "Q" puis "Y" pour confirmer).

Nous pouvons lancer la compilation :
```bash
make
```

Une fois la compilation terminée, nous pouvons remettre la configuration de l'imprimante (sauvegardé plus haut) :
```bash
mv .config.bak .config
```

Il faut maintenant récupéré le binaire compilé `~/klipper/out/klipper.uf2` sur son PC via SCP ou tout autre moyens (ex sur octoprint en le déplaçant dans `~/.octoprint/uploads`).


### Flasher la PIS

Pour brancher la board en mode flashboot :
* Brancher le câble USB-C sur le PCB
* Laisser le doigt appuyer sur le bouton présent sur la board PIS
* Brancher l'autre extrémité du câble USB (type A) sur votre PC
* Relâcher le bouton

Normalement le PC détecte un nouveau périphérique de type clé USB (nommé `RPI-RP2`).  
Il ne reste qu'à copier le fichier `klipper.uf2` sur ce périphérique. Après quelques secondes, la board reboot.




## Configuration de klipper (de l'imprimante)

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
serial: /dev/serial/by-id/xxxx

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
[include ~/PIS.cfg]
```
Il faudra bien penser à la commenter une fois la board PIS débranchée.




## Lancer les tests de résonance


### Lancer

Fixez la board sur la tête.  
Elle ne doit surtout pas vibrer et être vraiment solidaire de la tête.

Faites un homing complet :
```
G28
```

Nous pouvons lancer le test pour l'axe X avec le gcode suivant :
```
SHAPER_CALIBRATE AXIS=X
```
Le test dure environ une minute. Notez les résultats dans un fichier texte pour les analyser après.

Vous pouvez relancer pour l'axe Y :
```
SHAPER_CALIBRATE AXIS=Y
```

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
Exemple : Si X=4000 et Y=6500, la valeur de `max_accel` sera de 4000.

```
[printer]
max_accel: 4000
```

Pour les fréquences et l'algo, normalement un `SAVE_CONFIG` après les tests devrait le rajouter dans la partie dynamique de klipper (tout en bas, sous le `SAVE_CONFIG`) mais vous pouvez le rajouter manuellement :

Exemple (avec l'algo et la fréquence pour l'axe X et Y) :
```yaml
[input_shaper]
shaper_freq_x: 34.6
shaper_type_x: mvz
shaper_freq_y: 47.5
shaper_type_y: ei
```

La configuration est terminée. Pensez à remettre la configuration de l'accéléromètre en commentaire puis sauvegardez :
```yaml
#[include ~/PIS.cfg]
```


## Obtenir des graphs de la résonance

Cette partie est optionnelle.

En SSH, nous installons les outils pour générer les graphs :
```bash
sudo apt update
sudo apt install python3-numpy python3-matplotlib libatlas-base-dev
~/klippy-env/bin/pip install -v numpy
```

Lancez les gcodes suivants :
```
TEST_RESONANCES AXIS=X
TEST_RESONANCES AXIS=Y
```

Puis lancer les scripts :
```bash
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_*.csv -o /tmp/shaper_calibrate_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_*.csv -o /tmp/shaper_calibrate_y.png
```

Reste à récupérer les images (en SCP) ou les copier dans un dossier récupérable via l'interface Web.  
Exemple sur octoprint :
```bash
cp /tmp/shaper_calibrate_* ~/.octoprint/uploads/
```

Des graphs avec une grosse résonnance sur toute la durée du test sont souvent synonyme d'un problème de tension de courroie.