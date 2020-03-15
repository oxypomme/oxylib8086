DSEG        SEGMENT
        oxg_pointAx DW 1
        oxg_pointAy DW 1

        oxg_pointBx DW 1  
        oxg_pointBy DW 1 
DSEG        ENDS

RESETVIDEOMEM:
    mov AX, 0A000h
    mov ES, AX              ; Beginning of VGA memory in segment 0xA000
    ret

SETVIDEOMODE:
    mov  AX, 13h    ; Mode VGA de l'affichage, 13h signifie une mémoire de 320*200 avec 256 couleurs
    int  10h
    ret

; SETUPGRAPHICS
;   initialize few things before we start 
oxgSETUPGRAPHICS:
    call RESETVIDEOMEM
    call SETVIDEOMODE
    ret

; CLEAR
;   clear the screen
;   --> Thanks to https://stackoverflow.com/a/41318704
oxgCLEAR:
    cld                     ; Set forward direction for STOSD
    call SETVIDEOMODE

    push ES                 ; Save ES
    call RESETVIDEOMEM
    mov AX, 00              ; Set the color to clear with 00=black
    xor DI, DI              ; Destination address set to 0
    mov CX, (320*200)/2     ; We are doing 2 bytes at a time so count = (320*200)/2 DWORDS
    rep STOSW               ; Clear video memory
    pop ES                  ; Restore ES
    ret

; SHOWPIXEL
;   draw a pixel at (xA,yA) with color (hex code)
oxgSHOWPIXEL MACRO xA, yA, color
    mov Al, color
    mov CX, xA ; position x du point
    mov DX, yA ; position y du point

    mov AH, 0Ch     ; On veut afficher un pixel
    mov BH, 1       ; page no - critical while animating
    int 10h         ; affichage
ENDM

; SHOWHORLINE
;   draw a horizontal line from (oxg_pointAx,oxg_pointAy) to (oxg_pointBx,oxg_pointAy) with AL color
oxgSHOWHORLINE:
    call oxgSHOWPIXEL   ; on dessine le pixel

    inc CX              ; on augmente ...
    mov oxg_pointAx, CX ; ... sa position x

    cmp CX, oxg_pointBx ; on vérifie que la nouvelle position est ...
    jle oxgSHOWHORLINE  ; ... <= au max. Oui => On recommence, non => on arrête

    ret

; SHOWVERTLINE
;   draw a vertical line from (oxg_pointAx,oxg_pointAy) to (oxg_pointAx,oxg_pointBy) with AL color
oxgSHOWVERTLINE:
    call oxgSHOWPIXEL   ; on dessine le pixel

    inc DX              ; on augmente ...
    mov oxg_pointAy, DX ; ... sa position y

    cmp DX, oxg_pointBy ; on vérifie que la nouvelle position est ...
    jle oxgSHOWVERTLINE ; ... <= au max. Oui => On recommence, non => on arrête

    ret

; SHOWSQUARE
;   draw a square from (oxg_pointAx,oxg_pointAy) to (oxg_pointBx, oxg_pointBy) with AL color
oxgSHOWSQUARE:
    push oxg_pointAx    ; on sauvegarde la position x du point A
    call oxgSHOWHORLINE ; on dessine une ligne horizontale
    pop oxg_pointAx     ; on restaure la position x du point A

    push oxg_pointAy    ; on sauvegarde la position y du point A
    call oxgSHOWVERTLINE; on dessine une ligne verticale
    pop oxg_pointAy     ; on restaure la position y du point A

    push oxg_pointAy    ; on sauvegarde la position y du point A
    mov BX, oxg_pointBy ; on passe de l'autre côté du rectangle ...
    mov oxg_pointAy, BX ; ... cad on fait By => Ay (pour la ligne horizontale)

    push oxg_pointAx    ; on sauvegarde la position x du point A
    call oxgSHOWHORLINE ; on dessine une ligne horizontale
    pop oxg_pointAx     ; on restaure la position x du point A

    pop oxg_pointAy     ; on restaure l'ancienne position y du point A

    push oxg_pointAx    ; on sauvegarde la position x du point A
    mov BX, oxg_pointBx ; on passe de l'autre côté du rectangle ...
    mov oxg_pointAx, BX ; ... cad on fait  Bx => Ax (pour la ligne verticale)

    call oxgSHOWVERTLINE; on dessine une ligne verticale

    pop oxg_pointAx     ; on restaure l'ancienne position x du point A

    ret
