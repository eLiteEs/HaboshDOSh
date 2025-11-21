[bits 16]
org 0x7E00

start:
	cli
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00
	sti

 	call clear_screen
	mov si, welcome_msg
	call print_string
	jmp cli_main

; ----- Funciones básicas -----
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
	xor ah, ah
	int 0x16
	ret

print_newline:
	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	mov al, 0x0A
	int 0x10
	ret

; ----- Comandos internos -----
help_cmd:
	mov si, help_msg
	call print_string
	ret

clear_cmd:
	call clear_screen
	ret

unknown_cmd:
	mov si, unknown_msg
	call print_string
	ret

echo_cmd:
	mov si, command_buffer
	add si, 5       ; Saltar "echo "
.echo_loop:
	mov al, [si]
	cmp al, 0
	je .echo_done
	mov ah, 0x0E
	int 0x10
	inc si
	jmp .echo_loop
.echo_done:
	call print_newline
	ret

; ----- Interfaz de comandos -----
cli_main:
	mov si, prompt
	call print_string
	mov di, command_buffer
	mov cx, 0
	mov byte [di], 0

.input_loop:
	call read_key
	
	cmp al, 0x0D        ; Enter
	je .execute
	cmp al, 0x08        ; Backspace
	je .backspace
	
	cmp cx, 31
	jge .input_loop
	
	mov [di], al
	inc di
	inc cx
	mov ah, 0x0E
	int 0x10
	jmp .input_loop

.backspace:
	cmp cx, 0
	je .input_loop
	dec di
	dec cx
	mov byte [di], 0
	mov ah, 0x0E
	mov al, 0x08
	int 0x10
	mov al, ' '
	int 0x10
	mov al, 0x08
	int 0x10
	jmp .input_loop

.execute:
	mov byte [di], 0
	call print_newline
	
	; Verificar comandos
	mov si, command_buffer
	
	; Comando 'help'
	mov di, help_str
	call compare_strings
	je .do_help
	
	; Comando 'clear'
	mov di, clear_str
	call compare_strings
	je .do_clear
	
	; Comando 'echo' (verificar si empieza con "echo ")
	mov di, echo_str
	call starts_with
	je .do_echo

	jmp .do_unknown

.do_help:
	call help_cmd
	jmp cli_main

.do_clear:
	call clear_cmd
	jmp cli_main

.do_echo:
	call echo_cmd
	jmp cli_main

.do_unknown:
	call unknown_cmd
	jmp cli_main

compare_strings:
	push si
	push di
.loop:
	mov al, [si]
	cmp al, [di]
	jne .not_equal
	test al, al
	jz .equal
	inc si
	inc di
	jmp .loop
.equal:
	xor ax, ax
	jmp .done
.not_equal:
	mov ax, 1
.done:
	pop di
	pop si
	ret

starts_with:
	push si
	push di
.check_loop:
	mov al, [di]
	cmp al, 0
	je .match
	cmp al, [si]
	jne .no_match
	inc si
	inc di
	jmp .check_loop
.match:
	xor ax, ax    ; ZF = 1
	jmp .done
.no_match:
	mov ax, 1     ; ZF = 0
.done:
	pop di
	pop si
	ret

; ----- Datos del kernel -----
welcome_msg db "HaboshDOSh alpha 4", 0x0D, 0x0A, 0
prompt db "> ", 0
help_msg db "Available commands:", 0x0D, 0x0A
		db "  help   - Show this list", 0x0D, 0x0A
		db "  clear  - Clear screen", 0x0D, 0x0A
		db "  echo   - Show text on the screen", 0x0D, 0x0A, 0
unknown_msg db "Unknown command", 0x0D, 0x0A, 0
help_str db "help", 0
clear_str db "clear", 0
echo_str db "echo ", 0
command_buffer times 32 db 0

times 4096-($-$$) db 0
