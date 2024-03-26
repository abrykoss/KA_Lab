DATA SEGMENT PARA PUBLIC 'DATA' ; Start of data segment declaration
MAXLEN DB 50 ; Declare a byte variable MAXLEN and initialize it to 20
LEN DB 0 ; Declare a byte variable LEN and initialize it to 0
MSG DB 700 DUP(?) ; Declare a byte array MSG of size 20, uninitialized
BIN DB 16 DUP(0) ; Define BIN as a 16-byte array
BinaryArray DB 16 DUP(?) ; Declare an array of 16 bytes
count DW ? ; Declare a word variable count
DATA ENDS ; End of data segment declaration
CODE SEGMENT PARA PUBLIC 'CODE' ; Start of code segment declaration


START PROC FAR ; Start of procedure START
ASSUME CS:CODE, DS:DATA ; Assume that CS points to CODE and DS points to DATA
PUSH DS ; Push DS onto the stack
XOR AX, AX ; Clear AX register
PUSH AX ; Push AX onto the stack
MOV AX,DATA ; Move the offset of DATA to AX
MOV DS, AX ; Move the value of AX to DS
 CALL ReadInputAsWords; Call the method to read input from the keyboard

CALL AppendNullTerminator ; Call the method to append a null terminator to the input string
CALL SortArray ; Call the method to sort the array
CALL OutputString ; Call the method to output the sorted array




RET ; Return from procedure
START ENDP ; End of procedure START

ReadInput PROC NEAR
    MOV AH, 0AH ; Set AH to 0AH to prepare for interrupt 21H function 0AH (buffered input)
    MOV DX, OFFSET MAXLEN ; Move the offset of MAXLEN to DX
    INT 21H ; Call interrupt 21H, function 0AH reads a string from the keyboard
    RET
ReadInput ENDP

SortArray PROC NEAR
    lea si, MSG
    mov cx, word ptr count
    inc cx
outerLoop:
    push cx
    lea si, MSG
    mov dx, cx ; Copy the outer loop counter to dx for the inner loop
innerLoop:
    mov ax, [si]
    cmp ax, [si+2]
    jl nextStep
    xchg [si+2], ax
    mov [si], ax
nextStep:
    add si, 2
    dec dx ; Decrement dx instead of using loop
    jnz innerLoop ; Jump to innerLoop if dx is not zero
    pop cx
    dec cx ; Decrement cx instead of using loop
    jnz outerLoop ; Jump to outerLoop if cx is not zero
RET
SortArray ENDP

ReadInputAsWords PROC NEAR
    MOV AH, 0AH ; Set AH to 0AH to prepare for interrupt 21H function 0AH (buffered input)
    MOV DX, OFFSET MAXLEN ; Move the offset of MAXLEN to DX
    INT 21H ; Call interrupt 21H, function 0AH reads a string from the keyboard

    ; Start of conversion code
    MOV SI, OFFSET MSG ; Load the address of the input buffer into SI
    MOV DI, OFFSET BinaryArray ; Load the address of the output buffer into DI
    XOR CX, CX ; Clear CX to use it as a counter

    ConvertLoop:
        LODSB ; Load the byte at address SI into AL and increment SI
        CMP AL, 0 ; Check if we've reached the end of the string
        JE EndConversion ; If we have, jump to the end of the conversion code
        SUB AL, '0' ; Convert the ASCII digit to a number
        MOV [DI], AL ; Store the number in the output buffer
        INC DI ; Increment DI
        INC CX ; Increment the counter
        JMP ConvertLoop ; Repeat the loop

    EndConversion:
        MOV count, CX ; Update count with the number of elements entered
    ; Here you can call your sorting algorithm
    RET
ReadInputAsWords ENDP

OutputNewLine PROC NEAR
    MOV DL, 10 ; Move 10 to DL
    MOV AH, 02H ; Set AH to 02H to prepare for interrupt 21H function 02H (output character)
    INT 21H ; Call interrupt 21H, function 02H outputs a character (newline in this case)
    MOV DX, OFFSET MSG ; Move the offset of MSG to DX
    MOV AH, 09H ; Set AH to 09H to prepare for interrupt 21H function 09H (output string)
    INT 21H ; Call interrupt 21H, function 09H outputs a string
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
OutputString ENDP

CODE ENDS ; End of code segment declaration
END START ; End of program