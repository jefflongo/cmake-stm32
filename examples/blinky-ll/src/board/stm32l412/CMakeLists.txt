set(SOURCES board.c)

set(INCLUDES ../common/include)

add_library(board_stm32l412 OBJECT ${SOURCES})
target_include_directories(board_stm32l412 PUBLIC ${INCLUDES})
target_link_libraries(board_stm32l412 PUBLIC
    stm32::stm32l412_cmsis
    stm32::stm32l412_ll_gpio
    stm32::stm32l412_ll_utils 
    stm32::stm32l412_ll_pwr
    stm32::stm32l412_ll_rcc
)
