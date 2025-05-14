[bits 16]
org 0x7C00

start:
    ; Deshabilitar interrupciones durante la configuración
    cli
    
    ; Configurar segmentos y stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Stack crece hacia abajo desde 0x7C00
    
    ; Habilitar interrupciones
    sti

    ; Mostrar mensaje de carga
    mov si, loading_msg
    call print_string

    ; Resetear controlador de disco
    xor ah, ah
    xor dl, dl          ; DL = 0 (primera unidad de floppy)
    int 0x13
    jc disk_error

    ; Cargar kernel desde disco
    ; (8 sectores = 4KB a partir del sector 2)
    mov ah, 0x02        ; Función de lectura
    mov al, 8           ; Sectores a leer
    mov ch, 0           ; Cilindro 0
    mov cl, 2           ; Sector 2 (el 1 es el bootloader)
    mov dh, 0           ; Cabeza 0
    mov dl, 0           ; Unidad de floppy
    mov bx, 0x7E00      ; ES:BX = 0x0000:0x7E00 (justo después del bootloader)
    int 0x13
    jc disk_error       ; Si hay error (carry flag activado)

    ; Saltar al kernel
    jmp 0x0000:0x7E00

disk_error:
    mov si, error_msg
    call print_string
    jmp $               ; Colgar el sistema si hay error

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E        ; Función BIOS para imprimir carácter
    int 0x10
    jmp print_string
.done:
    ret

loading_msg db "Cargando kernel...", 0x0D, 0x0A, 0
error_msg db "Error de disco! Reinicie.", 0x0D, 0x0A, 0

; Rellenar hasta 510 bytes y añadir firma de arranque
times 510-($-$$) db 0
dw 0xAA55
