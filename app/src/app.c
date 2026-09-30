#include "app.h"
#include "bsp.h"
#include "log.h"
#include <time.h>

static void App_LogTransmit(const char *buf, uint16_t len)
{
    BSP_UART2_Transmit(buf, len);
}

static time_t App_GetTime(void)
{
    return (time_t)(HAL_GetTick() / 1000U);
}

void App_Init(void)
{
    BSP_Init();
    Log_Init(App_LogTransmit, App_GetTime);
    BSP_LED_On();
    LOG_INFO("System init complete");
}

void App_Run(void)
{
    while (1)
    {
        /* main superloop placeholder */
    }
}
