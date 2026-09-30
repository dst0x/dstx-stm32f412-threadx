#include "stm32f4xx_hal.h"
#include "app.h"

int main(void)
{
    HAL_Init();
    App_Init();
    App_Run();

    /* Never reached */
    return 0;
}
