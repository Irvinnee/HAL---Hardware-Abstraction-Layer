/* Linker script for Arduino Uno R4 Minima (Renesas RA4M1 - R7FA4M1AB) */
/* Memory map based on RA4M1 datasheet */

MEMORY
{
    /* Flash: 256 KB starting at 0x00000000 */
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
    
    /* SRAM: 32 KB starting at 0x20000000 */
    RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 32K
}

/* Entry point */
ENTRY(Reset_Handler)

SECTIONS
{
    /* Vector table - must be at beginning of flash */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } > FLASH

    /* Code section */
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
        _etext = .;
    } > FLASH

    /* Initialized data - stored in flash, copied to RAM at startup */
    .data : AT(_etext)
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM

    /* Uninitialized data (BSS) */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    /* Stack - at end of RAM */
    _stack_size = 2048;
    _stack_end = ORIGIN(RAM) + LENGTH(RAM);
    _stack_start = _stack_end - _stack_size;

    /* Heap (optional) */
    _heap_start = _ebss;
    _heap_end = _stack_start;
}
