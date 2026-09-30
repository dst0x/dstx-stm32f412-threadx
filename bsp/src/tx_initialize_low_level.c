#include "stm32f4xx_hal.h"
#include "tx_api.h"

/* Linker symbols */
extern uint32_t _end;
extern uint32_t _estack;

/* ThreadX internals */
extern VOID  *_tx_initialize_unused_memory;
extern ULONG  _tx_thread_system_stack_ptr;
extern VOID   _tx_timer_interrupt(VOID);

/*
 * _tx_initialize_low_level — called by tx_kernel_enter() before
 * tx_application_define().  Responsibilities:
 *   1. Record first free RAM for ThreadX byte pools
 *   2. Save the system stack pointer
 *   3. Configure SysTick at TX_TIMER_TICKS_PER_SECOND (1000 Hz)
 *   4. Set PendSV to lowest priority so the scheduler can always run
 */
VOID _tx_initialize_low_level(VOID)
{
    /* First available RAM after BSS + stack guard */
    _tx_initialize_unused_memory = (VOID *)(&_end + 1);

    /* System stack pointer (initial MSP from vector table) */
    _tx_thread_system_stack_ptr = (ULONG)&_estack;

    /* PendSV must be the lowest priority (0xFF) so the scheduler
       is never starved by other ISRs. */
    NVIC_SetPriority(PendSV_IRQn, 0xFF);

    /* SysTick one step above PendSV */
    NVIC_SetPriority(SysTick_IRQn, 0xFE);

    /* Reconfigure SysTick for TX_TIMER_TICKS_PER_SECOND */
    SysTick_Config(SystemCoreClock / TX_TIMER_TICKS_PER_SECOND);
}

/*
 * SysTick_Handler — strong definition that overrides the weak alias in
 * the startup file.  Advances both the HAL 1 ms tick and the ThreadX
 * time base.
 */
void SysTick_Handler(void)
{
    HAL_IncTick();
    _tx_timer_interrupt();
}
