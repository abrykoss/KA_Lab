DATA SEGMENT PARA PUBLIC 'DATA' ; Start of data segment declaration
MAXLEN DB 20 ; Declare a byte variable MAXLEN and initialize it to 20
LEN DB 0 ; Declare a byte variable LEN and initialize it to 0
MSG DB 20 DUP(?) ; Declare a byte array MSG of size 20, uninitialized
DATA ENDS ; End of data segment declaration

CODE SEGMENT PARA PUBLIC 'CODE' ; Start of code segment declaration
START PROC FAR ; Start of procedure START
ASSUME CS:CODE, DS:DATA ; Assume that CS points to CODE and DS points to DATA

PUSH DS ; Push DS onto the stack
XOR AX, AX ; Clear AX register
PUSH AX ; Push AX onto the stack
MOV AX,DATA ; Move the offset of DATA to AX
MOV DS, AX ; Move the value of AX to DS

CALL ReadInput ; Call the method to read input from the keyboard
CALL OutputNewLine ; Call the method to output a newline character

CALL AppendNullTerminator ; Call the method to append a null terminator to the input string

CALL OutputString ; Call the method to output the string

RET ; Return from procedure
START ENDP ; End of procedure START

ReadInput PROC NEAR
    MOV AH, 0AH ; Set AH to 0AH to prepare for interrupt 21H function 0AH (buffered input)
    MOV DX, OFFSET MAXLEN ; Move the offset of MAXLEN to DX
    INT 21H ; Call interrupt 21H, function 0AH reads a string from the keyboard
    RET
ReadInput ENDP

OutputNewLine PROC NEAR
    MOV DL, 10 ; Move 10 to DL
    MOV AH, 02H ; Set AH to 02H to prepare for interrupt 21H function 02H (output character)
    INT 21H ; Call interrupt 21H, function 02H outputs a character (newline in this case)
    RET
OutputNewLine ENDP

AppendNullTerminator PROC NEAR
    MOV AL, LEN ; Move the value of LEN to AL
    CBW ; Convert byte to word (sign-extend AL into AX)
    MOV SI, AX ; Move the value of AX to SI
    MOV MSG+SI, '$' ; Append a '$' to the end of the string in MSG
    RET
AppendNullTerminator ENDP

OutputString PROC NEAR
    MOV AH, 09H ; Set AH to 09H to prepare for interrupt 21H function 09H (output string)
    MOV DX, OFFSET MSG ; Move the offset of MSG to DX
    INT 21H ; Call interrupt 21H, function 09H outputs a string
    RET
OutputString ENDP

CODE ENDS ; End of code segment declaration
END START ; End of program
