DSEG        SEGMENT
    ; Define few keys
    _C_       EQU 9121
    _D_       EQU 8126
    _E_       EQU 7239
    _F_       EQU 6833
    _G_       EQU 6087
    _A_       EQU 5423
    _B_       EQU 4831
DSEG        ENDS

oxsPLAYSOUND MACRO frequency, duration
    locAL pause1, pause2

    push AX        ; save des registres
    push BX        ;
    push CX        ;
    push DX        ;

    mov     AL, 182         ; Prepare the speaker for the
    out     43h, AL         ;  note.
    ; mov     AX, 4560        ; Frequency number (in decimAL) for middle C.
    mov     AX, frequency        ; Frequency number (in decimAL) for middle C.

    out     42h, AL         ; Output low byte.
    mov     AL, AH          ; Output high byte.
    out     42h, AL 
    in      AL, 61h         ; Turn on note (get vALue from port 61h).
    
    or      AL, 00000011b   ; Set bits 1 and 0.
    out     61h, AL         ; Send new vALue.
    ; mov     BX, 25         ; Pause for duration of note.
    mov        BX, duration
    pause1:
         mov     CX, 65535
    pause2:
         dec     CX
         jne     pause2
         dec     BX
         jne     pause1
         in      AL, 61h         ; Turn off note (get vALue from port 61h).
         and     AL, 11111100b   ; Reset bits 1 and 0.
         out     61h, AL         ; Send new vALue.

    pop DX        ; recuperation des registres
    pop CX        ;
    pop BX        ;
    pop AX        ;
ENDM
