#include <board.h>

int main(int argc, char const* argv[]) {
    (void)argc;
    (void)argv;

    board_init();

    while (1) {
        board_delay(500);
        board_led_toggle();
    }

    return 0;
}
