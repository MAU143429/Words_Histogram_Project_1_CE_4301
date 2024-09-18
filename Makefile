build:
	nasm -f elf32 Algorithm.asm -o Algorithm.o
	ld -m elf_i386 Algorithm.o -o Algorithm

run: build
	qemu-system-i386 -nographic -no-reboot -hda Algorithm

debug: build
	gdb Algorithm

clean:
	rm -f Algorithm.o Algorithm

rev: build
	objdump -d Algorithm



