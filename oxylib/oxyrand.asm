DSEG        SEGMENT
    _seed       DW 0
    oxr_rand    DW 0
DSEG        ENDS

; GENRND
; --> Thanks to https://stackoverflow.com/a/40709661
GENRND PROC NEAR
    mov     AX, 25173        ; LCG Multiplier
    mul     word ptr [_seed] ; DX:AX = LCG multiplier * seed
    add     AX, 13849        ; Add LCG increment value
    ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
    mov     [_seed], AX      ; Update seed = return value
    ret
GENRND ENDP

; oxr_GETRND
;   set in oxr_rand a random number
;   --> Thanks to https://stackoverflow.com/a/40709661
;
;   range : max value of random number
oxr_GETRND MACRO range
    push AX
    push BX
    push CX
    push DX

    mov  AH, 00h   ; interrupt to get system timer in CX:DX 
    int  1AH
    mov  [_seed], DX
    call GENRND    ; -> AX is a random number
    mov  DX, 0
    mov  CX, range    
    div  CX        ; here dx contains the remainder - from 0 to range-1

    mov  oxr_rand, DX

    pop  DX
    pop  CX
    pop  BX
    pop  AX
ENDM
