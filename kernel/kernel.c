void print_string(const char *msg) {
    asm volatile (
        "mov %[msg], %%si\n"
        "print_loop:\n"
        "lodsb\n"
        "test %%al, %%al\n"
        "jz end\n"
        "mov $0x0E, %%ah\n"  // Función BIOS para imprimir carácter
        "int $0x10\n"        // Llama al BIOS
        "jmp print_loop\n"
        "end:\n"
        :
        : [msg] "r" (msg)
        : "si", "eax"
    );
}

void main() {
    print_string("Hola desde C + BIOS!");
    while (1);
}
