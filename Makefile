ASM = nasm
QEMU = qemu-system-x86_64

all: haboshdosh.img

haboshdosh.img: boot.bin kernel.bin babosh/test.bin
	dd if=/dev/zero of=haboshdosh.img.img bs=512 count=2880
	dd if=boot.bin of=haboshdosh.img conv=notrunc
	dd if=kernel.bin of=haboshdosh.img bs=512 seek=1 conv=notrunc
	dd if=babosh/test.bin of=haboshdosh.img bs=512 seek=10 conv=notrunc

boot.bin: boot/boot.asm
	$(ASM) -f bin $< -o $@
	@if [ $$(stat -c%s $@) -ne 512 ]; then \
		echo "Error: boot.bin debe ser exactamente 512 bytes"; exit 1; \
	fi

kernel.bin: kernel/kernel.asm
	$(ASM) -f bin $< -o $@
	@if [ $$(stat -c%s $@) -ne 4096 ]; then \
		echo "Error: kernel.bin debe ser exactamente 4096 bytes"; exit 1; \
	fi

babosh/test.bin: babosh/test.asm
	$(ASM) -f bin $< -o $@
	@if [ $$(stat -c%s $@) -ne 2048 ]; then \
		echo "Error: test.bin debe ser exactamente 2048 bytes"; exit 1; \
	fi

clean:
	rm -f *.bin *.img babosh/*.bin

run: haboshdosh.img
	$(QEMU) -fda haboshdosh.img -display curses

debug: haboshdosh.img
	$(QEMU) -fda haboshdosh.img -d int,cpu_reset -D qemu.log

.PHONY: all clean run debug
