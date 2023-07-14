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

```
  => Génération d'une clé : XXXX
cp: cannot stat '/home/pi/scripts/.env.dist': No such file or directory
sed: can't read /home/pi/scripts/.env: No such file or directory
  => Activation
=> Configuration octoprint


make: *** [Makefile:72: out/klipper.elf] Error 1
cp: cannot stat '/home/pi/klipper/out/klipper.bin': No such file or directory

Compilation terminée
  => Klipper


5E85445E6B32A70330F68685429E3F21
=> Octoprint : redémarrage
/home/pi/.local/lib/python3.9/site-packages/environ/environ.py:639: UserWarning: /home/pi/voron/scripts/.env doesn't exist - if you're not configuring your environment separately, create one.
  warnings.warn(
[DEBUG] Arguments : {'timeout': 45, 'interval': 1, 'debug': True}
Traceback (most recent call last):
  File "/home/pi/.local/lib/python3.9/site-packages/environ/environ.py", line 275, in get_value
    value = self.ENVIRON[var]
  File "/usr/lib/python3.9/os.py", line 679, in __getitem__
    raise KeyError(key) from None
KeyError: 'OCTOPRINT_API_KEY'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/home/pi/voron/scripts/wait-octoprint.py", line 27, in <module>
    octoprint  = Octoprint(debug=args.debug)
  File "/home/pi/voron/scripts/octoprint_class.py", line 27, in __init__
    self.API_KEY = env('OCTOPRINT_API_KEY')
  File "/home/pi/.local/lib/python3.9/site-packages/environ/environ.py", line 125, in __call__
    return self.get_value(var, cast=cast, default=default, parse_default=parse_default)
  File "/home/pi/.local/lib/python3.9/site-packages/environ/environ.py", line 279, in get_value
    raise ImproperlyConfigured(error_msg)
environ.compat.ImproperlyConfigured: Set the OCTOPRINT_API_KEY environment variable
=> Vérification des mises à jour
  => Octoprint



Fichier upload/système non présent

https://stackoverflow.com/questions/11378607/oh-my-zsh-disable-would-you-like-to-check-for-updates-prompt
DISABLE_UPDATE_PROMPT=true


=> LED IDE
tee: /sys/class/leds/led0/trigger: No such file or directory


Klipper :
Version: v0.11.0-235-gb9247810
  Preprocessing out/src/generic/armcm_link.ld
  Linking out/klipper.elf
/usr/lib/gcc/arm-none-eabi/8.3.1/../../../arm-none-eabi/bin/ld: out/src/spicmds.o: in function `spidev_transfer':
/home/pi/klipper/src/spicmds.c:96: undefined reference to `spi_software_prepare'
/usr/lib/gcc/arm-none-eabi/8.3.1/../../../arm-none-eabi/bin/ld: /home/pi/klipper/src/spicmds.c:104: undefined reference to `spi_software_transfer'
/usr/lib/gcc/arm-none-eabi/8.3.1/../../../arm-none-eabi/bin/ld: out/src/i2ccmds.o: in function `command_i2c_write':
/home/pi/klipper/src/i2ccmds.c:61: undefined reference to `i2c_software_write'
/usr/lib/gcc/arm-none-eabi/8.3.1/../../../arm-none-eabi/bin/ld: out/src/i2ccmds.o: in function `command_i2c_read':
/home/pi/klipper/src/i2ccmds.c:78: undefined reference to `i2c_software_read'
/usr/lib/gcc/arm-none-eabi/8.3.1/../../../arm-none-eabi/bin/ld: out/src/i2ccmds.o: in function `command_i2c_modify_bits':
/home/pi/klipper/src/i2ccmds.c:111: undefined reference to `i2c_software_write'
/usr/lib/gcc/arm-none-eabi/8.3.1/../../../arm-none-eabi/bin/ld: /home/pi/klipper/src/i2ccmds.c:101: undefined reference to `i2c_software_read'
collect2: error: ld returned 1 exit status
make: *** [Makefile:72: out/klipper.elf] Error 1
cp: cannot stat '/home/pi/klipper/out/klipper.bin': No such file or directory
