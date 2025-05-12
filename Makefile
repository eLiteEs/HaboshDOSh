# Makefile para compilar y ejecutar
ASM = nasm
ASMFLAGS = -f bin
QEMU = qemu-system-x86_64

all: bootloader.bin kernel.bin haboshdosh.img

bootloader.bin: bootloader.asm
	$(ASM) $(ASMFLAGS) $< -o $@

kernel.bin: kernel.asm
	$(ASM) $(ASMFLAGS) $< -o $@

haboshdosh.img: bootloader.bin kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880  # Disco de 1.44MB (floppy)
	dd if=bootloader.bin of=$@ conv=notrunc
	dd if=kernel.bin of=$@ seek=1 conv=notrunc  # Kernel en sector 2

run: haboshdosh.img
	$(QEMU) -fda haboshdosh.img

clean:
	rm -f *.bin *.img
