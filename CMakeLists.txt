cmake_minimum_required(VERSION 3.8)

# I promise these are temporary..
set(CMAKE_TOOLCHAIN_FILE ../cmake/cortex-m4.cmake)
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE ON)

project(blinky)

enable_language(C ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

include(cmake/stm32cubel4.cmake)
set(ll_libs gpio utils pwr rcc)
generate_stm32cubel4(stm32l412 LL_LIBS ${ll_libs})

add_subdirectory(src/board/stm32l412)

set(SOURCES src/app/main.c)

add_executable(exe_stm32l412 ${SOURCES})
target_link_libraries(
  exe_stm32l412 PRIVATE 
  -T${CMAKE_SOURCE_DIR}/src/stm32l412.ld 
  board_stm32l412
)
