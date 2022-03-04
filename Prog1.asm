.MODEL	small

.STACK	100h

.DATA
	A	DB	1
	B	DB	1
	C	DB	3
	D	DB	2
	E	DB	1
	F	DB	?

.CODE
	MOV AX, @DATA
	MOV	DS, AX ; Set DS
	;5(a^2+b^2)
	MOV	AL, A
	MUL AL	;AL = a^2
	JC	ERM
	ADD AL, B	;AL = a^2+b
	JC	ERM
	MUL AL	;AL = (..)^2
	JC	ERM
	MOV AH, 5h
	MUL AH	;AL = 5(..)^2
	JC	ERM
	MOV BH, AL	;BH = ...
	;a(2c-d^2)^2
	MOV AL, C
	MOV AH, 2h
	MUL AH	;AL = 2c
	JC	ERM
	MOV BL, AL	;BL = 2c
	MOV AL, D
	MUL AL	;AL = d^2
	JC	ERM
	SUB BL, AL	;BL = (2c-d^2)
	JC	ERM
	MOV AL, BL	;AL = ...
	MUL AL	;AL = (...)^2
	JC	ERM
	MUL A	;AL = a(...)^2
	JC	ERM
	ADD BH, AL	;BH = 5()^2+a()^2
	JC	ERM
	MOV AL, E
	;4e^2
	MUL E	;AL = e^2
	JC	ERM
	MOV AH, 4h
	MUL AH	;AL = 4e^2
	JC	ERM
	;MOVE ALL AND PREPARE PLACE IN AH
	MOV BL, AL	;BL = 4e^2
	XOR AH, AH
	MOV AL, BH	;AL = = 5()^2+a()^2
	;DIVIDE
	DIV BL	;AL = FUNCTION
	MOV F, AL
	;ENDER
	MOV AX, 4C00h
	INT 21h

ERM:
	MOV AX, 4C01h
	INT 21h
END