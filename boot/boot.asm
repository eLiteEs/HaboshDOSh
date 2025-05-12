bits 16]
org 0x7C00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Cargar kernel en 0x7E00 (1 sector después del bootloader)
    mov ah, 0x02
    mov al, 4          ; Número de sectores a leer
    mov ch, 0          ; Cilindro 0
    mov cl, 2          ; Sector 2
    mov dh, 0          ; Cabeza 0
    mov dl, 0x80       ; Disco duro
    mov bx, 0x7E00     ; Dirección de carga
    int 0x13
    jc disk_error

    ; Saltar al kernel
    jmp 0x7E00

disk_error:
    mov si, error_msg
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

error_msg db "Error de disco!", 0

times 510-($-$$) db 0
dw 0xAA55
