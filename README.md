# Overview
A simple starter template project that joins together [FreeRTOS](https://github.com/FreeRTOS/FreeRTOS-Kernel) and [libopencm3]() to blink an LED. 

Most of the file were either taken from or adapted from Warren Gay's [stm32f103c8t6 repo](https://github.com/ve3wwg/stm32f103c8t6) and the [libopencm3-template](https://github.com/libopencm3/libopencm3-template) repo.

# Dependencies
You will need the `Arm GNU Toolchain` to build and debug this repository. Download it either from from your package manager or from the [Arm developer](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm) website.

Install `openocd` to be able to flash and debug. The `stlink` package can also be used to flash.
# Building and Flashing
To clone the repo with all the submodules enter:

	git clone --recurse-submodules --depth 1 https://github.com/manjot-b/stm32-template

If you already cloned the repository without downloading the submodules you can download them now with:

	git submodule update --init --recursive --depth 1

`cd` into the root directory of the project and enter `make -jN` to build the project. Once built, hook up your programmer/st-link v2 to your STM32f103c8t6 and enter `make flash` to flash the binary **bin/myproject.elf** to the device.

If all went well you should see pin 13 on port C flashing at a steady rate.

# Changing Project Name
All source code is placed in **myproject/**. Rename this folder to the name of your project. Next, open up the `Makefile` and look for the following lines.

	# Redefine to the name of your project.
	BINARY				= myproject
	SOURCE_DIR			= myproject

Change `BINARY` to whatever you want and change `SOURCE_DIR` to whatever **myproject/** was renamed to. These variables don't need to have the same value.

# Adding FreeRTOS modules.
In the `Makefile` find the following lines

	SRCFILES	+= $(FREERTOS_DIR)/list.c
	SRCFILES 	+= $(FREERTOS_DIR)/tasks.c
	SRCFILES 	+= $(FREERTOS_PORT_DIR)/port.c
	SRCFILES 	+= $(FREERTOS_HEAP_DIR)/heap_4.c
	
	# SRCFILES 	+= $(FREERTOS_DIR)/croutine.c
	# SRCFILES 	+= $(FREERTOS_DIR)/event_groups.c
	# SRCFILES 	+= $(FREERTOS_DIR)/queue.c
	# SRCFILES 	+= $(FREERTOS_DIR)/stream_buffer.c
	# SRCFILES 	+= $(FREERTOS_DIR)/timers.c
	# SRCFILES 	+= $(FREERTOS_DIR)/portable/Common/mpu_wrappers.c

Change these lines by uncommenting them to include the necessary FreeRTOS modules. Don't forget to update **myproject/FreeRTOSConfig.h** to reflect this.
