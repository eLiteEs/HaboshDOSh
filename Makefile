ASM = nasm
QEMU = qemu-system-x86_64

all: os.img

os.img: boot.bin kernel.bin babosh/test.bin
	# Crear imagen de 1.44MB (2880 sectores)
	dd if=/dev/zero of=os.img bs=512 count=2880

	# Escribir bootloader (primer sector)
	dd if=boot.bin of=os.img conv=notrunc

	# Verificar firma de arranque
	@if ! tail -c 2 boot.bin | hexdump -v -e '1/1 "%02X "' | grep -q "55 AA"; then \
		echo "ERROR: Firma de arranque faltante en boot.bin!"; \
		exit 1; \
	fi

	# Escribir kernel (sectores 2-9)
	dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc

	# Escribir programas BABOSH (sectores 10+)
	dd if=babosh/test.bin of=os.img bs=512 seek=10 conv=notrunc

boot.bin: boot/boot.asm
	$(ASM) -f bin $< -o $@
	@if [ $$(stat -c%s $@) -ne 512 ]; then \
		echo "ERROR: boot.bin debe ser exactamente 512 bytes"; \
		exit 1; \
	fi

kernel.bin: kernel/kernel.asm
	$(ASM) -f bin $< -o $@
	@echo "Tamaño del kernel: $$(stat -c%s $@) bytes"

babosh/test.bin: babosh/test.asm
	$(ASM) -f bin $< -o $@

clean:
	rm -f *.bin *.img babosh/*.bin

run: os.img
	$(QEMU) -fda os.img -curses -boot order=a

.PHONY: all clean run
