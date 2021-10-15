/* Simple LED task demo, using timed delays:
 *
 * The LED on PC13 is toggled in toggle_led_task().
 */
#include "FreeRTOS.h"
#include "task.h"

#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>

void
vApplicationStackOverflowHook(
  TaskHandle_t pxTask __attribute((unused)),
  portCHAR *pcTaskName __attribute((unused))
) {
	for(;;);	// Loop forever here..
}

static void
toggle_led_task(void *args __attribute((unused))) {

	for (;;) {
		gpio_toggle(GPIOC,GPIO13);
		vTaskDelay(pdMS_TO_TICKS(500));
	}
}

int
main(void) {

	// Version to setup clocks below has been deprecated.
	// rcc_clock_setup_in_hse_8mhz_out_72mhz(); // For "blue pill"
	rcc_clock_setup_pll(&rcc_hse_configs[RCC_CLOCK_HSE8_72MHZ]);

	rcc_periph_clock_enable(RCC_GPIOC);
	gpio_set_mode(
		GPIOC,
		GPIO_MODE_OUTPUT_2_MHZ,
		GPIO_CNF_OUTPUT_PUSHPULL,
		GPIO13);

	xTaskCreate(toggle_led_task,"LED",100,NULL,configMAX_PRIORITIES-2,NULL);
	vTaskStartScheduler();

	for (;;);
	return 0;
}

// End
