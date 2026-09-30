/**
 * @file main.c
 * @brief STM32F412RET6 LED toggle on PB2
 *
 * This file contains the application entry point for turning on the LED
 * connected to pin PB2 on the STM32F412RET6 microcontroller.
 */

#include "stm32f412xx.h"

int main(void)
{
    /* Enable GPIOB clock (bit 1 in AHB1ENR) */
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;

    /* Set PB2 mode to output (01 in MODER) */
    GPIOB->MODER &= ~GPIO_MODER_MODER2;
    GPIOB->MODER |= (0x01 << GPIO_MODER_MODER2_Pos);

    /* Set PB2 output type to push-pull (default) */
    GPIOB->OTYPER &= ~GPIO_OTYPER_OT2;

    /* No pull-up/pull-down (default) */
    GPIOB->PUPDR &= ~GPIO_PUPDR_PUPD2;

    /* Set PB2 high to turn on LED */
    GPIOB->BSRR = GPIO_BSRR_BS2;

    while (1)
    {
        /* Infinite loop - LED stays on */
    }
}