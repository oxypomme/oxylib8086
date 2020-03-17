DSEG        SEGMENT
        ; Define colors
        _BLACK_     EQU 00h
        _BLUE_      EQU 01h
        _GREEN_     EQU 02h
        _CYAN_      EQU 03h
        _RED_       EQU 04h
        _MAGENTA_   EQU 05h
        _BROWN_     EQU 06h
        _WHITE_     EQU 07h
        _GRAY_      EQU 08h
        _LBLUE_     EQU 09h
        _LGREEN_    EQU 0Ah
        _LCYAN_     EQU 0Bh
        _LRED_      EQU 0Ch
        _LMAGENTA_  EQU 0Dh
        _YELLOW_    EQU 0Eh
        _BWHITE_    EQU 0Fh
DSEG        ENDS

RESETVIDEOMEM:
    push AX
    mov  AX, 0A000h
    mov  ES, AX              ; Beginning of VGA memory in segment 0xA000
    pop  AX
    ret

SETVIDEOMODE:
    push AX
    mov  AX, 13h    ; Mode VGA de l'affichage, 13h signifie une mémoire de 320*200 avec 256 couleurs
    int  10h
    pop  AX
    ret

; SETUPGRAPHICS
;   initialize few things before we start 
oxgSETUPGRAPHICS:
    call RESETVIDEOMEM
    call SETVIDEOMODE
    ret

; FILL
;   fill the screen with color
oxgFILLS MACRO color
    push AX          ; on stocke les registres
    push DS
    push BX
    push CX
    push DI

    mov  AH, 06h
    mov  AL, 0       ; on remonte toutes les lignes
    mov  BH, color   ; on attribue de nouvelles lignes
    mov  CH, 0       ; la colonne la plus haute
    mov  CL, 0       ; la colonne la plus basse
    mov  DH, 25      ; le coin en bas à droite
    mov  DL, 39
    int  10h         ; on affiche

    oxgSETCURSOR 0, 0, 0

    pop  DI          ; on restore les registres
    pop  CX
    pop  BX
    pop  DS
    pop  AX
ENDM

; CLEAR
;   fill the screen with black color
oxgCLEAR MACRO
    oxgFILLS _BLACK_
ENDM

; SETCURSOR
;   set the cursor at (x,y) position at page
oxgSETCURSOR MACRO page, x, y
    push BX             ; on stocke les registres 
    push DX
    push AX

    mov  BH, page       ; page actuelle
    mov  DL, x          ; collonne actuelle
    mov  DH, y          ; ligne actuelle
    mov  AH, 02         ; on change la position du curseur
    int  10h            ; et on affiche

    pop  AX             ; on restore les registres
    pop  DX
    pop  BX
ENDM

; SHOWPIXEL
;   draw a pixel at (xA,yA) with color
oxgSHOWPIXEL MACRO xA, yA, color
    push AX          ; on stocke les registres 
    push CX
    push DX
    push BX

    mov  AL, color
    mov  CX, xA      ; position x du point
    mov  DX, yA      ; position y du point

    mov  AH, 0Ch     ; On veut afficher un pixel
    mov  BH, 1       ; page no - critical while animating
    int  10h         ; affichage

    pop  AX          ; on restore les registres
    pop  DX
    pop  CX
    pop  BX
ENDM

; SHOWHORLINE
;   draw a horizontal line from (xA,yA) to (xB,yA) with color
oxgSHOWHORLINE MACRO xA, yA, xB, color
    local drawLoop        ; on définit un label local
    
    pop CX                ; on sauvegarde le registre

    mov CX, xA            ; on met xA dans CX
    drawLoop:
        oxgSHOWPIXEL CX, yA, color  ; on dessine le pixel

        inc CX                      ; on augmente la position x

        cmp CX, xB                  ; on vérifie que la nouvelle position est ...
        jle drawLoop                ; ... <= au max. Oui => On recommence, non => on arrête
    
    push CX               ; on restaure le registre
ENDM

; SHOWVERTLINE
;   draw a vertical line from (xA,yA) to (xA,yB) with AL color
oxgSHOWVERTLINE MACRO xA, yA, yB, color
    local drawLoop        ; on définit un label local

    pop DX                ; on sauvegarde le registre

    mov DX, yA            ; on met xA dans CX
    drawLoop:
        oxgSHOWPIXEL xA, DX, color   ; on dessine le pixel

        inc DX                       ; on augmente sa position y

        cmp DX, yB                   ; on vérifie que la nouvelle position est ...
        jle drawLoop                 ; ... <= au max. Oui => On recommence, non => on arrête

    push DX               ; on restaure le registre
ENDM

; SHOWSQUARE
;   draw a square from (xA,yA) to (xB, yB) with AL color
oxgSHOWSQUARE MACRO xA, yA, xB, yB, color
    oxgSHOWHORLINE xA, yA, xB, color    ; on dessine la ligne en haut

    oxgSHOWVERTLINE xA, yA, yB, color   ; on dessine la ligne à gauche

    oxgSHOWHORLINE xA, yB, xB, color   ; on dessine la ligne en bas

    oxgSHOWVERTLINE xB, yA, yB, color  ; on dessine la ligne à droite
ENDM
