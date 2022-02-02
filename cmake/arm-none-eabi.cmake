set(TOOLCHAIN_PREFIX arm-none-eabi-)

set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)

set(WARNINGS "-Wall -Wextra -Wpedantic -Wfatal-errors -Wno-unused-parameter")
set(C_FLAGS "-fdata-sections -ffunction-sections -MMD -MP")
set(LINK_FLAGS
    "--specs=nano.specs -lc -lm -lnosys -Wl,-Map=out.map,--cref -Wl,--gc-sections -Wl,--print-memory-usage"
)

set(CMAKE_ASM_FLAGS_INIT
    "-x assembler-with-cpp"
    CACHE INTERNAL "asm compiler flags")

set(CMAKE_C_FLAGS_INIT
    "${CPU_FLAGS} ${C_FLAGS} ${WARNINGS}"
    CACHE INTERNAL "c compiler flags")

set(CMAKE_EXE_LINKER_FLAGS_INIT
    "${CPU_FLAGS} ${LINK_FLAGS}"
    CACHE INTERNAL "executable linker flags")
    
set(CMAKE_C_FLAGS_DEBUG
    "-Og -g -gdwarf-2"
    CACHE INTERNAL "c compiler debug flags")

set(CMAKE_C_FLAGS_RELEASE
    "-Og"
    CACHE INTERNAL "c compiler release flags")

set(CMAKE_C_FLAGS_MINSIZEREL
    "-Os"
    CACHE INTERNAL "c compiler min-size release flags")

set(CMAKE_C_FLAGS_RELWITHDEBINFO
    "-Og -g -gdwarf-2"
    CACHE INTERNAL "c compiler release with debug info")

set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)
set(CMAKE_EXECUTABLE_SUFFIX_C .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
