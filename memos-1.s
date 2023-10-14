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

        call write_0x       # write "0x"
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

        call change_line

do_e820:
        # ax
        xor %ebx, %ebx              # ebx must be 0 to start
        movl $0x534D4150, %edx      # Place "SMAP" into edx
        movl $0xE820, %eax
        movl $24, %ecx              # ask for 24 bytes again
        int $0x15
        cmp $0x534D4150, %eax
        jne end

        call do_print

repeat_e820:
        movl $0xE820, %eax
        movl $24, %ecx              # ask for 24 bytes again

        int $0x15
        jc end
        cmp $0, %ebx                # terminate if the ebx is reset to 0
        je end
        cmp $0x534D4150, %eax
        jne end

        call do_print
        jmp repeat_e820

do_print:
        call print_str1
        call print_address
        call add_address_len
        call print_str2
        call print_address
        call print_str3
        call print_address_type
        call change_line
        ret

print_address:
        call write_0x
        movw %es:6(%di), %ax          # load the 2 bytes at ES:DI into %ax
        call print_2byte_in_ax
        movw %es:4(%di), %ax          # load the 2 bytes at ES:DI into %ax
        call print_2byte_in_ax
        movw %es:2(%di), %ax          # load the 2 bytes at ES:DI into %ax
        call print_2byte_in_ax
        movw %es:(%di), %ax          # load the 2 bytes at ES:DI into %ax
        call print_2byte_in_ax
        ret

add_address_len:
        movl %es:8(%di), %eax           # start address
        addl %eax, %es:(%di)           # add len
        ret

print_address_type:
        movw %es:16(%di), %ax          # load the 2 bytes at ES:DI into %ax
        cmp $1, %ax
        je print_type1
        cmp $2, %ax
        je print_type2
        ret

print_2byte_in_ax:
        movw %ax, %cx
        shr $8, %ax
        call print # write what is in AL to screen 
        movw %cx, %ax
        andb $0xFF, %ax
        call print
        ret

write_0x: # write "0x"
        movb $'0, %al
        movb $0x0E, %ah     # Set AH to 0x0E for BIOS Teletype output
        int $0x10           # Call BIOS interrupt 0x10 to print the character
        
        movb $'x, %al
        movb $0x0E, %ah     # Set AH to 0x0E for BIOS Teletype output
        int $0x10           # Call BIOS interrupt 0x10 to print the character
        ret

# this print function print 1 byte in AL in hex 
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

change_line:
        movb $13, %al
        movb $0x0E, %ah     
        int $0x10           
        
        movb $10, %al
        movb $0x0E, %ah     
        int $0x10           
        ret

print_str1: 
        leaw str_1, %si       
        movw str1_len, %cx 
1:      
        lodsb               
        movb $0x0E, %ah     
        int $0x10        
        loop 1b             
        ret

print_str2: 
        leaw str_2, %si       
        movw str2_len, %cx 
1:      
        lodsb               
        movb $0x0E, %ah     
        int $0x10        
        loop 1b             
        ret

print_str3: 
        leaw str_3, %si       
        movw str3_len, %cx 
1:      
        lodsb               
        movb $0x0E, %ah     
        int $0x10        
        loop 1b             
        ret

print_type1:
        leaw type1, %si       
        movw type1_len, %cx 
1:      
        lodsb               
        movb $0x0E, %ah     
        int $0x10        
        loop 1b             
        ret

print_type2:
        leaw type2, %si       
        movw type2_len, %cx 
1:      
        lodsb               
        movb $0x0E, %ah     
        int $0x10        
        loop 1b             
        ret

msg:    .asciz "MemOs: Weclome *** System memory is:"
msg_len:.word . - msg

munits: .asciz "KB"
u_len:  .word . - munits

str_1: .asciz "Address range ["
str1_len:  .word . - str_1

str_2: .asciz " : "
str2_len:  .word . - str_2

str_3: .asciz "] status: "
str3_len:  .word . - str_3

type1: .asciz "Free(1)"
type1_len:  .word . - type1

type2: .asciz "Reserved(2)"
type2_len:  .word . - type2


end:
        hlt

	.org 0x1FE

	.byte 0x55
	.byte 0xAA 

