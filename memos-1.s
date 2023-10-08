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

# write "0x"
        movb $'0, %al
        movb $0x0E, %ah     # Set AH to 0x0E for BIOS Teletype output
        int $0x10           # Call BIOS interrupt 0x10 to print the character
        
        movb $'x, %al
        movb $0x0E, %ah     # Set AH to 0x0E for BIOS Teletype output
        int $0x10           # Call BIOS interrupt 0x10 to print the character
# probe menmory call BIOS interrupt 0x15 to set AX = 0xE801
        movw $0xE801, %ax
        int $0x15
        # ax holds KBs (1M-16M)
        # bx holds number of pages of 64KB above 16M
        addw $0x400, %ax    # 1024KB, convert the memory size from KB to MB
        movw %ax, %cx
        movw %bx, %dx

        # write looking Hex value for KBs of menmoy below 16MB
        shr $8, %ax
        call print # write what is in AL to screen 
        movw %cx, %ax
        andb $0xFF, %ax
        call print

        # finish with the memory units
        leaw munits, %si
        movw u_len, %cx
1:      
        lodsb
        movb $0x0E, %ah
        int $0x10
        loop 1b 
        jmp end


print:
        pushw %dx               # Save dx register on the stack
        movb %al, %dl           # Copy the input value (AL) to DL

        shrb $4, %al            # Shift right 4 bits to get the high nibble
        cmpb $10, %al           # Compare with 10
        jge 1f                  # Jump if greater or equal to 10
        addb $48, %al           # Add 48 ('0' offset) to convert to ASCII
        jmp 2f                  # Jump to the second part of the code

1:      addb $55, %al           # Subtract 10 from AL and add 55 to get ASCII ('A' - 10)
2:      movb $0x0E, %ah         # Set AH to 0x0E for BIOS Teletype output
        int $0x10               # Call BIOS interrupt 0x10 to print the character

        movb %dl, %al           # Restore the original input value to AL
        andb $0x0F, %al         # Mask out the high nibble to get the low nibble
        cmpb $10, %al           # Compare with 10
        jge 1f                  # Jump if greater or equal to 10
        addb $48, %al           # Add 48 ('0' offset) to convert to ASCII
        jmp 2f                  # Jump to the second part of the code

1:      addb $55, %al           # Subtract 10 from AL and add 55 to get ASCII ('A' - 10)
2:      movb $0x0E, %ah         # Set AH to 0x0E for BIOS Teletype output
        int $0x10               # Call BIOS interrupt 0x10 to print the character

        popw %dx                # Restore dx register from the stack
        ret                     # Return from the subroutine
        
        
        
msg:    .asciz "MemOs: Weclome *** System memory is:"
msg_len:.word . - msg

munits: .asciz "KB"
u_len:  .word . - munits

end:
        hlt

	.org 0x1FE

	.byte 0x55
	.byte 0xAA 