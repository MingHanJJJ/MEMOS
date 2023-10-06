# memOS-1
    .global _start
    .code16

_start:
        movw $0x9000, %ax
        movw %ax, %ss
        xorw %sp, %sp  #set sp to zero, sp: stack pointer

        movw $0x7C0, %dx # BIOS load MBR at 0x7C00
        movw %dx, %ds

        leaw msg, %si       # load total address to si
        movw msg_len, %cx # load len to cx
1:      
        lodsb               #load abyte from DS:SI to AL & increment SI
        movb $0x0E, %ah     # Set AH to 0x0E for BIOS Teletype output
        int $0x10           # Call BIOS interrupt 0x10 to print the character
        loop 1b             # Loop back to label 1 if CX is not zero (decrements CX)


msg:    .asciz "MemOs: Weclome *** System memory is:"
msg_len:.word . - msg

	.org 0x1FE

	.byte 0x55
	.byte 0xAA