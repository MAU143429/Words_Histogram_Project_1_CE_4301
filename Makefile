build:
	arm-linux-gnueabihf-as Algorithm.s -o Algorithm.o && arm-linux-gnueabihf-ld -static Algorithm.o -o Algorithm

run:
	./Algorithm
	
host:
	qemu-arm -singlestep -g 1236 Algorithm

debug:
	gdb-multiarch Algorithm
	target remote localhost:1236
