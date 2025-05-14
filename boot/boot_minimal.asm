[bits 16]
org 0x7C00

start:
    mov si, msg
    mov ah, 0x0E
print_loop:
    lodsb
    test al, al
    jz hang
    int 0x10
    jmp print_loop
hang:
    jmp $

msg db "Bootloader funcionando!", 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55
