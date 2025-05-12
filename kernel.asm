; Kernel básico (se carga en 0x7E00)
org 0x7E00
bits 16

start:
    mov si, msg_kernel
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

msg_kernel db "Hola desde el kernel!", 0x0D, 0x0A, 0
