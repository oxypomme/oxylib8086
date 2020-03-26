; DELAY
;   wait before next instruction
;
;   time : time to wait (in µsec)
oxDELAY MACRO time
    push AX         ; on sauvegarde les registres
    push CX
    push DX
    
    mov  CX, 0h     ; poids fort du temps
    mov  DX, time   ; poids faible du temps bak = 09FFFh
    mov  AH, 86h    ; on veut arrêter le programme
    int  15h        ; on met en pause le programme

    pop  DX         ; on restaure les registres
    pop  CX
    pop  AX
ENDM
