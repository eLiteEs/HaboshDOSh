bits 16]
global _start

_start:
    ; Configurar segmentos
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; Llamar a función en C (opcional)
    extern main
    call main

    ; O ejecutar código en ASM directamente
    call print_hello

    cli
    hlt

print_hello:
    mov si, hello_msg
    mov ah, 0x0E
.print_loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .print_loop
.done:
    ret

hello_msg db "Kernel en ASM ejecutandose!", 0
