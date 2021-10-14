/* Linker script for ST STM32F103C8T6 */

MEMORY
{
	rom (rx) : ORIGIN = 0x08000000, LENGTH = 64K
	ram (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

/* Provied by libopencm3. */
INCLUDE cortex-m-generic.ld
