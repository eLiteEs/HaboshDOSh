[bits 16]
org 0x7E00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    call clear_screen
    mov si, welcome_msg
    call print_string
    jmp cli_main

; --------------------------------------------------
; FUNCIONES DEL KERNEL
; --------------------------------------------------
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

clear_screen:
    mov ah, 0x06
    xor al, al
    mov bh, 0x07
    xor cx, cx
    mov dx, 0x184F
    int 0x10
    mov ah, 0x02
    xor bh, bh
    xor dx, dx
    int 0x10
    ret

read_key:
    mov ah, 0x00
    int 0x16
    ret

; --------------------------------------------------
; INTERFAZ DE COMANDOS
; --------------------------------------------------
cli_main:
    mov si, prompt
    call print_string
    mov di, command_buffer
    xor cx, cx          ; Contador de caracteres

.input_loop:
    call read_key
    cmp al, 0x0D        ; Enter
    je .execute
    cmp al, 0x08        ; Backspace
    je .backspace
    
    ; Solo aceptar si hay espacio en el buffer
    cmp cx, 31
    jge .input_loop
    
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .input_loop

.backspace:
    test cx, cx
    jz .input_loop
    dec di
    dec cx
    mov byte [di], 0
    ; Imprimir backspace (borrar carácter en pantalla)
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .input_loop

.execute:
    mov byte [di], 0    ; Asegurar terminación nula
    call print_newline
    
    ; Solo ejecutar si hay comando
    cmp byte [command_buffer], 0
    je cli_main
    
    call execute_cmd    ; Cambiado de execute_command a execute_cmd
    jmp cli_main

execute_cmd:            ; Nombre cambiado para evitar conflictos
    ; Verificar comando vacío
    cmp byte [command_buffer], 0
    je .empty
    
    ; Cargar programa desde BABOSH
    mov si, command_buffer
    mov di, babosh_prefix
    call str_cat        ; Cambiado de strcat a str_cat

    ; Intento de carga
    mov bx, 0x8000      ; Dirección de carga
    mov cx, 10          ; Sector inicial (después del kernel)
    mov ax, 4           ; Sectores a leer (2KB)
    call load_file_fs    ; Cambiado de load_file a load_file_fs
    jc .not_found

    ; Ejecutar programa
    mov si, executing_msg
    call print_string
    mov si, command_buffer
    call print_string
    call print_newline

    ; Preparar retorno
    push word .return_point
    push word 0x0000    ; Segmento de retorno
    
    ; Saltar al programa
    jmp 0x0000:0x8000

.return_point:
    ; Programa terminó
    mov si, return_msg
    call print_string
    ret

.not_found:
    mov si, not_found_msg
    call print_string
    ret

.empty:
    ret

load_file_fs:           ; Nombre cambiado para evitar conflictos
    ; BX=dirección, CX=sector, AX=sectores
    push es
    push bx
    push ax
    
    mov dl, 0x00        ; Unidad de floppy
    mov dh, 0           ; Cabeza
    mov ch, 0           ; Cilindro
    
    ; ES:BX = buffer
    push 0x0000
    pop es
    
    mov ah, 0x02        ; Función de lectura
    int 0x13
    
    pop bx              ; Restaurar registros
    pop bx
    pop es
    ret

str_cat:                ; Nombre cambiado para evitar conflictos
    push di
.find_end:
    cmp byte [di], 0
    je .copy
    inc di
    jmp .find_end
.copy:
    cmp byte [si], 0
    je .done
    movsb
    jmp .copy
.done:
    mov byte [di], 0    ; Asegurar terminación nula
    pop di
    ret

print_newline:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

; --------------------------------------------------
; DATOS DEL KERNEL
; --------------------------------------------------
welcome_msg: db "HaboshDOSh v1.0", 0x0D, 0x0A, 0
prompt: db "> ", 0
executing_msg: db "Ejecutando: ", 0
return_msg: db "Programa terminado.", 0x0D, 0x0A, 0
not_found_msg: db "Comando no encontrado", 0x0D, 0x0A, 0
babosh_prefix: db "BABOSH/", 0
command_buffer: times 32 db 0

times 4096-($-$$) db 0
