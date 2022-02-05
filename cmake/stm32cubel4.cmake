# TODO: support other families of STM32

include(${CMAKE_CURRENT_LIST_DIR}/stm32cube_drivers.cmake)

function(generate_stm32cubel4 mcu)
  set(options)
  set(args)
  set(list_args HAL_LIBS LL_LIBS)
  cmake_parse_arguments(PARSE_ARGV 1 
    ARG
    "${options}"
    "${args}"
    "${list_args}"
  )

  foreach(arg IN LISTS ARG_UNPARSED_ARGUMENTS)
    message(WARNING "Invalid argument: ${arg}")
  endforeach()

  # validate MCU
  string(TOUPPER ${mcu} mcu_upper)
  string(TOLOWER ${mcu} mcu_lower)
  string(REGEX MATCH "^STM32([FGHLUW][0-9])([0-9][0-9])$" mcu_match ${mcu_upper})
  if(NOT mcu_match)
    message(FATAL_ERROR "Unknown MCU: ${mcu}")
  endif()

  # validate HAL libraries
  foreach(lib IN LISTS ARG_HAL_LIBS)
    if(lib IN_LIST HAL_DRIVERS_L4)
      message(VERBOSE "Adding HAL library: ${lib}")
      list(APPEND hal_drivers ${lib})
    else()
      message(WARNING "Invalid HAL library: ${lib}")
    endif()
  endforeach()

  # validate LL libraries
  foreach(lib IN LISTS ARG_LL_LIBS)
    if(lib IN_LIST LL_DRIVERS_L4)
      message(VERBOSE "Adding LL library: ${lib}")
      list(APPEND ll_drivers ${lib})
    else()
      message(WARNING "Invalid LL library: ${lib}")
    endif()
  endforeach()

  # get path to cube library
  if(STM32CUBEL4_PATH)
    set(STM32CUBE_PATH "${STM32CUBEL4_PATH}")
  else()
    message(STATUS "STM32CUBEL4_PATH not set, defaulting to /opt")
    set(STM32CUBE_PATH "/opt")
  endif()

  # build CMSIS
  set(library_name ${mcu_lower}_cmsis)
  add_library(${library_name} STATIC
    ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/gcc/startup_${mcu_lower}xx.s
    ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/system_stm32l4xx.c
  )
  target_compile_definitions(${library_name} PUBLIC -D${mcu_upper}xx)
  target_include_directories(${library_name} PUBLIC
    ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
    ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32L4xx/Include
  )

  # build HAL libraries
  foreach(driver IN LISTS hal_drivers)
    set(libray_name ${mcu_lower}_hal_${driver})
    add_library(${libray_name} STATIC
      ${STM32CUBE_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_${driver}.c)
    target_compile_definitions(${libray_name} PUBLIC -D${mcu_upper}xx -DUSE_HAL_DRIVER)
    target_include_directories(${libray_name} PUBLIC
      ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
      ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32L4xx/Include
      ${STM32CUBE_PATH}/Drivers/STM32L4xx_HAL_Driver/Inc
    )
  endforeach()

  # build LL libraries
  foreach(driver IN LISTS ll_drivers)
    set(libray_name ${mcu_lower}_ll_${driver})
    add_library(${libray_name} STATIC
      ${STM32CUBE_PATH}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_${driver}.c)
    target_compile_definitions(${libray_name} PUBLIC -D${mcu_upper}xx -DUSE_FULL_LL_DRIVER)
    target_include_directories(${libray_name} PUBLIC
      ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
      ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32L4xx/Include
      ${STM32CUBE_PATH}/Drivers/STM32L4xx_HAL_Driver/Inc
    )
  endforeach()
endfunction()
