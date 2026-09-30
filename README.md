# dst0x-app_bm1.0

Bare-metal firmware framework for the **STM32F412RETx** (Cortex-M4, 512 KB Flash, 256 KB SRAM).
Built with **CMake + arm-none-eabi-gcc** and developed in **VS Code**.

---

## Hardware

| Item | Detail |
|------|--------|
| MCU | STM32F412RETx |
| Core | Cortex-M4 with FPU (hard-float) |
| Flash | 512 KB @ 0x08000000 |
| SRAM | 256 KB @ 0x20000000 |
| LED | PB2 (active HIGH) |

---

## Project structure

```
dst0x-app_bm1.0/
├── CMakeLists.txt                  Root CMake build file
├── cmake/
│   └── arm-none-eabi.cmake         Cross-compiler toolchain file
├── linker/
│   └── STM32F412RETX_FLASH.ld      Linker script (Flash + SRAM regions)
├── startup/
│   └── startup_stm32f412retx.s     Vector table + Reset_Handler
├── include/
│   └── stm32f4xx_hal_conf.h        HAL module selection + assert_param
├── drivers/
│   ├── Device/ST/STM32F4xx/Include CMSIS device headers (stm32f4xx.h, stm32f412rx.h)
│   └── Include/                    CMSIS core headers (core_cm4.h, …)
├── middleware/
│   ├── stm32f4xx_hal_driver/       STM32F4 HAL driver (Inc/ + Src/)
│   ├── filex/                      Azure RTOS FileX (future use)
│   └── threadx/                    Azure RTOS ThreadX (future use)
├── bsp/
│   ├── inc/bsp.h                   Board support API — LED macros + functions
│   └── src/
│       ├── bsp.c                   GPIO init, BSP_LED_On/Off/Toggle
│       └── system_stm32f4xx.c      SystemInit (HSI 16 MHz, FPU enable)
├── app/
│   ├── inc/app.h                   Application API
│   └── src/app.c                   App_Init (LED on), App_Run (superloop)
├── main.c                          Entry point: HAL_Init → App_Init → App_Run
└── .vscode/
    ├── c_cpp_properties.json       IntelliSense include paths + defines
    ├── tasks.json                  CMake Configure, Build, Clean, Flash tasks
    ├── launch.json                 cortex-debug / OpenOCD debug session
    └── settings.json               CMake Tools integration
```

---

## Prerequisites

| Tool | Version tested |
|------|----------------|
| `arm-none-eabi-gcc` | 14.2.1 |
| `cmake` | ≥ 3.22 |
| `openocd` | 0.12.0 |
| VS Code extension | **Cortex-Debug** (for debugging) |
| VS Code extension | **CMake Tools** (optional, for GUI) |

---

## Build

```bash
# Configure (first time or after CMakeLists changes)
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug

# Build
cmake --build build --parallel
```

Or in VS Code: **Ctrl+Shift+B → Build**

Build outputs land in `build/`:
- `dst0x-app_bm1.0.elf` — debug ELF
- `dst0x-app_bm1.0.bin` — raw binary for flashing
- `dst0x-app_bm1.0.map` — linker map

---

## Flash

Connect an ST-Link and run the VS Code task **Flash (OpenOCD ST-Link)**, or:

```bash
openocd \
  -f interface/stlink.cfg \
  -f target/stm32f4x.cfg \
  -c "program build/dst0x-app_bm1.0.elf verify reset exit"
```

---

## Debug

In VS Code: **Run → Start Debugging (F5)** with the **Debug (OpenOCD)** configuration.

Requires the [Cortex-Debug](https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug) extension.

---

## Architecture

```
main.c
  └── App_Init / App_Run          (app/)
        └── BSP_Init / BSP_LED_*  (bsp/)
              └── HAL_GPIO_*      (middleware/stm32f4xx_hal_driver/)
                    └── CMSIS     (drivers/)
```

The BSP layer owns all board-specific pin definitions. The app layer calls only BSP APIs — no direct register or HAL access above BSP.

---

## Compiler flags

```
-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
-Wall -Wextra -fdata-sections -ffunction-sections
```

Linker: `--gc-sections`, `nano.specs`, `libnosys`.

---

## Defines

| Define | Purpose |
|--------|---------|
| `STM32F412Rx` | Selects device header in `stm32f4xx.h` |
| `USE_HAL_DRIVER` | Enables STM32F4 HAL driver |
