set(SOURCES board.c)

set(INCLUDES ../common/include)

# TODO: these files shouldn't be necessarily tied to the board
set(STM32CUBE_SOURCES
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/gcc/startup_stm32l412xx.s
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/system_stm32l4xx.c
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_gpio.c
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_pwr.c
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_rcc.c
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_utils.c
)

set(STM32CUBE_INCLUDES
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Core/Include
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Include
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Inc)

add_library(board_stm32l412 OBJECT ${SOURCES} ${STM32CUBE_SOURCES})
target_include_directories(board_stm32l412 PUBLIC ${INCLUDES}
                                                  ${STM32CUBE_INCLUDES})
target_compile_definitions(board_stm32l412 PUBLIC -DUSE_FULL_LL_DRIVER
                                                  -DSTM32L412xx)
