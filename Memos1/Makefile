

all: 
	as --32 memos-1.s -o memos-1.o
	ld -T memos-1.ld memos-1.o -o memos-1
	qemu-system-i386 -hda memos-1 -m 8