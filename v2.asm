DATA SEGMENT PARA PUBLIC 'DATA' ; Start of data segment declaration

MAXLEN DB 100 ; Declare a byte variable MAXLEN and initialize it to 20
LEN DB 0 ; Declare a byte variable LEN and initialize it to 0

MSG DB 700 DUP(?) ; Declare a byte array MSG of size 20, uninitialized
BIN DB 16 DUP(0) ; Define BIN as a 16-byte array
ConvertedNumbers DB 100 DUP(?) ; Declare an array of 100 bytes to store converted numbers
BinaryArray DB 10000 DUP(?) ; Declare an array of 16 bytes
count DW ? ; Declare a word variable count
average DW ? ; Declare a word variable average
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

CALL AppendNullTerminator


CALL OutputNewLine
CALL OutputString




RET


START ENDP ; End of procedure START


ReadInput PROC NEAR
    ; Function: Read from file or device
    mov ah, 3Fh
    ; File handle 00h for standard input (keyboard)
    mov bx, 00h
    ; Maximum number of bytes to read
    mov cx, 100
    ; Pointer to buffer
    lea dx, MSG
    ; Call interrupt
    int 21h

    ; Initialize SI to point to the start of the MSG buffer
    lea si, MSG

    ; Initialize DI to point to the start of the converted numbers buffer
    lea di, ConvertedNumbers

    ; Initialize CX to the length of the input
    mov cx, 100

ConvertLoop:
    ; Check if we've processed all characters
    cmp cx, 0
    je EndLoop

    ; Load the current character into AL
    lodsb

    ; Check if the character is a digit
    cmp al, '0'
    jl NotADigit
    cmp al, '9'
    jg NotADigit

    ; Subtract '0' to convert the character to a number
    sub al, '0'

    ; Add the new digit to the current number
    add [di], al

    ; Multiply the current number by 10
    mov bl, [di]
    mov al, 10
    mul bl

    ; Store the multiplied number back
    mov [di], ax

    ; Decrement CX
    dec cx

    ; Continue with the next character
    jmp ConvertLoop

NotADigit:
    ; Move to the next number
    inc di

    ; Decrement CX
    dec cx

    ; Continue with the next character
    jmp ConvertLoop

EndLoop:
    ret
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
  MOV AX, average
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
    XOR CX, CX ; Clear CX
    mov cx, word ptr count
    dec cx  ; count-1
outerLoop:
    push cx
    lea si, MSG
    xor dx, dx ; flag to check if any swap happened
innerLoop:
    mov ax, [si]
    cmp ax, [si+2]
    jl nextStep
    xchg [si+2], ax
    mov [si], ax
    inc dx ; increment dx if a swap happened
nextStep:
    add si, 2
    loop innerLoop
    cmp dx, 0 ; check if any swap happened
    je sorted ; if no swap happened, array is sorted
    pop cx
    loop outerLoop
sorted:
    ret
SortArray ENDP

ConvertToWords PROC NEAR
    MOV SI, OFFSET BinaryArray ; Початкова адреса масиву чисел
    MOV DI, OFFSET MSG ; Початкова адреса масиву для збереження слів
    XOR CX, CX ; Очищення лічильника CX
    MOV BX, OFFSET BIN ; Початкова адреса BIN
    MOV CX, 16 ; Задання лічильника на 16 біт (16 символів)

ConvertLoopWords:
    MOV AL, [SI] ; Завантажити байт у AL
    CMP AL, 0 ; Перевірка, чи досягли ми кінця рядка
    JE EndWordConversion ; Якщо так, перейти до кінця конвертації
    ADD AL, '0' ; Конвертувати число у ASCII-символ
    MOV [DI], AL ; Зберегти символ у вихідний масив
    INC DI ; Збільшити вказівник на вихідний масив
    INC CX ; Збільшити лічильник
    INC SI ; Перейти до наступного числа
    JMP ConvertLoopWords ; Повторити цикл

EndWordConversion:
    MOV count, CX ; Оновити значення count з кількістю слів
    RET
ConvertToWords ENDP


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
    MOV AH, 02H ; Set AH to 09H to prepare for interrupt 21H function 09H (output string)
    lea dx, MSG ; Move the offset of MSG to DX
    INT 21H ; Call interrupt 21H, function 09H outputs a string
    RET
OutputString ENDP




CODE ENDS ; End of code segment declaration
END START ; End of program