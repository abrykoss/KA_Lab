DATA SEGMENT PARA PUBLIC 'DATA' ; Start of data segment declaration
MAXLEN DB 20 ; Declare a byte variable MAXLEN and initialize it to 20
LEN DB 0 ; Declare a byte variable LEN and initialize it to 0
MSG DB 20 DUP(?) ; Declare a byte array MSG of size 20, uninitialized
BIN DB 16 DUP(0) ; Define BIN as a 16-byte array
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
CALL ConvertToBinary ; Call the method to convert the input to binary
CALL OutputNewLine ; Call the method to output a newline character

CALL AppendNullTerminator ; Call the method to append a null terminator to the input string

CALL OutputBinary ; Call the method to output the string

RET ; Return from procedure
START ENDP ; End of procedure START

ReadInput PROC NEAR
    MOV AH, 0AH ; Set AH to 0AH to prepare for interrupt 21H function 0AH (buffered input)
    MOV DX, OFFSET MAXLEN ; Move the offset of MAXLEN to DX
    INT 21H ; Call interrupt 21H, function 0AH reads a string from the keyboard
    RET
ReadInput ENDP

ConvertToBinary PROC NEAR
    MOV CX, 16 ; Set the counter to 16 (for 16 bits)
    MOV BX, OFFSET MSG ; Move the offset of MSG to BX
    MOV SI, 0 ; Initialize SI to 0

NextBit:
    SHL WORD PTR [BX], 1 ; Shift the bits of the word at [BX] to the left
    PUSHF ; Push the flags onto the stack
    POP AX ; Pop the flags into AX
    AND AL, 1 ; Isolate the carry flag (the last bit shifted out)
    ADD AL, '0' ; Convert the bit to a character ('0' or '1')
    MOV [BX+SI], AL ; Store the character in the output string
    INC SI ; Increment SI
    DEC CX ; Decrement the counter
    JNZ NextBit ; If the counter is not zero, go to the next bit

    RET
ConvertToBinary ENDP

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

OutputBinary PROC NEAR
    MOV CX, 16 ; Set the counter to 16 (for 16 bits)
    MOV BX, OFFSET BIN ; Move the offset of BIN to BX
    ADD BX, 15 ; Add 15 to BX to start from the end of the array

NextChar:
    MOV DL, [BX] ; Move the character at [BX] to DL
    MOV AH, 02H ; Set AH to 02H to prepare for interrupt 21H function 02H (print character)
    INT 21H ; Call interrupt 21H, function 02H prints a character
    DEC BX ; Decrement BX to move to the next character
    DEC CX ; Decrement the counter
    JNZ NextChar ; If the counter is not zero, go to the next character

    RET
OutputBinary ENDP

OutputString PROC NEAR
    MOV AH, 09H ; Set AH to 09H to prepare for interrupt 21H function 09H (print string)
    MOV DX, OFFSET BIN ; Move the offset of BIN to DX
    INT 21H ; Call interrupt 21H, function 09H prints a string
    RET
OutputString ENDP

CODE ENDS ; End of code segment declaration
END START ; End of program