#include <stm32l4xx_hal.h>

#define LED_PIN GPIO_PIN_13
#define LED_PORT GPIOB

void SysTick_Handler(void) {
    HAL_IncTick();
}

int main(int argc, char const* argv[]) {
    (void)argc;
    (void)argv;

    // init systick
    HAL_Init();

    // init led
    __HAL_RCC_GPIOB_CLK_ENABLE();
    GPIO_InitTypeDef led = {
        .Pin = LED_PIN,
        .Mode = GPIO_MODE_OUTPUT_PP,
    };
    HAL_GPIO_Init(LED_PORT, &led);

    while (1) {
        HAL_Delay(500);
        HAL_GPIO_TogglePin(LED_PORT, LED_PIN);
    }

    return 0;
}
