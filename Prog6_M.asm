.MODEL  small

.STACK  100h

.DATA
    filt    db  "bBcCdDfFgGhHkjJKlLmMnNpPqQrRsStTvVwWxXyYzZ"
    ifname  db  "fin.txt", 0
    ofname  db  "fout.txt", 0
    ifdescr dw  ?
    ofdescr dw  ?
    symbuf  db  ?
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
    maxlen  db  254
    actlen  db  ?
    string  db  255 dup ('') ;+1 for conversion $->0D-0A

    public eol, maxlen, actlen, string
    public ifname, ofname, ifdescr, ofdescr, symbuf
    public filt

.CODE

extrn readc:proc, printstr:proc
extrn readf:proc, writef:proc, openf:proc, closef:proc
extrn transform:proc

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