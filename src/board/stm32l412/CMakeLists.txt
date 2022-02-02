set(SOURCES board.c)

set(INCLUDES ../common/include)

add_library(board_stm32l412 STATIC ${SOURCES})
target_include_directories(board_stm32l412 PUBLIC ${INCLUDES})
target_link_libraries(board_stm32l412 PUBLIC
    stm32l412 
    stm32l4_ll_gpio
    stm32l4_ll_utils 
    stm32l4_ll_pwr
    stm32l4_ll_rcc
)
