.MODEL	small

.STACK	100h

.DATA

	A	DW	0110011011011100b
	R	DB	?

.CODE
	MOV AX, @DATA
	MOV DS, AX
;beginning
	MOV	AX,	A
	MOV	CX,	16d
	XOR	BL,	BL	;state
	XOR	BH,	BH	;counter
LP:	CMP BL,	0000b	;lol, state machine
	JZ	S0
	CMP BL,	0001b
	JZ	S1
	CMP BL,	0010b
	JZ	S2
	CMP BL,	0100b
	JZ	S3
	CMP BL,	1000b
	JZ	S4
S0:	SHL	AX,	1
	JC	T0
	JNC	T1
S1:	SHL	AX,	1
	JC	T2
	JNC	T1
S2:	SHL	AX,	1
	JC	T3
	JNC	T1
S3:	SHL	AX,	1
	JC	T0
	JNC	T4
S4:	SHL	AX,	1
	JC	T2
	JNC	T1
T0:	MOV	BL,	0000b
	LOOP	LP
	JMP EP
T1:	MOV	BL,	0001b
	LOOP	LP
	JMP EP
T2:	MOV	BL,	0010b
	LOOP	LP
	JMP EP
T3:	MOV	BL,	0100b
	LOOP	LP
	JMP EP
T4:	MOV	BL,	1000b
	INC	BH
	LOOP	LP
	JMP EP
	;ending
EP:	MOV	R,	BH
	MOV AX, 4C00h
	INT 21h
END