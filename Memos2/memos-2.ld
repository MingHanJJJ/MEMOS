OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)
SECTIONS
{
	. = 0x100000;
	.ksection : {
		*(.*);
		. = ALIGN(0x1000);
	}
	.text : {*(.text)}
}