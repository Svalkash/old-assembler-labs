.MODEL  small

.STACK  100h

.DATA
    extrn eol:byte, maxlen:byte, actlen:byte, string:byte
    extrn filt:byte
.CODE

;IN:
;DI-write index
;SI-filt index
;STACK:
;AX-let to compare with
;SI-look index
find proc
    pushf
    push ax
    push bx
    push si
    mov al, filt[si]
    xor bh, bh
    mov bl, actlen
    ;prog
    mov si, di;si=di
ffor:
    cmp string[si], al
    jne fbad
    ;equal
    mov ah, string[di]
    mov string[si], ah
    mov string[di], al
    inc di
fbad:
    inc si
    ;for-loop
    cmp si, bx
    jb ffor
    ;pop
    pop si
    pop bx
    pop ax
    popf
    ret
find endp

;IN:
;STACK:
;FLAGS
;CX-counter
;SI-filt index
;DI-write index
transform proc
    pushf
    push ax
    push cx
    push si
    push di
    ;prog
    xor si, si
    xor di, di
    mov cx, 42d
    ;logic
wloop:
    call find
    inc si
    loop wloop
    ;new len
    mov string[di], '$'
    mov ax, di
    mov actlen, al
    ;popping
    pop di
    pop si
    pop cx
    pop ax
    popf
    ret
transform endp

public transform
end