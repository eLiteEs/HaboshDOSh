# Configuración
ASM = nasm
CC = gcc
LD = ld
CFLAGS = -m32 -ffreestanding -nostdlib -fno-pie -O0
LDFLAGS = -m elf_i386 -T kernel/linker.ld

# Archivos
BOOT_SRC = boot/boot.asm
KERNEL_ENTRY_SRC = boot/kernel_entry.asm
KERNEL_SRC = kernel/kernel.c
KERNEL_OBJ = build/kernel.o
KERNEL_ENTRY_OBJ = build/kernel_entry.o

# Crear directorio build/
$(shell mkdir -p build)

all: os-image

os-image: boot.bin kernel.bin
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd if=boot.bin of=disk.img conv=notrunc
	dd if=kernel.bin of=disk.img seek=1 conv=notrunc

boot.bin: $(BOOT_SRC)
	$(ASM) -f bin $< -o $@

kernel.bin: $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) $^ -o $@

$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_SRC)
	$(ASM) -f elf32 $< -o $@

$(KERNEL_OBJ): $(KERNEL_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

run: os-image
	qemu-system-x86_64 -fda disk.img

clean:
	rm -rf *.bin *.o *.img build/
