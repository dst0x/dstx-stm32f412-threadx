#include "stm32f4xx.h"

/* HSI at 16 MHz after reset — no PLL configured here.
 * Extend this function to set up your target clock tree. */

uint32_t SystemCoreClock = 16000000U;

const uint8_t AHBPrescTable[16] = {0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 6, 7, 8, 9};
const uint8_t APBPrescTable[8]  = {0, 0, 0, 0, 1, 2, 3, 4};

void SystemInit(void)
{
    /* FPU — enable CP10/CP11 full access */
#if (__FPU_PRESENT == 1) && (__FPU_USED == 1)
    SCB->CPACR |= ((3UL << 10*2) | (3UL << 11*2));
#endif

    /* Reset RCC to default state */
    RCC->CR |= RCC_CR_HSION;
    RCC->CFGR = 0x00000000U;
    RCC->CR &= ~(RCC_CR_HSEON | RCC_CR_CSSON | RCC_CR_PLLON);
    RCC->PLLCFGR = 0x24003010U;
    RCC->CR &= ~RCC_CR_HSEBYP;
    RCC->CIR = 0x00000000U;

    /* Relocate vector table to Flash base */
    SCB->VTOR = FLASH_BASE;
}

void SystemCoreClockUpdate(void)
{
    /* Minimal implementation — extend for PLL use */
    SystemCoreClock = 16000000U;
}
