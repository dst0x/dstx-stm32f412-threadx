# dst0x-app_bm1.0

Bare-metal firmware framework for the **STM32F412RETx** (Cortex-M4, 512 KB Flash, 256 KB SRAM).
Built with **CMake + arm-none-eabi-gcc**, developed in **VS Code**, and running **Azure RTOS ThreadX**.

---

## Hardware

| Item | Detail |
|------|--------|
| MCU | STM32F412RETx |
| Core | Cortex-M4 with FPU (hard-float) |
| Flash | 512 KB @ 0x08000000 |
| SRAM | 256 KB @ 0x20000000 |
| LED | PB2 (active HIGH) |
| UART2 TX | PA2 (AF7, 115200 8N1) |
| UART2 RX | PA3 (AF7, 115200 8N1) |

---

## Application behaviour

Two ThreadX threads run concurrently:

| Thread | Priority | Period | Action |
|--------|----------|--------|--------|
| `LED` | 5 | 500 ms | Toggles PB2 |
| `UART` | 5 | 500 ms | Reads LED pin state, logs `LED ON` or `LED OFF` over USART2 |

Both threads sleep via `tx_thread_sleep()`. The SysTick interrupt (1 kHz) drives both the ThreadX scheduler and `HAL_GetTick()`.

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
│   ├── stm32f4xx_hal_conf.h        HAL module selection + assert_param
│   └── tx_user.h                   ThreadX user config (1000 Hz tick)
├── drivers/
│   ├── Device/ST/STM32F4xx/Include CMSIS device headers (stm32f4xx.h, stm32f412rx.h)
│   └── Include/                    CMSIS core headers (core_cm4.h, …)
├── middleware/
│   ├── stm32f4xx_hal_driver/       STM32F4 HAL driver (Inc/ + Src/)
│   ├── threadx/                    Azure RTOS ThreadX (common/ + ports/cortex_m4/gnu/)
│   ├── log/
│   │   ├── log.h                   LOG_INFO/WARNING/ERROR macros + Log_Init/Log_Put
│   │   └── log.c                   Formatter: timestamp + level + func/line → callback
│   └── filex/                      Azure RTOS FileX (future use)
├── bsp/
│   ├── inc/
│   │   ├── bsp.h                   Umbrella header — includes bsp_gpio.h + bsp_usart.h
│   │   ├── bsp_gpio.h              LED pin macros + BSP_GPIO_Init / BSP_LED_* API
│   │   └── bsp_usart.h             UART2 pin macros + BSP_USART2_Init/Transmit API
│   └── src/
│       ├── bsp.c                   BSP_Init — delegates to BSP_GPIO_Init + BSP_USART2_Init
│       ├── bsp_gpio.c              GPIO init, LED On/Off/Toggle/GetState
│       ├── bsp_usart.c             USART2 init (115200 8N1), blocking transmit
│       ├── system_stm32f4xx.c      SystemInit (HSI 16 MHz, FPU enable)
│       └── tx_initialize_low_level.c  ThreadX low-level init: SysTick 1 kHz, PendSV priority
├── app/
│   ├── inc/app.h                   Application API
│   └── src/app.c                   App_Init, tx_application_define (2 threads), App_Run
├── main.c                          Entry point: HAL_Init → App_Init → App_Run (→ tx_kernel_enter)
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
  └── App_Init / App_Run              (app/)
        ├── Log_Init                  (middleware/log/)
        └── BSP_Init                  (bsp/bsp.c)
              ├── BSP_GPIO_Init       (bsp/bsp_gpio.c) — LED PB2
              └── BSP_USART2_Init     (bsp/bsp_usart.c) — PA2/PA3 115200
App_Run
  └── tx_kernel_enter()               (middleware/threadx/)
        └── tx_application_define()   (app/app.c)
              ├── Thread_LED          toggles LED every 500 ms
              └── Thread_UART         logs LED state every 500 ms via LOG_INFO → USART2
```

The BSP layer owns all board-specific pin and peripheral definitions, split by function:
- `bsp_gpio` — LED control
- `bsp_usart` — serial output

The app layer calls only BSP and Log APIs. Log output is routed through `BSP_USART2_Transmit` passed as a callback to `Log_Init`.

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
| `TX_INCLUDE_USER_DEFINE_FILE` | Makes ThreadX include `tx_user.h` |
