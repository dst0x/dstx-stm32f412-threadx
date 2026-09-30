#include "bsp_usart.h"

UART_HandleTypeDef huart2;

void BSP_USART2_Init(void)
{
    GPIO_InitTypeDef gpio = {0};

    UART2_GPIO_CLK_EN();
    UART2_CLK_EN();

    gpio.Pin       = UART2_TX_PIN | UART2_RX_PIN;
    gpio.Mode      = GPIO_MODE_AF_PP;
    gpio.Pull      = GPIO_NOPULL;
    gpio.Speed     = GPIO_SPEED_FREQ_VERY_HIGH;
    gpio.Alternate = UART2_GPIO_AF;
    HAL_GPIO_Init(UART2_GPIO_PORT, &gpio);

    huart2.Instance          = USART2;
    huart2.Init.BaudRate     = UART2_BAUDRATE;
    huart2.Init.WordLength   = UART_WORDLENGTH_8B;
    huart2.Init.StopBits     = UART_STOPBITS_1;
    huart2.Init.Parity       = UART_PARITY_NONE;
    huart2.Init.Mode         = UART_MODE_TX_RX;
    huart2.Init.HwFlowCtl    = UART_HWCONTROL_NONE;
    huart2.Init.OverSampling = UART_OVERSAMPLING_16;
    HAL_UART_Init(&huart2);
}

void BSP_USART2_Transmit(const char *buf, uint16_t len)
{
    HAL_UART_Transmit(&huart2, (const uint8_t *)buf, len, HAL_MAX_DELAY);
}
