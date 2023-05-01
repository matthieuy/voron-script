Macros
=======


# Positions


## Home

Faire un home uniquement si c'est nécessaire (moteurs coupés, premier démarrage,...).

```
[gcode_macro HOME]
description: Faire un home uniquement si necessaire
gcode:
    {% if printer.toolhead.homed_axes != "xyz" %}
        {action_respond_info("Home")}
        G28
    {% endif %}
```


## Park

Déplacer la tête dans une zone assez haute pour soulever le bed (attention aux positions à adapter).

```
[gcode_macro PARK]
description: Park de la tete pour soulever le bed
gcode:
    {action_respond_info("Parking nozzle")} ; Log
    HOME                                    ; Home si necessaire
    G0 X320 Y340 Z250 F9000                 ; Deplacement dans une zone safe
```


## Clean

Déplace la tête vers le devant pour nettoyage.

```
[gcode_macro CLEAN]
description: Nettoyage tete
gcode:
    HOME                  ; Home si necessaire
    G1 X170 Y0 Z150 F9000 ; Deplacement tete
```

## Idle timeout

Lancer un gcode lorsque l'imprimante est inactive depuis un certain temps.
Dans la configuration klipper, il faut rajouter :
```
[idle_timeout]
timeout: 900 # Timeout apres 15min
gcode:
    IDLE_TIMEOUT
```

La macro associée :

```
[gcode_macro IDLE_TIMEOUT]
description: Timeout sans action
gcode:
    TURN_OFF_HEATERS    ; Coupure bed+hotend
    M107                ; Coupure fan
    G28 X Y             ; Home en X et Y
    G91                 ; Passage en position relative
    G0 X-5 Y-5          ; Deplacement (gauche+avant) pour couper les endstop optiques
    G90                 ; Passage en position absolue
    M84                 ; Coupure moteur
```


# Calibration


## Gantry (G32)

Faire un gantry (avec home avant et après).

```
[gcode_macro G32]
description: Faire un gantry level
gcode:
    G90                ; Position absolue
    G28                ; Home
    BED_MESH_CLEAR     ; On vire l'eventuel bed mesh
    QUAD_GANTRY_LEVEL  ; Gantry
    G28                ; Home

```

## Bed mesh

Faire un bed mesh et le sauvegarder dans la config.

```
[gcode_macro G29]
description: Faire un bed mesh et le sauvegarder
gcode:
    BED_MESH_CALIBRATE  ; Bed mesh
    G28                 ; Home
    SAVE_CONFIG         ; Sauvegarde
```

# Impression


## Trait de purge

Faire une purge de l'extrudeur via 2 traits.


```
[gcode_macro PURGE]
description: Purge de demarrage
gcode:
    {action_respond_info("Start purge")} ; Log
    G92 E0                               ; Reset de l'extrudeur
    G1 X1 Y0 Z60 F8000                   ; Deplacement (assez haut pour brosser la buse si necessaire)
    G1 Z0.22                             ; Descendre
    G1 X1 Y200.0 Z0.2 F1500.0 E15        ; Premiere ligne
    G1 X3 Y200.0 Z0.2 F5000.0            ; Decalage
    G1 X3 Y0 Z0.2 F1500.0 E25            ; Seconde ligne
    G1 Z0.18                             ; Descendre un peu
    G92 E0                               ; Reset de l'extrudeur
    {action_respond_info("End purge")}   ; Log
```    


## Démarrage d'un print

Dans le slicer, rajouter le gcode suivant : `PRINT_START`

Macro associée :
```
[gcode_macro PRINT_START]
description: Gcode avant le print
gcode:
    G32                            ; Gantry (avec home)
    BED_MESH_PROFILE LOAD=default  ; Chargement du bed mesh
    PURGE                          ; Trait de purge
```

## Fin d'un print

Dans le slicer, rajouter le gcode suivant : `PRINT_END`

Macro associée :

```
[gcode_macro PRINT_END]
description: Gcode fin de print
gcode:
    M400                         ; Vide le buffer
    G91                          ; Position relative
    G1 E-3.0 F3600               ; Retract filament
    G0 Z2.00 X20.0 Y20.0 F10000  ; Deplacement buse (stringing)
    G90                          ; Position absolue
    G28 X0 Y0                    ; Home en X et Y
    TURN_OFF_HEATERS             ; Coupure bed+hotend
    M107                         ; Coupure fan
```


## Annulation d'un print

Dans octoprint => Configuration => GCODE scripts => After print job is cancelled => `PRINT_CANCEL`

Macro associée :
```
[gcode_macro PRINT_CANCEL]
description: Gcode lors de l'annulation du print
gcode:
    G91             ; Passage en position relative
    G1 E-3.0 F3600  ; Retract filament
    G0 Z5.00 F10000	; Decallage de la tete vers le haut
    G90             ; Passage en position absolue
    G28 X0 Y0       ; Home X et Y
    M107            ; Coupure du fan
```


<!--
```
[gcode_macro PRINT_PAUSE]
description: Gcode lors d'une pause
gcode:
    SAVE_GCODE_STATE NAME=pause_print
    G1 X170 Y0 Z150 F4000
    

[gcode_macro PRINT_RESUME]
description: Gcode lors d'une reprise (apres une pause)
gcode:
    { action_respond_info("Le print n'est pas en pause.") }
-->