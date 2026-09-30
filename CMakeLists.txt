cmake_minimum_required(VERSION 3.22)

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/arm-none-eabi.cmake")

project(dst0x-app_bm1.0 C ASM)

set(CMAKE_C_STANDARD 11)

# ── Target flags ──────────────────────────────────────────────────────────────
set(CPU_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")

set(CMAKE_C_FLAGS   "${CPU_FLAGS} -Wall -Wextra -fdata-sections -ffunction-sections")
set(CMAKE_ASM_FLAGS "${CPU_FLAGS} -x assembler-with-cpp")

set(CMAKE_EXE_LINKER_FLAGS
    "${CPU_FLAGS} \
     -T${CMAKE_SOURCE_DIR}/linker/STM32F412RETX_FLASH.ld \
     -specs=nano.specs \
     -lc -lm -lnosys \
     -Wl,--gc-sections \
     -Wl,-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map,--cref"
)

# ── Include paths ─────────────────────────────────────────────────────────────
set(CMSIS_DEVICE_INC  ${CMAKE_SOURCE_DIR}/drivers/Device/ST/STM32F4xx/Include)
set(CMSIS_CORE_INC    ${CMAKE_SOURCE_DIR}/drivers/Include)
set(HAL_INC           ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Inc)
set(PROJECT_INC       ${CMAKE_SOURCE_DIR}/include)
set(BSP_INC           ${CMAKE_SOURCE_DIR}/bsp/inc)
set(APP_INC           ${CMAKE_SOURCE_DIR}/app/inc)
set(LOG_INC           ${CMAKE_SOURCE_DIR}/middleware/log)

# ── HAL driver sources ────────────────────────────────────────────────────────
file(GLOB HAL_SOURCES
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_cortex.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_dma.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_dma_ex.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_flash.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_flash_ex.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_flash_ramfunc.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_gpio.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_pwr.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_pwr_ex.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_rcc.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_rcc_ex.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_uart.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_tim.c
    ${CMAKE_SOURCE_DIR}/middleware/stm32f4xx_hal_driver/Src/stm32f4xx_hal_tim_ex.c
)

# ── Project sources ───────────────────────────────────────────────────────────
set(SOURCES
    ${CMAKE_SOURCE_DIR}/main.c
    ${CMAKE_SOURCE_DIR}/startup/startup_stm32f412retx.s
    ${CMAKE_SOURCE_DIR}/bsp/src/system_stm32f4xx.c
    ${CMAKE_SOURCE_DIR}/bsp/src/bsp.c
    ${CMAKE_SOURCE_DIR}/app/src/app.c
    ${CMAKE_SOURCE_DIR}/middleware/log/log.c
    ${HAL_SOURCES}
)

# ── Executable ────────────────────────────────────────────────────────────────
add_executable(${PROJECT_NAME} ${SOURCES})

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMSIS_DEVICE_INC}
    ${CMSIS_CORE_INC}
    ${HAL_INC}
    ${PROJECT_INC}
    ${BSP_INC}
    ${APP_INC}
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
    STM32F412Rx
    USE_HAL_DRIVER
)

# ── Post-build: generate .bin and print size ──────────────────────────────────
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary
        $<TARGET_FILE:${PROJECT_NAME}>
        ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
    COMMENT "Generating ${PROJECT_NAME}.bin"
)
