# -----------------------------
# Configuración
# -----------------------------
ASM = nasm
QEMU = qemu-system-i386

IMG = haboshdosh.img
ISO = haboshdosh.iso

BOOT_SRC = boot/boot.asm
KERNEL_SRC = kernel/kernel.asm
TEST_SRC = babosh/test.asm

BOOT_BIN = boot.bin
KERNEL_BIN = kernel.bin
TEST_BIN = test.bin

# -----------------------------
# Reglas principales
# -----------------------------
all: $(IMG)

# Crear imagen RAW de 1.44 MB
$(IMG): $(BOOT_BIN) $(KERNEL_BIN) $(TEST_BIN)
	@echo "Creando imagen RAW..."
	dd if=/dev/zero of=$(IMG) bs=512 count=2880
	dd if=$(BOOT_BIN) of=$(IMG) conv=notrunc
	dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc
	dd if=$(TEST_BIN) of=$(IMG) bs=512 seek=10 conv=notrunc
	@echo "Imagen RAW lista: $(IMG)"

# -----------------------------
# Compilación de binarios
# -----------------------------
$(BOOT_BIN): $(BOOT_SRC)
	$(ASM) -f bin $< -o $@
	@if [ $$(stat -c%s $@) -ne 512 ]; then \
		echo "Error: $(BOOT_BIN) debe ser exactamente 512 bytes"; exit 1; \
	fi

$(KERNEL_BIN): $(KERNEL_SRC)
	$(ASM) -f bin $< -o $@
	@if [ $$(stat -c%s $@) -ne 4096 ]; then \
		echo "Error: $(KERNEL_BIN) debe ser exactamente 4096 bytes"; exit 1; \
	fi

$(TEST_BIN): $(TEST_SRC)
	$(ASM) -f bin $< -o $@
	@if [ $$(stat -c%s $@) -ne 2048 ]; then \
		echo "Error: $(TEST_BIN) debe ser exactamente 2048 bytes"; exit 1; \
	fi

# -----------------------------
# Limpiar archivos generados
# -----------------------------
clean:
	@echo "Limpiando archivos binarios e imágenes..."
	rm -f *.bin *.img *.iso babosh/*.bin

# -----------------------------
# Ejecutar en QEMU
# -----------------------------
run: $(IMG)
	$(QEMU) -fda $(IMG) -display curses

debug: $(IMG)
	$(QEMU) -fda $(IMG) -d int,cpu_reset -D qemu.log

# -----------------------------
# Crear ISO booteable sin GRUB
# -----------------------------
iso: $(BOOT_BIN) $(KERNEL_BIN) $(TEST_BIN)
	@echo "Creando estructura temporal para ISO..."
	mkdir -p iso/boot
	cp $(BOOT_BIN) iso/boot/boot.bin
	cp $(KERNEL_BIN) iso/boot/kernel.bin
	cp $(TEST_BIN) iso/boot/test.bin

	@echo "Generando ISO booteable con mkisofs..."
	mkisofs -o $(ISO) \
		-b boot/boot.bin \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		iso

	@echo "ISO booteable lista: $(ISO)"
	rm -rf iso

# -----------------------------
# Declarar targets phony
# -----------------------------
.PHONY: all clean run debug iso

