#include <stm32l4xx_ll_bus.h>
#include <stm32l4xx_ll_cortex.h>
#include <stm32l4xx_ll_gpio.h>
#include <stm32l4xx_ll_rcc.h>
#include <stm32l4xx_ll_utils.h>

#define LED_PIN LL_GPIO_PIN_13
#define LED_PORT GPIOB

int main(int argc, char const* argv[]) {
    (void)argc;
    (void)argv;

    // init systick
    LL_Init1msTick(4000000);
    LL_SYSTICK_SetClkSource(LL_SYSTICK_CLKSOURCE_HCLK);

    // init led
    LL_AHB2_GRP1_EnableClock(LL_AHB2_GRP1_PERIPH_GPIOB);
    LL_GPIO_SetPinMode(LED_PORT, LED_PIN, LL_GPIO_MODE_OUTPUT);
    LL_GPIO_SetPinOutputType(LED_PORT, LED_PIN, LL_GPIO_OUTPUT_PUSHPULL);

    while (1) {
        LL_mDelay(500);
        LL_GPIO_TogglePin(LED_PORT, LED_PIN);
    }

    return 0;
}
