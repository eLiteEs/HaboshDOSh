[bits 16]
org 0x8000

start:
    ; Configurar registros de segmento
    mov ax, cs
    mov ds, ax
    mov es, ax
    
    ; Configurar pila temporal
    mov ss, ax
    mov sp, 0x7C00
    
    ; Mostrar mensaje - ¡USAR SOLO BIOS!
    mov si, success_msg
.print_loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .print_loop
.done:
    ; Retornar al kernel (FAR RET)
    retf

success_msg db "Test ejecutado correctamente!", 0x0D, 0x0A, 0

times 2048-($-$$) db 0
