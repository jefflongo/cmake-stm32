generate_stm32cube(stm32l412 LL_DRIVERS gpio utils pwr rcc)

add_library(board_stm32l412 OBJECT board.c)
target_include_directories(board_stm32l412 PUBLIC ../common/include)
target_link_libraries(
  board_stm32l412
  PUBLIC stm32::stm32l412_cmsis stm32::stm32l412_ll_gpio
         stm32::stm32l412_ll_utils stm32::stm32l412_ll_pwr
         stm32::stm32l412_ll_rcc)
# create interface library to allow transitive OBJECT library dependencies
add_library(_board_stm32l412 INTERFACE)
target_link_libraries(
  _board_stm32l412 INTERFACE board_stm32l412 $<TARGET_OBJECTS:board_stm32l412>)
# create alias for namespacing
add_library(board::stm32l412 ALIAS _board_stm32l412)
