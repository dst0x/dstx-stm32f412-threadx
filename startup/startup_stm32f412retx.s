/**
 * startup_stm32f412retx.s — Reset and vector table for STM32F412RETx
 */

  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb

  .global _estack
  .global Default_Handler

/* Stack and initial data symbols from linker script */
  .word _estack
  .word _sidata
  .word _sdata
  .word _edata
  .word _sbss
  .word _ebss

/**
 * Vector table
 */
  .section .isr_vector,"a",%progbits
  .type g_pfnVectors, %object

g_pfnVectors:
  .word _estack
  .word Reset_Handler
  .word NMI_Handler
  .word HardFault_Handler
  .word MemManage_Handler
  .word BusFault_Handler
  .word UsageFault_Handler
  .word 0
  .word 0
  .word 0
  .word 0
  .word SVC_Handler
  .word DebugMon_Handler
  .word 0
  .word PendSV_Handler
  .word SysTick_Handler
  /* External interrupts */
  .word WWDG_IRQHandler
  .word PVD_IRQHandler
  .word TAMP_STAMP_IRQHandler
  .word RTC_WKUP_IRQHandler
  .word FLASH_IRQHandler
  .word RCC_IRQHandler
  .word EXTI0_IRQHandler
  .word EXTI1_IRQHandler
  .word EXTI2_IRQHandler
  .word EXTI3_IRQHandler
  .word EXTI4_IRQHandler
  .word DMA1_Stream0_IRQHandler
  .word DMA1_Stream1_IRQHandler
  .word DMA1_Stream2_IRQHandler
  .word DMA1_Stream3_IRQHandler
  .word DMA1_Stream4_IRQHandler
  .word DMA1_Stream5_IRQHandler
  .word DMA1_Stream6_IRQHandler
  .word ADC_IRQHandler
  .word CAN1_TX_IRQHandler
  .word CAN1_RX0_IRQHandler
  .word CAN1_RX1_IRQHandler
  .word CAN1_SCE_IRQHandler
  .word EXTI9_5_IRQHandler
  .word TIM1_BRK_TIM9_IRQHandler
  .word TIM1_UP_TIM10_IRQHandler
  .word TIM1_TRG_COM_TIM11_IRQHandler
  .word TIM1_CC_IRQHandler
  .word TIM2_IRQHandler
  .word TIM3_IRQHandler
  .word TIM4_IRQHandler
  .word I2C1_EV_IRQHandler
  .word I2C1_ER_IRQHandler
  .word I2C2_EV_IRQHandler
  .word I2C2_ER_IRQHandler
  .word SPI1_IRQHandler
  .word SPI2_IRQHandler
  .word USART1_IRQHandler
  .word USART2_IRQHandler
  .word USART3_IRQHandler
  .word EXTI15_10_IRQHandler
  .word RTC_Alarm_IRQHandler
  .word OTG_FS_WKUP_IRQHandler
  .word TIM8_BRK_TIM12_IRQHandler
  .word TIM8_UP_TIM13_IRQHandler
  .word TIM8_TRG_COM_TIM14_IRQHandler
  .word TIM8_CC_IRQHandler
  .word DMA1_Stream7_IRQHandler
  .word 0
  .word SDIO_IRQHandler
  .word TIM5_IRQHandler
  .word SPI3_IRQHandler
  .word 0
  .word 0
  .word 0
  .word 0
  .word DMA2_Stream0_IRQHandler
  .word DMA2_Stream1_IRQHandler
  .word DMA2_Stream2_IRQHandler
  .word DMA2_Stream3_IRQHandler
  .word DMA2_Stream4_IRQHandler
  .word 0
  .word 0
  .word CAN2_TX_IRQHandler
  .word CAN2_RX0_IRQHandler
  .word CAN2_RX1_IRQHandler
  .word CAN2_SCE_IRQHandler
  .word OTG_FS_IRQHandler
  .word DMA2_Stream5_IRQHandler
  .word DMA2_Stream6_IRQHandler
  .word DMA2_Stream7_IRQHandler
  .word USART6_IRQHandler
  .word I2C3_EV_IRQHandler
  .word I2C3_ER_IRQHandler
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word RNG_IRQHandler
  .word FPU_IRQHandler
  .word 0
  .word 0
  .word SPI4_IRQHandler
  .word SPI5_IRQHandler
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word 0
  .word FMPI2C1_EV_IRQHandler
  .word FMPI2C1_ER_IRQHandler

/**
 * Reset handler — copies .data, zeroes .bss, calls main
 */
  .section .text.Reset_Handler
  .weak Reset_Handler
  .type Reset_Handler, %function
Reset_Handler:
  ldr sp, =_estack

  /* Copy .data from Flash to SRAM */
  ldr r0, =_sdata
  ldr r1, =_edata
  ldr r2, =_sidata
  movs r3, #0
  b LoopCopyDataInit

CopyDataInit:
  ldr r4, [r2, r3]
  str r4, [r0, r3]
  adds r3, r3, #4

LoopCopyDataInit:
  adds r4, r0, r3
  cmp r4, r1
  bcc CopyDataInit

  /* Zero .bss */
  ldr r2, =_sbss
  ldr r4, =_ebss
  movs r3, #0
  b LoopFillZerobss

FillZerobss:
  str r3, [r2]
  adds r2, r2, #4

LoopFillZerobss:
  cmp r2, r4
  bcc FillZerobss

  bl SystemInit
  bl main
  bx lr

