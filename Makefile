ASM = nasm
QEMU = qemu-system-x86_64

all: os.img

os.img: boot.bin kernel.bin
	# Crear imagen de 1.44MB (2880 sectores)
	dd if=/dev/zero of=os.img bs=512 count=2880
	
	# Escribir bootloader (primer sector)
	dd if=boot.bin of=os.img conv=notrunc
	
	# Escribir kernel (sectores 2-9)
	dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc
	
	# Verificar firma de arranque
	@if ! tail -c 2 os.img | hexdump -v -e '1/1 "%02X "' | grep -q "55 AA"; then \
		echo "ERROR: Firma de arranque faltante!"; \
		exit 1; \
	fi

boot.bin: boot/boot.asm
	$(ASM) -f bin $< -o $@
	@if [ $$(stat -c%s $@) -ne 512 ]; then \
		echo "ERROR: boot.bin debe ser exactamente 512 bytes"; \
		exit 1; \
	fi

kernel.bin: kernel/kernel.asm
	$(ASM) -f bin $< -o $@
	@echo "Tamaño del kernel: $$(stat -c%s $@) bytes"

clean:
	rm -f *.bin *.img

run: os.img
	$(QEMU) -fda os.img -curses -boot order=a

.PHONY: all clean run
