set(TOOLCHAIN_PREFIX arm-none-eabi-)

set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)

set(WARNINGS
    "-Wall -Wextra -Wpedantic -Wfatal-errors -Wno-unused-parameter -Werror")
set(C_FLAGS "-fdata-sections -ffunction-sections -MMD -MP")
set(LINK_FLAGS "--specs=nano.specs -Wl,--gc-sections -Wl,--print-memory-usage")

# ignore warnings about rwx segments introduced in binutils 2.39
execute_process(
  COMMAND ${CMAKE_C_COMPILER} -print-prog-name=ld
  RESULT_VARIABLE RUN_C_RESULT
  OUTPUT_VARIABLE FULL_LD_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE)
if(${RUN_C_RESULT} EQUAL 0)
  execute_process(
    COMMAND ${FULL_LD_PATH} --help
    RESULT_VARIABLE RUN_LD_RESULT
    OUTPUT_VARIABLE LD_HELP_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(${RUN_LD_RESULT} EQUAL 0)
    set(RWX_WARNING "no-warn-rwx-segments")
    string(FIND "${LD_HELP_OUTPUT}" "${RWX_WARNING}" LD_RWX_WARNING_SUPPORTED)
    if(${LD_RWX_WARNING_SUPPORTED} GREATER -1)
      set(LINK_FLAGS "${LINK_FLAGS} -Wl,--${RWX_WARNING}")
    endif()
  endif()
endif()

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
    "-Og -g3 -gdwarf-5"
    CACHE INTERNAL "c compiler debug flags")

set(CMAKE_C_FLAGS_RELEASE
    "-Og"
    CACHE INTERNAL "c compiler release flags")

set(CMAKE_C_FLAGS_MINSIZEREL
    "-Os"
    CACHE INTERNAL "c compiler min-size release flags")

set(CMAKE_C_FLAGS_RELWITHDEBINFO
    "-Og -g3 -gdwarf-5"
    CACHE INTERNAL "c compiler release with debug info")

set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)
set(CMAKE_EXECUTABLE_SUFFIX_C .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
