cmake_minimum_required(VERSION 3.21)

project(blinky C ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# add the path containng `FindSTM32Cube.cmake` to `CMAKE_MODULE_PATH`
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../../cmake)
find_package(STM32Cube)

# add the `CMakeLists.txt` containing the `board::stm32l412` and
# `board::stm32l476` libraries
add_subdirectory(src/board)

# create an executable using the `board::stm32l412` library
add_executable(blinky_stm32l412 src/app/main.c)
target_link_libraries(
  blinky_stm32l412 PRIVATE -T${CMAKE_SOURCE_DIR}/src/stm32l412.ld
                           board::stm32l412)

# create an executable using the `board::stm32l476` library
add_executable(blinky_stm32l476 src/app/main.c)
target_link_libraries(
  blinky_stm32l476 PRIVATE -T${CMAKE_SOURCE_DIR}/src/stm32l476.ld
                           board::stm32l476)
