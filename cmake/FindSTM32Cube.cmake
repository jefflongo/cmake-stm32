cmake_minimum_required(VERSION 3.18)

include(${CMAKE_CURRENT_LIST_DIR}/stm32cube_drivers.cmake)

function(generate_stm32cube mcu)
  set(options)
  set(args)
  set(list_args HAL_DRIVERS LL_DRIVERS)
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

  # validate HAL drivers
  list(REMOVE_DUPLICATES ARG_HAL_DRIVERS)
  foreach(driver IN LISTS ARG_HAL_DRIVERS)
    if(driver IN_LIST HAL_DRIVERS_${type_core_upper})
      message(VERBOSE "Adding HAL driver: ${driver}")
      list(APPEND hal_drivers ${driver})
    else()
      message(WARNING "Invalid HAL driver: ${driver}")
      list(REMOVE_ITEM hal_drivers ${driver})
    endif()
  endforeach()

  # validate LL drivers
  list(REMOVE_DUPLICATES ARG_LL_DRIVERS)
  foreach(driver IN LISTS ARG_LL_DRIVERS)
    if(driver IN_LIST LL_DRIVERS_${type_core_upper})
      message(VERBOSE "Adding LL driver: ${driver}")
      list(APPEND ll_drivers ${driver})
    else()
      message(WARNING "Invalid LL driver: ${driver}")
      list(REMOVE_ITEM ll_drivers ${driver})
    endif()
  endforeach()

  # get path to cube library
  if(STM32CUBE${type_core_upper}_PATH)
    get_filename_component(STM32CUBE_PATH ${STM32CUBE${type_core_upper}_PATH}
                           REALPATH)
  else()
    message(
      WARNING
        "STM32CUBE${type_core_upper}_PATH not set, defaulting to /opt/STM32Cube${type_core_upper}"
    )
    set(STM32CUBE_PATH "/opt/STM32Cube${type_core_upper}")
  endif()

  # check if the cube path actually exists
  if(NOT
     ((EXISTS ${STM32CUBE_PATH})
      AND (IS_DIRECTORY ${STM32CUBE_PATH})
      AND (${STM32CUBE_PATH} MATCHES "STM32Cube[FGHLUW][0-9]$")))
    message(
      FATAL_ERROR
        "Invalid path to STM32Cube${type_core_upper}: ${STM32CUBE_PATH}")
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
  add_library(stm32::${library_name} ALIAS ${library_name})

  # build HAL libraries
  foreach(driver IN LISTS hal_drivers)
    set(library_name ${mcu_lower}_hal_${driver})
    add_library(
      ${library_name} STATIC
      ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Src/stm32${type_core_lower}xx_hal_${driver}.c
    )
    target_compile_definitions(${library_name} PUBLIC -D${mcu_upper}xx
                                                      -DUSE_HAL_DRIVER)
    target_include_directories(
      ${library_name}
      PUBLIC
        ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
        ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Include
        ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Inc)
    # add_library(stm32::${library_name} ALIAS ${library_name})
  endforeach()

  # build LL libraries
  foreach(driver IN LISTS ll_drivers)
    set(library_name ${mcu_lower}_ll_${driver})
    add_library(
      ${library_name} STATIC
      ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Src/stm32${type_core_lower}xx_ll_${driver}.c
    )
    set(defs -D${mcu_upper}xx)
    if(NOT (${driver} IN_LIST hal_drivers))
      # some HAL drivers are dependent on a portion of an LL driver. only use
      # the full LL driver if associated HAL driver is not used
      list(APPEND defs -DUSE_FULL_LL_DRIVER)
    endif()
    target_compile_definitions(${library_name} PUBLIC ${defs})
    target_include_directories(
      ${library_name}
      PUBLIC
        ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
        ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Include
        ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Inc)
    add_library(stm32::${library_name} ALIAS ${library_name})
  endforeach()
endfunction()

set(STM32Cube_VERSION 0.1.0)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  STM32Cube
  VERSION_VAR STM32Cube_VERSION
  HANDLE_COMPONENTS)
