# TODO: these definitions are mcu dependent. it's not ideal to make this library a dependency of
# every other library to get the compilation and linker options
set(CPU -mcpu=cortex-m4)
set(FPU -mfpu=fpv4-sp-d16)
set(FLOAT_ABI -mfloat-abi=hard)

set(MCU
        ${CPU}
        -mthumb
        ${FPU}
        ${FLOAT_ABI}
)

add_library(stm32l4 INTERFACE)

target_compile_options(stm32l4 INTERFACE 
  ${MCU}
)

target_link_libraries(stm32l4 INTERFACE
        ${MCU} 
        -specs=nano.specs
        -lc
        -lm
        -lnosys
        -Wl,-Map=${PROJECT_NAME}.map,--cref
        -Wl,--gc-sections
        -Wl,--print-memory-usage
)
