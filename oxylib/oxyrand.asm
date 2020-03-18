DSEG        SEGMENT
    _seed       DW 0
    oxr_rand   DW 0
DSEG        ENDS


; Generate the seed to generate the random thing
; --> Thanks to https://github.com/oded8bit
genSeed:
    push AX
    push DX

    mov  AH, 00h
    int  1AH
    mov  [_seed], DX

    pop  DX
    pop  AX
    
    ret

; RANDOMWORD
;   Generate a word between min and max
oxr_RANDOMWORD MACRO min, max
    local randomize

    cmp _seed, 0
    jnz randomize
    call genSeed

    push DX
    push AX
    
    randomize:
        mov  ax, 25173           ; LCG Multiplier
        mul  [WORD PTR _seed] ; DX:AX = LCG multiplier * seed
        add  ax, 13849           ; Add LCG increment value
        ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
        mov  [oxr_rand], ax           ; Update seed = return value
        
        cmp oxr_rand, min
        jl  randomize
        cmp oxr_rand, max
        jg  randomize

    pop  AX
    pop  DX
ENDM

oxr_RANDOMBYTE MACRO min, max
    oxr_RANDOMWORD min, max
    and oxr_rand, 00FFh
ENDM
