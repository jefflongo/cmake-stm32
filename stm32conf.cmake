set(CPU -mcpu=cortex-m4)
set(FPU -mfpu=fpv4-sp-d16)
set(FLOAT_ABI -mfloat-abi=hard)

set(MCU
        ${CPU}
        -mthumb
        ${FPU}
        ${FLOAT_ABI}
)

# TODO: probably move this to toolchain file?
set(WARNINGS       
        -Wall
        -Wextra
        -Wpedantic
        -Wfatal-errors
        -Wno-unused-parameter
)

add_library(stm32 INTERFACE)
target_compile_definitions(stm32 INTERFACE
  -DSTM32L412xx
)

target_compile_options(stm32 INTERFACE 
  ${MCU}
  ${WARNINGS} 

  -fdata-sections
  -ffunction-sections
  -MMD
  -MP

  $<$<CONFIG:Debug>:-Og>
)

target_link_libraries(stm32 INTERFACE
        ${MCU} 
        -specs=nano.specs
        -lc
        -lm
        -lnosys
        -Wl,-Map=${PROJECT_NAME}.map,--cref
        -Wl,--gc-sections
        -Wl,--print-memory-usage
)
