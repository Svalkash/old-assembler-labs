.MODEL  small

.STACK  100h

.DATA
    extrn eol:byte, maxlen:byte, actlen:byte, string:byte
.CODE

readc proc
    pushf
    push ax
    push dx
    push si
    lea dx, maxlen
    xor ax, ax
    mov ah, 0Ah
    int 21h
    ;0D->$
    xor ah, ah
    mov al, actlen
    mov si, ax
    mov al, '$'
    mov string[si], al
    lea dx, eol
    mov ah, 09h
    int 21h
    pop si
    pop dx
    pop ax
    popf
    ret
readc endp

;IN:
;DX-string address (lea before call!)
printstr proc
    pushf
    push ax
    mov ah, 09h
    int 21h
    pop ax
    popf
    ret
printstr endp

public readc, printstr

end