/**
 * Default weak handler — loops forever
 */
  .section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b Infinite_Loop

  .macro WEAK_ALIAS name
  .weak \name
  .thumb_set \name, Default_Handler
  .endm

  WEAK_ALIAS NMI_Handler
  WEAK_ALIAS HardFault_Handler
  WEAK_ALIAS MemManage_Handler
  WEAK_ALIAS BusFault_Handler
  WEAK_ALIAS UsageFault_Handler
  WEAK_ALIAS SVC_Handler
  WEAK_ALIAS DebugMon_Handler
  WEAK_ALIAS PendSV_Handler
  WEAK_ALIAS SysTick_Handler
  WEAK_ALIAS WWDG_IRQHandler
  WEAK_ALIAS PVD_IRQHandler
  WEAK_ALIAS TAMP_STAMP_IRQHandler
  WEAK_ALIAS RTC_WKUP_IRQHandler
  WEAK_ALIAS FLASH_IRQHandler
  WEAK_ALIAS RCC_IRQHandler
  WEAK_ALIAS EXTI0_IRQHandler
  WEAK_ALIAS EXTI1_IRQHandler
  WEAK_ALIAS EXTI2_IRQHandler
  WEAK_ALIAS EXTI3_IRQHandler
  WEAK_ALIAS EXTI4_IRQHandler
  WEAK_ALIAS DMA1_Stream0_IRQHandler
  WEAK_ALIAS DMA1_Stream1_IRQHandler
  WEAK_ALIAS DMA1_Stream2_IRQHandler
  WEAK_ALIAS DMA1_Stream3_IRQHandler
  WEAK_ALIAS DMA1_Stream4_IRQHandler
  WEAK_ALIAS DMA1_Stream5_IRQHandler
  WEAK_ALIAS DMA1_Stream6_IRQHandler
  WEAK_ALIAS ADC_IRQHandler
  WEAK_ALIAS CAN1_TX_IRQHandler
  WEAK_ALIAS CAN1_RX0_IRQHandler
  WEAK_ALIAS CAN1_RX1_IRQHandler
  WEAK_ALIAS CAN1_SCE_IRQHandler
  WEAK_ALIAS EXTI9_5_IRQHandler
  WEAK_ALIAS TIM1_BRK_TIM9_IRQHandler
  WEAK_ALIAS TIM1_UP_TIM10_IRQHandler
  WEAK_ALIAS TIM1_TRG_COM_TIM11_IRQHandler
  WEAK_ALIAS TIM1_CC_IRQHandler
  WEAK_ALIAS TIM2_IRQHandler
  WEAK_ALIAS TIM3_IRQHandler
  WEAK_ALIAS TIM4_IRQHandler
  WEAK_ALIAS I2C1_EV_IRQHandler
  WEAK_ALIAS I2C1_ER_IRQHandler
  WEAK_ALIAS I2C2_EV_IRQHandler
  WEAK_ALIAS I2C2_ER_IRQHandler
  WEAK_ALIAS SPI1_IRQHandler
  WEAK_ALIAS SPI2_IRQHandler
  WEAK_ALIAS USART1_IRQHandler
  WEAK_ALIAS USART2_IRQHandler
  WEAK_ALIAS USART3_IRQHandler
  WEAK_ALIAS EXTI15_10_IRQHandler
  WEAK_ALIAS RTC_Alarm_IRQHandler
  WEAK_ALIAS OTG_FS_WKUP_IRQHandler
  WEAK_ALIAS TIM8_BRK_TIM12_IRQHandler
  WEAK_ALIAS TIM8_UP_TIM13_IRQHandler
  WEAK_ALIAS TIM8_TRG_COM_TIM14_IRQHandler
  WEAK_ALIAS TIM8_CC_IRQHandler
  WEAK_ALIAS DMA1_Stream7_IRQHandler
  WEAK_ALIAS SDIO_IRQHandler
  WEAK_ALIAS TIM5_IRQHandler
  WEAK_ALIAS SPI3_IRQHandler
  WEAK_ALIAS DMA2_Stream0_IRQHandler
  WEAK_ALIAS DMA2_Stream1_IRQHandler
  WEAK_ALIAS DMA2_Stream2_IRQHandler
  WEAK_ALIAS DMA2_Stream3_IRQHandler
  WEAK_ALIAS DMA2_Stream4_IRQHandler
  WEAK_ALIAS CAN2_TX_IRQHandler
  WEAK_ALIAS CAN2_RX0_IRQHandler
  WEAK_ALIAS CAN2_RX1_IRQHandler
  WEAK_ALIAS CAN2_SCE_IRQHandler
  WEAK_ALIAS OTG_FS_IRQHandler
  WEAK_ALIAS DMA2_Stream5_IRQHandler
  WEAK_ALIAS DMA2_Stream6_IRQHandler
  WEAK_ALIAS DMA2_Stream7_IRQHandler
  WEAK_ALIAS USART6_IRQHandler
  WEAK_ALIAS I2C3_EV_IRQHandler
  WEAK_ALIAS I2C3_ER_IRQHandler
  WEAK_ALIAS RNG_IRQHandler
  WEAK_ALIAS FPU_IRQHandler
  WEAK_ALIAS SPI4_IRQHandler
  WEAK_ALIAS SPI5_IRQHandler
  WEAK_ALIAS FMPI2C1_EV_IRQHandler
  WEAK_ALIAS FMPI2C1_ER_IRQHandler
