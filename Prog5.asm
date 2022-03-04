.MODEL  small

.STACK  100h

.DATA
    ifname  db  "fin.txt", 0
    ofname  db  "fout.txt", 0
    ifdescr dw  ?
    ofdescr dw  ?
    filt    db  "bBcCdDfFgGhHkjJKlLmMnNpPqQrRsStTvVwWxXyYzZ"
    yours   db  "Your string: "
            db  '$'
    ask     db  "Enter your string: "
            db  '$'
    line    db  "________________________________________"
            db  0Dh, 0Ah
            db  '$'
    eofw    db  "WARNING: end of file reached"
            db  0Dh, 0Ah
            db  '$'
    ovfw    db  "WARNING: string is too long"
            db  0Dh, 0Ah
            db  '$'
    menu    db  "MENU:"
            db  0Dh, 0Ah
            db  "0 | Exit"
            db  0Dh, 0Ah
            db  "1 | Read from console"
            db  0Dh, 0Ah
            db  "2 | Read from file"
            db  0Dh, 0Ah
            db  "3 | Write to console"
            db  0Dh, 0Ah
            db  "4 | Write to file"
            db  0Dh, 0Ah
            db  "5 | Transform"
            db  0Dh, 0Ah
            db  0Dh, 0Ah
            db  "Choose your option: "
            db  '$'
    eol     db  0Dh, 0Ah, '$'
    symbuf  db  ?
    maxlen  db  254
    actlen  db  ?
    string  db  255 dup ('') ;+1 for conversion $->0D-0A

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
    mov cx, 42
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
    je rfof
    ;calling
    mov ah, 3Fh
    mov bx, ifdescr
    mov cx, 1h
    lea dx, symbuf
    int 21h
    ;check eof
    cmp ax, 0h
    je rfendline
    ;check eoline
    cmp [symbuf], 0Dh
    je rfendline
    ;not eof/eol, addtostr
    mov cl, [symbuf]
    mov string[si], cl
    inc si
    jmp rfloop
rfof: ;skipping the rest of the string
    mov ah, 3Fh
    mov bx, ifdescr
    mov cx, 1h
    lea dx, symbuf
    int 21h
    cmp [symbuf], 0Ah
    jne rfof
    ;space for $
    dec si
    mov ax, 2h
rfendline:
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

start:
    mov ax, @data
    mov ds, ax
    call openf
mloop:
    lea dx, line
    call printstr
    lea dx, menu
    call printstr
    ;option
    mov ah, 01h
    int 21h
    lea dx, eol
    call printstr
    lea dx, line
    call printstr
    ;analyze
    cmp al, '1'
    je optrc
    cmp al, '2'
    je optrf
    cmp al, '3'
    je optwc
    cmp al, '4'
    je optwf
    cmp al, '5'
    je optt
    jmp opte
optrc:
    lea dx, ask
    call printstr
    call readc
    lea dx, eol
    call printstr
    jmp mloop
optrf:
    call readf
    cmp ax, 0h
    je optrf_eof
    cmp ax, 2h
    je optrf_ovfw
    jmp mloop
optrf_eof:
    lea dx, eofw
    call printstr
    jmp mloop
optrf_ovfw:
    lea dx, ovfw
    call printstr
    jmp mloop
optwc:
    lea dx, yours
    call printstr
    lea dx, string
    call printstr
    lea dx, eol
    call printstr
    jmp mloop
optwf:
    call writef
    jmp mloop
optt:
    call transform
    jmp mloop
opte:
    call closef
    ;stopping
    mov ax, 4C00h
    int 21h
end start