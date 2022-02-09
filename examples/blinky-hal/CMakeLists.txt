cmake_minimum_required(VERSION 3.21)

project(blinky C ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# allow `stm32l4xx_hal_conf.h` to be included when generating cube libraries
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

# add the path containng `FindSTM32Cube.cmake` to `CMAKE_MODULE_PATH`
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../../cmake)
find_package(STM32Cube REQUIRED)
generate_stm32cube(stm32l412 HAL_DRIVERS cortex gpio)

add_executable(blinky main.c)
target_link_libraries(
  blinky PRIVATE -T${CMAKE_SOURCE_DIR}/stm32l412.ld stm32::stm32l412_cmsis
                 stm32::stm32l412_hal_cortex stm32::stm32l412_hal_gpio)
