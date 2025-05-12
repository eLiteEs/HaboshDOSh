qemu-system-x86_64 -fda haboshdosh.img -s -S &
gdb -ex "target remote localhost:1234" -ex "set architecture i8086" -ex "break *0x7C00" -ex "continue"
