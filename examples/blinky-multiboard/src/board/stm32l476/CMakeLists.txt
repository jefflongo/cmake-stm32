generate_stm32cube(stm32l476 LL_DRIVERS gpio utils pwr rcc)

add_library(board_stm32l476 OBJECT board.c)
target_include_directories(board_stm32l476 PUBLIC ../common/include)
target_link_libraries(board_stm32l476 PUBLIC
    stm32::stm32l476_cmsis
    stm32::stm32l476_ll_gpio
    stm32::stm32l476_ll_utils 
    stm32::stm32l476_ll_pwr
    stm32::stm32l476_ll_rcc
)
add_library(board::stm32l476 ALIAS board_stm32l476)
