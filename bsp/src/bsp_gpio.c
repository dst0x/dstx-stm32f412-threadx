#include "bsp_gpio.h"

void BSP_GPIO_Init(void)
{
    GPIO_InitTypeDef gpio = {0};

    LED_GPIO_CLK_EN();

    gpio.Pin   = LED_GPIO_PIN;
    gpio.Mode  = GPIO_MODE_OUTPUT_PP;
    gpio.Pull  = GPIO_NOPULL;
    gpio.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(LED_GPIO_PORT, &gpio);

    HAL_GPIO_WritePin(LED_GPIO_PORT, LED_GPIO_PIN, GPIO_PIN_RESET);
}

void BSP_LED_On(void)
{
    HAL_GPIO_WritePin(LED_GPIO_PORT, LED_GPIO_PIN, GPIO_PIN_SET);
}

void BSP_LED_Off(void)
{
    HAL_GPIO_WritePin(LED_GPIO_PORT, LED_GPIO_PIN, GPIO_PIN_RESET);
}

void BSP_LED_Toggle(void)
{
    HAL_GPIO_TogglePin(LED_GPIO_PORT, LED_GPIO_PIN);
}

uint8_t BSP_LED_GetState(void)
{
    return (uint8_t)HAL_GPIO_ReadPin(LED_GPIO_PORT, LED_GPIO_PIN);
}
