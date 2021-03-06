%include oxygraph.asm
%include oxylib.asm

DSEG        SEGMENT
    ; Define few keys
    _Zkey_          EQU 2Ch
    _Qkey_          EQU 10h
    _Skey_          EQU 1Fh
    _Dkey_          EQU 20h
    _Upkey_         EQU 48h
    _Leftkey_       EQU 4Bh
    _Downkey_       EQU 50h
    _Rightkey_      EQU 4Dh
    _ESCkey_        EQU 01h
    _ENTERkey_      EQU 1Ch
    _SPACEkey_      EQU 39h

    oxj_framerate   DW 0
DSEG        ENDS

; FRM
;   wait before calc the next frame
oxj_FRM PROC NEAR
    cmp  oxj_framerate, 25
    jg   midfrm
    jmp  lowfrm
    lowfrm:
         oxDELAY 0FA0h
         jmp finnalyFrm
    midfrm:
         oxDELAY 0BB8h
         jmp finnalyFrm
    finnalyFrm:
         ret
oxj_FRM ENDP

; GETKEY
;   get keypressed in AH
oxj_GETKEY PROC NEAR
    mov  AH, 10h
    int  16h
    ret
oxj_GETKEY ENDP
