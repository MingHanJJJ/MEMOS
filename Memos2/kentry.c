#include "multiboot.h"

static unsigned short *videoram = (unsigned short *)0xB8000; //Base address of the VGA frame buffer
static int attrib = 0x0F; //black background, white foreground
static int csr_x = 0, csr_y = 0;
static char hexDigits[] = "0123456789ABCDEF";
#define COLS 80

void putc(unsigned char c){
    if(c == 0x09){ // Tab (move to next multiple of 8)
        csr_x = (csr_x + 8) & ~(8 - 1);
    } else if(c == '\r'){ // CR
        csr_x = 0;
    } else if(c == '\n'){ // LF (unix-like)
        csr_x = 0; 
        csr_y++;
    } else if(c >= ' '){ // Printable characters
        *(videoram + (csr_y * COLS + csr_x)) = c | (attrib << 8); // Put the character w/ attributes
        csr_x++;
    }
    if(csr_x >= COLS){ csr_x = 0; csr_y++;} // wrap around!
}

void puts(char *text, int size){
    for (int i = 0; i < size; i++){
		putc(text[i]);
	}
}

void print0x(){
    puts("0x", 2);
}

void printHex(unsigned long long num, int size){
    char hexBuffer[size]; // 32 bits
    int digitCount = 0;
    while(num != 0){
        hexBuffer[digitCount++] = hexDigits[num % 16];
        num /= 16;
    }
    // fill '0'
    while(digitCount < size){
        hexBuffer[digitCount++] = '0';
    }
    for (int i = size-1; i >= 0; i--){
		putc(hexBuffer[i]);
	}
}

void changeLine(){
    putc('\r');
    putc('\n');
}

void printType(unsigned long type){
    switch (type){
        case 1:
            puts("Free(1)", 7);
            break;
        case 2:
            puts("Reserved(2)", 11);
            break;
        default:
            break;
    }
}

void kmain(multiboot_info_t* mbd){
    puts("MemOS: Welcome *** Total Free Memory: ", 38);

    if(!(mbd->flags >> 6 & 0x1)) {
        puts("invalid memory map given by GRUB bootloader", 43);
    }
    printHex(mbd->mem_upper + mbd->mem_lower, 8);
    puts("KB", 2);
    changeLine();
    
    int i;
    for(i = 0; i < mbd->mmap_length; i += sizeof(memory_map_t)) {
        memory_map_t* mmmt = (memory_map_t*) (mbd->mmap_addr + i);
        unsigned long long base = mmmt->base_addr_high;
        unsigned long long len = mmmt->length_high;
        base =  base*0x100000000 + mmmt->base_addr_low;
        len =  len*0x100000000 + mmmt->length_low;
        
        puts("Address range [", 15);
        print0x(); printHex(base, 16); 
        puts(" : ", 3);
        print0x(); printHex(len + base, 16); 
        puts("] status: ", 10);
        printType(mmmt->type);
        changeLine();
    }

}

