#ifndef BSP_USART_H
#define BSP_USART_H

#include "stm32f4xx_hal.h"
#include <stdint.h>

/* USART2: PA2 (TX), PA3 (RX), AF7 */
#define UART2_TX_PIN        GPIO_PIN_2
#define UART2_RX_PIN        GPIO_PIN_3
#define UART2_GPIO_PORT     GPIOA
#define UART2_GPIO_AF       GPIO_AF7_USART2
#define UART2_CLK_EN()      __HAL_RCC_USART2_CLK_ENABLE()
#define UART2_GPIO_CLK_EN() __HAL_RCC_GPIOA_CLK_ENABLE()
#define UART2_BAUDRATE      115200U

extern UART_HandleTypeDef huart2;

void BSP_USART2_Init(void);
void BSP_USART2_Transmit(const char *buf, uint16_t len);

#endif /* BSP_USART_H */
