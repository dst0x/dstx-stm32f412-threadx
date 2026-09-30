#include "app.h"
#include "bsp.h"
#include "log.h"
#include "tx_api.h"
#include <time.h>

/* ── Thread configuration ─────────────────────────────────────────── */
#define LED_STACK_SIZE      512U
/* Log_Put (148 B) + localtime_r + strftime + snprintf + HAL_UART_Transmit
   easily exceed 512 B; 2048 B gives comfortable headroom. */
#define UART_STACK_SIZE     2048U
#define LED_BLINK_PERIOD_MS 500U   /* tx ticks == ms with 1000 Hz clock */

/* ── Thread control blocks and stacks ────────────────────────────── */
static TX_THREAD  led_thread;
static TX_THREAD  uart_thread;
static ULONG      led_stack[LED_STACK_SIZE  / sizeof(ULONG)];
static ULONG      uart_stack[UART_STACK_SIZE / sizeof(ULONG)];

/* ── Log callbacks ───────────────────────────────────────────────── */
static void App_LogTransmit(const char *buf, uint16_t len)
{
    BSP_USART2_Transmit(buf, len);
}

static time_t App_GetTime(void)
{
    return (time_t)(HAL_GetTick() / 1000U);
}

/* ── Thread entry functions ──────────────────────────────────────── */
static void Thread_LED(ULONG arg)
{
    (void)arg;
    while (1)
    {
        BSP_LED_Toggle();
        tx_thread_sleep(LED_BLINK_PERIOD_MS);
    }
}

static void Thread_UART(ULONG arg)
{
    (void)arg;
    while (1)
    {
        tx_thread_sleep(LED_BLINK_PERIOD_MS);

        if (BSP_LED_GetState())
            LOG_INFO("LED ON");
        else
            LOG_INFO("LED OFF");
    }
}

/* ── Public API ──────────────────────────────────────────────────── */

void App_Init(void)
{
    BSP_Init();
    Log_Init(App_LogTransmit, App_GetTime);
    LOG_INFO("System init complete");
}

/*
 * tx_application_define — called once by ThreadX after low-level init.
 * Creates both threads; first_unused_memory is provided by ThreadX but
 * we use static stacks so it is not needed here.
 */
void tx_application_define(void *first_unused_memory)
{
    (void)first_unused_memory;

    tx_thread_create(&led_thread,  "LED",
                     Thread_LED,  0,
                     led_stack,  sizeof(led_stack),
                     5, 5, TX_NO_TIME_SLICE, TX_AUTO_START);

    tx_thread_create(&uart_thread, "UART",
                     Thread_UART,  0,
                     uart_stack,  sizeof(uart_stack),
                     5, 5, TX_NO_TIME_SLICE, TX_AUTO_START);
}

void App_Run(void)
{
    tx_kernel_enter();
    /* Never reached */
}
