[bits 32]
extern main          ; Función en C
global _start        ; Punto de entrada
global print_char
global read_key

_start:
    call main        ; Llama al kernel en C
    cli
    hlt

; Función para imprimir un carácter (AH=0x0E, AL=carácter
print_char:
    mov ah, 0x0E
    int 0x10
    ret

; Función para leer una tecla (AH=0x00)
read_key:
    mov ah, 0x00
    int 0x16
    ret

