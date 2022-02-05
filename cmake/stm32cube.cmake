include(${CMAKE_CURRENT_LIST_DIR}/stm32cube_drivers.cmake)

function(generate_stm32cube mcu)
  set(options)
  set(args)
  set(list_args HAL_LIBS LL_LIBS)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "${options}" "${args}" "${list_args}")

  foreach(arg IN LISTS ARG_UNPARSED_ARGUMENTS)
    message(WARNING "Invalid argument: ${arg}")
  endforeach()

  # validate MCU
  string(TOUPPER ${mcu} mcu_upper)
  string(TOLOWER ${mcu} mcu_lower)
  string(REGEX MATCH "^STM32([FGHLUW][0-9])([A-Z0-9][0-9])$" mcu_match
               ${mcu_upper})
  if(NOT mcu_match)
    message(FATAL_ERROR "Unknown MCU: ${mcu}")
  endif()

  # given 'STM32F4', extract the 'F4'
  set(type_core_upper ${CMAKE_MATCH_1})
  string(TOLOWER ${type_core_upper} type_core_lower)

  # validate HAL libraries
  list(REMOVE_DUPLICATES ARG_HAL_LIBS)
  foreach(lib IN LISTS ARG_HAL_LIBS)
    if(lib IN_LIST HAL_DRIVERS_${type_core_upper})
      message(VERBOSE "Adding HAL library: ${lib}")
      list(APPEND hal_drivers ${lib})
    else()
      message(WARNING "Invalid HAL library: ${lib}")
      list(REMOVE_ITEM hal_drivers ${lib})
    endif()
  endforeach()

  # validate LL libraries
  list(REMOVE_DUPLICATES ARG_LL_LIBS)
  foreach(lib IN LISTS ARG_LL_LIBS)
    if(lib IN_LIST LL_DRIVERS_${type_core_upper})
      message(VERBOSE "Adding LL library: ${lib}")
      list(APPEND ll_drivers ${lib})
    else()
      message(WARNING "Invalid LL library: ${lib}")
      list(REMOVE_ITEM ll_drivers ${lib})
    endif()
  endforeach()

  # get path to cube library
  if(STM32CUBE${type_core_upper}_PATH)
    set(STM32CUBE_PATH "${STM32CUBE${type_core_upper}_PATH}")
  else()
    message(
      STATUS
        "STM32CUBE${type_core_upper}_PATH not set, defaulting to /opt/STM32Cube${type_core_upper}"
    )
    set(STM32CUBE_PATH "/opt/STM32Cube${type_core_upper}")
  endif()
  message(VERBOSE "Path to STM32Cube${type_core_upper}: ${STM32CUBE_PATH}")

  # build CMSIS
  set(library_name ${mcu_lower}_cmsis)
  add_library(
    ${library_name} STATIC
    ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Source/Templates/gcc/startup_${mcu_lower}xx.s
    ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Source/Templates/system_stm32${type_core_lower}xx.c
  )
  target_compile_definitions(${library_name} PUBLIC -D${mcu_upper}xx)
  target_include_directories(
    ${library_name}
    PUBLIC
      ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
      ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Include
  )

  # build HAL libraries
  foreach(driver IN LISTS hal_drivers)
    set(libray_name ${mcu_lower}_hal_${driver})
    add_library(
      ${libray_name} STATIC
      ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Src/stm32${type_core_lower}xx_hal_${driver}.c
    )
    target_compile_definitions(${libray_name} PUBLIC -D${mcu_upper}xx
                                                     -DUSE_HAL_DRIVER)
    target_include_directories(
      ${libray_name}
      PUBLIC
        ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
        ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Include
        ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Inc)
  endforeach()

  # build LL libraries
  foreach(driver IN LISTS ll_drivers)
    set(libray_name ${mcu_lower}_ll_${driver})
    add_library(
      ${libray_name} STATIC
      ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Src/stm32${type_core_lower}xx_ll_${driver}.c
    )
    set(defs -D${mcu_upper}xx)
    if(NOT (${driver} IN_LIST hal_drivers))
      # some HAL drivers are dependent on a portion of an LL driver. only use
      # the full LL driver if associated HAL driver is not used
      list(APPEND defs -DUSE_FULL_LL_DRIVER)
    endif()
    target_compile_definitions(${libray_name} PUBLIC ${defs})
    target_include_directories(
      ${libray_name}
      PUBLIC
        ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
        ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Include
        ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Inc)
  endforeach()
endfunction()
