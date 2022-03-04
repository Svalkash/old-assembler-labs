.MODEL  small

.STACK  100h

.DATA
    extrn eol:byte, maxlen:byte, actlen:byte, string:byte
    extrn ifname:byte, ofname:byte, ifdescr:word, ofdescr:word, symbuf:byte
.CODE

;OUT:
;AX - if 0, eof. if 2, overflow
readf proc
    pushf
    push bx
    push cx
    push dx
    push si
    mov si, 0h
rfloop:
    ;check overflow
    mov cx, si
    cmp cl, maxlen
    je rfovfw
    ;calling
    mov ah, 3Fh
    mov bx, ifdescr
    mov cx, 1h
    lea dx, symbuf
    int 21h
    ;check eof
    cmp ax, 0h
    je rfeof
    ;check eoline
    cmp [symbuf], 0Dh
    je rfendline
    ;not eof/eol, addtostr
    mov cl, [symbuf]
    mov string[si], cl
    inc si
    jmp rfloop
rfovfw: ;skipping the rest of the string
    ;space for $
    dec si
    mov ax, 2h
rfendline:
    mov ah, 3Fh
    mov bx, ifdescr
    mov cx, 1h
    lea dx, symbuf
    int 21h
    cmp [symbuf], 0Ah
    jne rfendline
rfeof:
    mov string[si], '$'
    mov bx, si
    mov actlen, bl
    pop si
    pop dx
    pop cx
    pop bx
    popf
    ret
readf endp

writef proc
    pushf
    push ax
    push bx
    push cx
    push dx
    push si
    ;changing $ to OD-0A
    xor ah, ah
    mov al, actlen
    mov si, ax
    mov al, 0Dh
    mov string[si], al
    inc si
    mov al, 0Ah
    mov string[si], al
    ;
    mov ah, 40h
    mov bx, ofdescr
    xor ch, ch
    mov cl, actlen
    add cl, 2h ;for 0D,0A TO FILE Bly
    lea dx, string
    int 21h
    ;and back
    dec si
    mov al, '$'
    mov string[si], al
    ;ender
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret
writef endp

openf proc
    pushf
    push ax
    push cx
    push dx
    xor ax, ax
    ;open IN
    mov ax, 3D02h
    lea dx, ifname
    int 21h
    mov cl, 1h
    jc oferr
    mov ifdescr, ax
    ;open OUT
    mov ax, 3C00h
    mov cx, 0h
    lea dx, ofname
    int 21h
    mov cl, 2h
    jc oferr
    mov ofdescr, ax
    pop dx
    pop cx
    pop ax
    popf
    ret
oferr:
    mov al, cl
    pop dx
    pop cx
    pop ax
    popf
    mov ah, 4Ch
    int 21h
    ret
openf endp

closef proc
    pushf
    push ax
    push bx
    mov ah, 3Eh
    mov bx, ifdescr
    int 21h
    mov ah, 3Eh
    mov bx, ofdescr
    int 21h
    pop bx
    pop ax
    popf
    ret
closef endp

public readf, writef, openf, closef
end