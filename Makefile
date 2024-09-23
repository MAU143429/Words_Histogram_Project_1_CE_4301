build:
	arm-linux-gnueabihf-as Algorithm.s -o Algorithm.o && arm-linux-gnueabihf-ld -static Algorithm.o -o Algorithm

run:
	./Algorithm


