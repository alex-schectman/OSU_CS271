TITLE Project6   (Proj6_schectma.asm)

; Author: Alex Schectman
; Last Modified: 06/09/2024
; OSU email address: schectma@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 06/10/2024
; Description: This program reads ten integers of a limited length from user input
;				and stores them in an array as ASCII decimal values.
;				It is supposed to then convert them to integers, summarize them,
;				then display their sum and average. This was not achieved.


INCLUDE Irvine32.inc

mGetString MACRO message, string
	; This macro displays a prompt then receives user input.

	; Display prompt
	mDisplayString	message

	; Get user input to memory location
	PUSH	EDX
	MOV		EDX, string							; inString
	MOV		ECX, MAXSIZE						; Limit string length with count (use MAXSIZE)
	CALL	ReadString
	POP		EDX
	
	
	; Track and output bytes read
		; EAX will contain this after ReadString. Do not PUSH/POP EAX.

	; Output aforementioned memory location
		; inString will contain this after ReadString
ENDM

mDisplayString	MACRO	message
	PUSH	EDX
	MOV		EDX, message
	CALL	WriteString
	POP		EDX
ENDM

; (insert constant definitions here)
MAXSIZE	= 11								; Maximum size of input string.
INPUT_BUFFER = 10
ASCII_BUFFER = 10

.data

intro1		BYTE	"PROGRAMMING ASSIGNMENT 6: Desgining low-level I/O procedures", 13,10,0
credit		BYTE	"Written by: Alex Schectman",13,10,0
intro2		BYTE	"Please provide 10 signed decimal integers.",13,10,0
intro3		BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,10,0
prompt		BYTE	"Please enter a signed number: ",0
error		BYTE	"ERROR: You did not enter a signed number or your number was too big. ",13,10,0
redo		BYTE	"Please try again: ",0
summary		BYTE	"You entered the following numbers:",13,10,0
yourSum		BYTE	"The sum of these numbers is: ",0
yourAvg		BYTE	"The truncated average is: ",0
farewell	BYTE	"Thanks for playing!",13,10,0

bytes		DWORD	?

inString	BYTE	MAXSIZE	DUP(?)
outArray	SDWORD	MAXSIZE	DUP(?)
asciiArray	SDWORD	MAXSIZE	DUP(?)


.code
main PROC
	; Introduce program.
	PUSH	OFFSET	intro1
	PUSH	OFFSET	credit
	PUSH	OFFSET	intro2
	PUSH	OFFSET	intro3
	CALL	introduction						; Invoke macro to call proc to print strings
	
	; LOOP to convert string to ascii then to integer
		; Get 10 valid integers from user.
		MOV		ECX, MAXSIZE
		_readIn:
			PUSH	OFFSET	outArray		; + 16
			PUSH	OFFSET	inString		; + 12
			PUSH	OFFSET	error			; + 8
			CALL	ReadVal
			; TODO: add outArray in array
			LOOP	_readIn

		
		; Display the integers, their sum, and their truncated average.
			; Do all this in WriteVal.
			; TODO: calc. sum; calc. average -- these can occur anywhere in code
		_writeOut:
			PUSH	OFFSET	outArray
			CALL	writeVal

	; Close out program with farewell message.
	mDisplayString	OFFSET farewell

	Invoke ExitProcess,0
main ENDP

	introduction PROC
		; Input values: 
		PUSH	EBP
		MOV		EBP, ESP

		MOV		ECX, 4
		MOV		ESI, EBP

		_introduce:
			mDisplayString	[ESI + 20]
			SUB		ESI, 4
			LOOP	_introduce
		
		MOV		ESP, EBP
		POP		EBP
		RET		16
	introduction ENDP

	ReadVal PROC
		PUSH	EBP
		MOV		EBP, ESP
		PUSH	EAX
		PUSH	ECX

		; Get user input with mGetString
		_getInput:
			mGetString	OFFSET prompt, [EBP + 12]		; Outputs count (EAX) and inString.

		CLD											; Ensure EDI increments
		MOV		ECX, EAX							; Move string unit count to counter
		MOV		ESI, [EBP + 12]						; inString
		MOV		EDI, [EBP + 16]						; outArray
		MOV		AL, 0
		MOV		EAX, 0
		; Convert user input to single numeric SDWORD
		_convert:
			LODSB									; Load single byte
			
			; Validate all input chars are ints (ASCII 48-57)
			CMP		AL, 57
			JA		_error
			CMP		AL, 48
			JB		_error
			
			; TODO: convert to actual int
			MOV		EAX, numChar
			PUSH	EAX
			MOV		EAX, numInt
			MUL		EAX, 10
			POP		EDX
			ADD		EAX, EDX
			MOV		numInt, EAX

			; Store this single value in a memory variable
			_store:
				STOSB
			LOOP	_convert

			JMP		_finish

		_skip:
			DEC		ECX
			JMP		_convert

		; Display error, discard value, and re-prompt as necessary.
		_error:
			mDisplayString	[EBP + 8]
			MOV		ESI, 0
			JMP		_getInput
	
		_finish:
			
			POP		ECX
			POP		EAX
			MOV		ESP, EBP
			POP		EBP
			RET	16
	ReadVal ENDP

	WriteVal PROC
		PUSH	EBP
		MOV		EBP, ESP
		PUSH	EAX
		PUSH	EDX
		PUSH	ECX

		; Convert SDWORD value to string of ASCII digits.

		; Print this string to console using mDisplayString macro.

		POP		ECX
		POP		EDX
		POP		EAX
		MOV		ESP, EBP
		POP		EBP
		RET	4
	WriteVal ENDP

	xferContents PROC
		PUSH	EBP
		MOV		EBP, ESP
		PUSH	ESI
		PUSH	EDI
		PUSH	ECX

		MOV		ESI, [EBP + 4]			; outArray
		MOV		EDI, [EBP + 8]			; asciiArray
		MOV		EAX, [EBP + 12]			; LENGTHOF outArray
		MOV		ECX, EAX

		_xfer:	; this will just print for now
			MOV		EAX, ESI
			CALL	WriteDec
			CALL	CrLf
			ADD		ESI, [EBP + 12]
			LOOP	_xfer
		
		POP		ECX
		POP		EDI
		POP		ESI
		MOV		ESP, EBP
		POP		EBP
		RET	12
	xferContents ENDP

END main
