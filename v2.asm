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


 CALL ReadInput; Call the method to read input from the keyboard

CALL OutputNewLine ; Call the method to output a newline character
CALL ConvertToNumber

CALL CalculateAverage

 ; Call the method to output the string




RET


START ENDP ; End of procedure START


ReadInput PROC NEAR
    MOV AH, 0AH ; Set AH to 0AH to prepare for interrupt 21H function 0AH (buffered input)
    MOV DX, OFFSET MAXLEN ; Move the offset of MAXLEN to DX
    INT 21H ; Call interrupt 21H, function 0AH reads a string from the keyboard
    RET
ReadInput ENDP

CalculateAverage PROC
    ; Initialize AX and BX to 0
    XOR AX, AX
    XOR BX, BX

    ; Load the address of the array into SI
    LEA SI, BinaryArray

    ; Loop through each element of the array
    FOR_LOOP:
        ; Load the value of the current element into AL
        MOV AL, [SI]

        ; Check if the current element is a space
        CMP AL, ' '
        JNE ADD_NUMBER

        ; If it is a space, check the next character
        INC SI
        MOV AL, [SI]

        ; If the next character is not a digit, end the loop
        CMP AL, '0'
        JB END_LOOP
        CMP AL, '9'
        JA END_LOOP

        ; If the next character is a digit, decrement SI to process this digit
        DEC SI

        ADD_NUMBER:
        ; Convert the digit to a number and add it to AX
        SUB AL, '0'
        ADD AX, AX

        ; Increment the counter in BX
        INC BX

        ; Increment the pointer SI to the next element
        INC SI

        ; Continue the loop
        JMP FOR_LOOP

    END_LOOP:
    ; Divide the sum by the number of elements to get the average
    DIV BX

    ; The average is now in AX
  MOV DX, AX
    RET
CalculateAverage ENDP

ConvertToBinary PROC NEAR
    MOV CX, 16 ; Set the counter to 16 (for 16 bits)
    MOV BX, OFFSET BIN ; Move the offset of BIN to BX
    ADD BX, 15 ; Add 15 to BX to start from the end of the array

NextBit:
    MOV DX, AX ; Move the value of AX to DX
    AND DX, 1 ; Get the least significant bit of DX
    ADD DL, '0' ; Convert the bit to a character
    MOV [BX], DL ; Store the character at [BX]
    SHR AX, 1 ; Shift AX right by 1 bit (equivalent to dividing by 2)
    DEC BX ; Decrement BX to move to the next character
    DEC CX ; Decrement the counter
    JNZ NextBit ; If the counter is not zero, go to the next bit

    RET
ConvertToBinary ENDP

SortArray PROC NEAR
    ; Initialize outer loop counter
    mov cx, word ptr count
    inc cx

    ; Outer loop
    outerLoop:
        push cx ; Save the outer loop counter

        ; Initialize inner loop counter and array pointer
        mov dx, cx ; Copy the outer loop counter to dx for the inner loop
        lea si, MSG

        ; Inner loop
        innerLoop:
            mov ax, [si] ; Load the current element
            mov bx, [si+2] ; Load the next element

            ; Compare elements
            cmp ax, bx
            jl nextPair ; If the current element is less than the next element, move to the next pair

            ; Swap elements if necessary
            xchg ax, bx
            mov [si], ax
            mov [si+2], bx

        nextPair:
            add si, 2 ; Move to the next pair of elements
            dec dx ; Decrement dx instead of using loop
            jnz innerLoop ; Jump to innerLoop if dx is not zero

        pop cx ; Restore the outer loop counter
        dec cx ; Decrement cx instead of using loop
        jnz outerLoop ; Jump to outerLoop if cx is not zero

    ret
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

ConvertToNumber PROC NEAR
    MOV SI, OFFSET MSG ; Start of the string
    XOR AX, AX ; Clear AX to store the result
    XOR BX, BX ; Clear BX to use as a temporary register
    XOR CX, CX ; Clear CX to use as a counter
    MOV DL, [SI] ; Load the first character

    ; Check for negative sign
    CMP DL, '-' 
    JE HandleNegativeNumber 

    ; Handle positive numbers
    NextDigit_Positive:
        CMP DL, '0' ; Check if it's a valid digit
        JB ConvertComplete ; If not, conversion is complete
        CMP DL, '9' ; Check if it's a valid digit
        JA ConvertComplete ; If not, conversion is complete
        SUB DL, '0' ; Convert ASCII digit to numeric value
        SHL AX, 1 ; Shift existing value in AX left by one digit place (effectively multiplying by 10)
        ADD AX, DX ; Add new digit to AX
        INC SI ; Move to the next character
        MOV DL, [SI] ; Load the next character
        INC CX ; Increment the digit count
        JMP NextDigit_Positive

    ; Handle negative numbers
    HandleNegativeNumber:
        INC SI ; Move past the negative sign
        MOV DL, [SI] ; Load the next character

    NextDigit_Negative:
        CMP DL, '0' ; Check if it's a valid digit
        JB ConvertComplete ; If not, conversion is complete
        CMP DL, '9' ; Check if it's a valid digit
        JA ConvertComplete ; If not, conversion is complete
        SUB DL, '0' ; Convert ASCII digit to numeric value
        SHL AX, 1 ; Shift existing value in AX left by one digit place (effectively multiplying by 10)
        SUB AX, DX ; Subtract new digit from AX
        INC SI ; Move to the next character
        MOV DL, [SI] ; Load the next character
        INC CX ; Increment the digit count
        JMP NextDigit_Negative

    ConvertComplete:
    RET
ConvertToNumber ENDP








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

    MOV DX, OFFSET MSG ; Move the offset of MSG to DX
    MOV AH, 09H ; Set AH to 09H to prepare for interrupt 21H function 09H (output string)
    INT 21H ; Call interrupt 21H, function 09H outputs a string
    RET
OutputBinary ENDP

OutputString PROC NEAR
 MOV AH, 09H ; Set AH to 09H to prepare for interrupt 21H function 09H (output string)
MOV DX, OFFSET MSG ; Move the offset of MSG to DX
INT 21H ; Call interrupt 21H, function 09H outputs a string
OutputString ENDP
CODE ENDS ; End of code segment declaration
END START ; End of program