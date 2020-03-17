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

; FILL
;   fill the screen with color
;   --> Thanks to https://github.com/AhmadNaserTurnkeySolutions/emu8086/blob/b99ea60f5dbf8647f278eef60ed1bd8a174468e5/inc/emu8086.inc#L470
oxgFILL MACRO color
        PUSH    AX      ; store registers...
        PUSH    DS      ;
        PUSH    BX      ;
        PUSH    CX      ;
        PUSH    DI      ;

        MOV     AX, 40h
        MOV     DS, AX  ; for getting screen parameters.
        MOV     AH, 06h ; scroll up function id.
        MOV     AL, 0   ; scroll all lines!
        MOV     BH, color  ; attribute for new lines.
        MOV     CH, 0   ; upper row.
        MOV     CL, 0   ; upper col.
        MOV     DI, 84h ; rows on screen -1,
        MOV     DH, [DI] ; lower row (byte).
        MOV     DI, 4Ah ; columns on screen,
        MOV     DL, [DI]
        DEC     DL      ; lower col.
        INT     10h

        ; set cursor position to top
        ; of the screen:
        MOV     BH, 0   ; current page.
        MOV     DL, 0   ; col.
        MOV     DH, 0   ; row.
        MOV     AH, 02
        INT     10h

        POP     DI      ; re-store registers...
        POP     CX      ;
        POP     BX      ;
        POP     DS      ;
        POP     AX      ;
ENDM

; CLEAR
;   fill the screen with black color
oxgCLEAR MACRO
    oxgFILL _BLACK_
ENDM

; SHOWPIXEL
;   draw a pixel at (xA,yA) with color
oxgSHOWPIXEL MACRO xA, yA, color
    mov AL, color
    mov CX, xA      ; position x du point
    mov DX, yA      ; position y du point

    mov AH, 0Ch     ; On veut afficher un pixel
    mov BH, 1       ; page no - critical while animating
    int 10h         ; affichage
ENDM

; SHOWHORLINE
;   draw a horizontal line from (xA,yA) to (xB,yA) with color
oxgSHOWHORLINE MACRO xA, yA, xB, color
    local drawLoop        ; on définit un label local

    mov CX, xA            ; on met xA dans CX
    drawLoop:
        oxgSHOWPIXEL CX, yA, color  ; on dessine le pixel

        inc CX                      ; on augmente la position x

        cmp CX, xB                  ; on vérifie que la nouvelle position est ...
        jle drawLoop                ; ... <= au max. Oui => On recommence, non => on arrête
ENDM

; SHOWVERTLINE
;   draw a vertical line from (xA,yA) to (xA,yB) with AL color
oxgSHOWVERTLINE MACRO xA, yA, yB, color
    local drawLoop        ; on définit un label local

    mov DX, yA            ; on met xA dans CX
    drawLoop:
        oxgSHOWPIXEL xA, DX, color   ; on dessine le pixel

        inc DX                       ; on augmente sa position y

        cmp DX, yB                   ; on vérifie que la nouvelle position est ...
        jle drawLoop                 ; ... <= au max. Oui => On recommence, non => on arrête
ENDM

; SHOWSQUARE
;   draw a square from (xA,yA) to (xB, yB) with AL color
oxgSHOWSQUARE MACRO xA, yA, xB, yB, color
    oxgSHOWHORLINE xA, yA, xB, color    ; on dessine la ligne en haut

    oxgSHOWVERTLINE xA, yA, yB, color   ; on dessine la ligne à gauche

    oxgSHOWHORLINE xA, yB, xB, color   ; on dessine la ligne en bas

    oxgSHOWVERTLINE xB, yA, yB, color  ; on dessine la ligne à droite
ENDM
