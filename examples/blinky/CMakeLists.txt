cmake_minimum_required(VERSION 3.18)

project(blinky)

enable_language(C ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# add the path containng `FindSTM32Cube.cmake` to `CMAKE_MODULE_PATH`
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../../cmake)
find_package(STM32Cube)
generate_stm32cube(stm32l412 LL_DRIVERS gpio utils pwr rcc)

add_executable(blinky main.c)
target_link_libraries(
  blinky
  PRIVATE -T${CMAKE_SOURCE_DIR}/stm32l412.ld stm32::stm32l412_cmsis
          stm32::stm32l412_ll_gpio stm32::stm32l412_ll_utils
          stm32::stm32l412_ll_pwr stm32::stm32l412_ll_rcc)
