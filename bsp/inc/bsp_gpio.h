#ifndef BSP_GPIO_H
#define BSP_GPIO_H

#include "stm32f4xx_hal.h"

/* LED on PB2 */
#define LED_GPIO_PORT     GPIOB
#define LED_GPIO_PIN      GPIO_PIN_2
#define LED_GPIO_CLK_EN() __HAL_RCC_GPIOB_CLK_ENABLE()

void BSP_GPIO_Init(void);
void BSP_LED_On(void);
void BSP_LED_Off(void);
void BSP_LED_Toggle(void);
uint8_t BSP_LED_GetState(void);

#endif /* BSP_GPIO_H */
