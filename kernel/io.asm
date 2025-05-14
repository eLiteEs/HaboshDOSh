[bits 32]
global clear_screen  ; Exporta la función para C

clear_screen:
    pusha
    mov ax, 0x0F00   ; Atributo: blanco sobre negro
    mov edi, 0xB8000  ; Dirección de memoria VGA
    mov ecx, 80*25    ; Número de caracteres en pantalla (80x25)
    rep stosw         ; Llena la pantalla con espacios
    popa
    ret
