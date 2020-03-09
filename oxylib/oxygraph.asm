DSEG        SEGMENT
        x_coord     DW 0
DSEG        ENDS

SETUPGRAPHICS:
    mov  AX, 0A000h
    mov  ES, AX
    mov  AX, 13h
    int  10h
    ret

; SHOWPIXEL NEEDS : color (to AL), X (to CX) and Y (to DX)
SHOWPIXEL:
    mov AH, 0Ch     ; ?
    mov BH, 1       ; page no - critical while animating
    int 10h         ; affichage
    ret

; SHOWPIXEL NEEDS : color (to AL), X1 (to CX), X2 (to BX) and Y (to DX)
SHOWHORLINE:
    mov x_coord, BX

    draw:
    call SHOWPIXEL

    inc CX
    cmp CX, x_coord
    jle draw

    ret
