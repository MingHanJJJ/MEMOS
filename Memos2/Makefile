all: 
	as --32 -o memos-2.o memos-2.s
	gcc -std=c99 -m32 -fno-stack-protector -fno-builtin -nostdinc -c kentry.c -o kentry.o
	ld -m elf_i386 -T memos-2.ld memos-2.o kentry.o -o memos-2
	mount /root/memos-2.img /mnt/C -text2 -o loop,offset=32256
	cp memos-2 /mnt/C/boot/
	cp menu.lst /mnt/C/boot/grub/
	umount /mnt/C/
	qemu-system-i386 -hda /root/memos-2.img -m 8
clean: 
	rm -f *.o