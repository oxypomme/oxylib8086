DSEG        SEGMENT
        oxg_pointAx DW 1
        oxg_pointAy DW 1

        oxg_pointBx DW 1  
        oxg_pointBy DW 1 
DSEG        ENDS

oxgSETUPGRAPHICS:
    mov  AX, 0A000h
    mov  ES, AX
    mov  AX, 13h
    int  10h

    ret

; SHOWPIXEL
;   draw a pixel to (oxg_pointAx,oxg_pointAy) with AL color
oxgSHOWPIXEL:
    mov CX, oxg_pointAx
    mov DX, oxg_pointAy

    mov AH, 0Ch     ; On veut afficher un pixel
    mov BH, 1       ; page no - critical while animating
    int 10h         ; affichage

    ret

; SHOWHORLINE
;   draw a horizontal line from (oxg_pointAx,oxg_pointAy) to (oxg_pointBx,oxg_pointAy) with AL color
oxgSHOWHORLINE:
    call oxgSHOWPIXEL

    inc CX
    mov oxg_pointAx, CX

    cmp CX, oxg_pointBx
    jle oxgSHOWHORLINE

    ret

; SHOWVERTLINE
;   draw a vertical line from (oxg_pointAx,oxg_pointAy) to (oxg_pointAx,oxg_pointBy) with AL color
oxgSHOWVERTLINE:
    call oxgSHOWPIXEL

    inc DX
    mov oxg_pointAy, DX

    cmp DX, oxg_pointBy
    jle oxgSHOWVERTLINE

    ret

; SHOWSQUARE
;   draw a square from (oxg_pointAx,oxg_pointAy) to (oxg_pointBx, oxg_pointBy) with AL color
oxgSHOWSQUARE:
    push oxg_pointAx
    call oxgSHOWHORLINE
    pop oxg_pointAx

    push oxg_pointAy
    call oxgSHOWVERTLINE
    pop oxg_pointAy

    push oxg_pointAy
    mov BX, oxg_pointBy
    mov oxg_pointAy, BX

    push oxg_pointAx
    call oxgSHOWHORLINE
    pop oxg_pointAx

    pop oxg_pointAy

    push oxg_pointAx
    mov BX, oxg_pointBx
    mov oxg_pointAx, BX

    call oxgSHOWVERTLINE

    pop oxg_pointAx

    ret
