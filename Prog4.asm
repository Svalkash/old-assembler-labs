.MODEL  small

.STACK  100h

.DATA
    filt    db  'bBcCdDfFgGhHkjJKlLmMnNpPqQrRsStTvVwWxXyYzZ'
    ask     db  'Continue? (Y/N): $'
    eol     db  0Dh, 0Ah, '$'
    maxlen  db  255
    actlen  db  ?
    string  db  255 dup ('')

.CODE

;IN:
;DI-write index
;SI-filt index
;STACK:
;AX-let to compare with
;SI-look index
find proc
    push ax
    push bx
    mov al, filt[si]
    xor bh, bh
    mov bl, actlen
    push si
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
    ret
find endp

;IN:
;STACK:
;FLAGS
;CX-counter
;SI-filt index
;DI-write index
work proc
    pushf
    push cx
    push si
    push di
    ;prog
    xor si, si
    xor di, di
    mov cx, 42
    ;logic
wloop:
    call find
    inc si
    loop wloop
    ;new len
    mov string[di], '$'
    ;popping
    pop di
    pop si
    pop cx
    popf
    ret
work endp



start:
    mov ax, @data
    mov ds, ax
mloop:
    lea dx, maxlen
    xor ax, ax
    mov ah, 0Ah
    int 21h
    lea dx, eol
    mov ah, 09h
    int 21h
    ;work with str
    call work
    ;output
    lea dx, string
    mov ah, 09h
    int 21h
    ;\n, WINDOWS FORMAT
    lea dx, eol
    mov ah, 09h
    int 21h
    ;askformore
    lea dx, ask
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    ;check al
    lea dx, eol
    mov ah, 09h
    int 21h
    cmp al, 'Y'
    je mloop
    cmp al, 'y'
    je mloop
    ;stopping
    mov ax, 4C00h
    int 21h
end start