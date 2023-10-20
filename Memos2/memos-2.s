# memOS-2

    .global _start
    .code32

_start:
        jmp real_start

        .align 4
        .long 0x1BADB002  # Multiboot magic number 
        .long 0x00000003  # Align modules to 4KB, req. mem size 
                          # See 'info multiboot' for further info 
        .long 0xE4524FFB  # Checksum 

real_start:

multiboot_entry:
        /* Initialize the stack pointer. */
        movl $0x4000, %esp
        /* Push the pointer to the Multiboot information structure. */
        pushl %ebx
        
        call kmain

        add $4, %esp

        hlt


