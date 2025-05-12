ENTRY(_start)

SECTIONS {
    . = 0x7E00;  /* Dirección de carga del kernel (1MB, común para modo protegido) */
    .text : { *(.text) }
    .data : { *(.data) }
    .bss  : { *(.bss) }
}
