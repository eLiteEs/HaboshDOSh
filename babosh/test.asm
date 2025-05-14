[bits 16]
org 0x8000

start:
    mov si, msg
    mov ah, 0x0E
.print_loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .print_loop
.done:
    retf  ; Retorno FAR al kernel

msg db "Programa ejecutado correctamente!", 0x0D, 0x0A, 0

times 2048-($-$$) db 0
