; Saute une ligne
ln          PROC NEAR
            mov  DL, 10             ; Charge le caractère \n
            mov  AH, 2              ; Passe en affichage de caractère
            int  21H                ; Affiche le résultat
            ret
ln          ENDP

; Affiche une message
print       PROC NEAR
            mov  AH, 09H            ; Chargement de la fonction
            int  21H                ; Affichage du résultat de la fonction
            ret
print       ENDP

println     PROC NEAR
            call print
            call ln
            ret
println     ENDP

; Demande un message 
scan        PROC NEAR
            mov  AH, 0AH            ; Chargement de la fonction
            int  21H                ; Demande d'input
            call ln                 ; Saute une ligne
            ret
scan        ENDP
