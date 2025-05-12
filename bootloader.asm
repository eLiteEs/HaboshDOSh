org 0x7C00
bits 16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Mensaje de carga
    mov si, msg_loading
    call print_string

    ; Cargar kernel (sector 2)
    mov ah, 0x02
    mov al, 1           ; Número de sectores
    mov ch, 0           ; Cilindro
    mov cl, 2           ; Sector
    mov dh, 0           ; Cabeza
    mov dl, 0x00        ; Disco (0x00 para floppy en QEMU)
    mov bx, 0x7E00      ; Dirección de carga
    int 0x13
    jc disk_error       ; Error si Carry Flag = 1

    ; Saltar al kernel
    mov si, msg_kernel_loaded
    call print_string
    jmp 0x7E00

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

disk_error:
    mov si, msg_disk_error
    call print_string
    mov ah, 0x00        ; Esperar tecla
    int 0x16
    int 0x19            ; Reiniciar

msg_loading db "Cargando kernel...", 0x0D, 0x0A, 0
msg_kernel_loaded db "Kernel cargado. Saltando...", 0x0D, 0x0A, 0
msg_disk_error db "Error de disco! Reiniciando...", 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55
