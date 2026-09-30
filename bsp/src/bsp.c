#include "bsp.h"

void BSP_Init(void)
{
    BSP_GPIO_Init();
    BSP_USART2_Init();
}
