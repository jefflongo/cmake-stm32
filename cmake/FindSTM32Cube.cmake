cmake_minimum_required(VERSION 3.21)

include(${CMAKE_CURRENT_LIST_DIR}/stm32cube_drivers.cmake)

# Adds an object library named `output name` from the given `object_library`
# which can be use transitively.
#
# object libraries are preferable to static libraries when the library overrides
# a weak symbol with a strong one. this is because, by default, the linker will
# omit the strong symbol if a weak one is already present. the only way to get
# around this is to provide --whole-archive (or OS equivalent), or to use an
# object library. object libraries cannot be used transitively. that is, an
# object library cannot link another object library because object libraries
# have no link stage. this function provides a way to create a transitive object
# library. see here for more info:
# https://cmake.org/cmake/help/latest/command/target_link_libraries.html#linking-object-libraries-via-target-objects
function(add_transitive_object_library output_name object_library)
  # make sure the given library is an OBJECT library
  get_target_property(library_type ${object_library} TYPE)
  if(NOT ${library_type} STREQUAL "OBJECT_LIBRARY")
    message(FATAL_ERROR "${object_library} is not an OBJECT library")
  endif()

  if("${output_name}" STREQUAL "_${object_library}")
    message(FATAL_ERROR "Output name cannot be input name prefixed with '_'")
  endif()

  # create interface library to allow transitive library dependencies
  set(interface_object_library "_${object_library}")
  add_library(${interface_object_library} INTERFACE)

  # inherit the usage requirements and objects
  target_link_libraries(
    ${interface_object_library} INTERFACE ${object_library}
                                          $<TARGET_OBJECTS:${object_library}>)

  # create an alias for namespacing
  add_library(${output_name} ALIAS ${interface_object_library})
endfunction()

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
  string(
    REGEX
      MATCH
      "^STM32(C0|F0|F1|F2|F3|F4|F7|G0|G4|H7|L0|L1|L4|L5|U5|WB|WL|WBA)([A-Z0-9][0-9])$"
      mcu_match
      ${mcu_upper})
  if(NOT mcu_match)
    message(FATAL_ERROR "Unknown MCU: ${mcu}")
  endif()

  # given 'STM32F4', extract the 'F4'
  set(type_core_upper ${CMAKE_MATCH_1})
  string(TOLOWER ${type_core_upper} type_core_lower)

  # validate HAL drivers
  if(HAL_DRIVERS IN_LIST ARG_KEYWORDS_MISSING_VALUES)
    message(VERBOSE "Adding all HAL drivers")
    set(hal_drivers ${HAL_DRIVERS_${type_core_upper}})
  else()
    list(REMOVE_DUPLICATES ARG_HAL_DRIVERS)
    foreach(driver IN LISTS ARG_HAL_DRIVERS)
      string(TOLOWER ${driver} driver)
      if(driver IN_LIST HAL_DRIVERS_${type_core_upper})
        message(VERBOSE "Adding HAL driver: ${driver}")
        list(APPEND hal_drivers ${driver})
      else()
        message(WARNING "Invalid HAL driver: ${driver}")
      endif()
    endforeach()
  endif()

  # validate LL drivers
  if(LL_DRIVERS IN_LIST ARG_KEYWORDS_MISSING_VALUES)
    message(VERBOSE "Adding all LL drivers")
    set(ll_drivers ${LL_DRIVERS_${type_core_upper}})
  else()
    list(REMOVE_DUPLICATES ARG_LL_DRIVERS)
    foreach(driver IN LISTS ARG_LL_DRIVERS)
      string(TOLOWER ${driver} driver)
      if(driver IN_LIST LL_DRIVERS_${type_core_upper})
        message(VERBOSE "Adding LL driver: ${driver}")
        list(APPEND ll_drivers ${driver})
      else()
        message(WARNING "Invalid LL driver: ${driver}")
      endif()
    endforeach()
  endif()

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
      AND (${STM32CUBE_PATH} MATCHES "STM32Cube[FGHLUW][0-9]")))
    message(
      FATAL_ERROR
        "Invalid path to STM32Cube${type_core_upper}: ${STM32CUBE_PATH}")
  endif()
  message(VERBOSE "Path to STM32Cube${type_core_upper}: ${STM32CUBE_PATH}")

  # build CMSIS
  add_library(
    ${mcu_lower}_cmsis OBJECT
    ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Source/Templates/gcc/startup_${mcu_lower}xx.s
    ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Source/Templates/system_stm32${type_core_lower}xx.c
  )
  target_compile_definitions(${mcu_lower}_cmsis PUBLIC -D${mcu_upper}xx)
  target_include_directories(
    ${mcu_lower}_cmsis
    PUBLIC
      ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
      ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Include
  )
  add_transitive_object_library(stm32::${mcu_lower}_cmsis ${mcu_lower}_cmsis)

  # build HAL as a link dependency for HAL drivers
  if(hal_drivers)
    add_library(
      ${mcu_lower}_hal OBJECT
      ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Src/stm32${type_core_lower}xx_hal.c
    )
    target_compile_definitions(${mcu_lower}_hal PUBLIC -D${mcu_upper}xx
                                                       -DUSE_HAL_DRIVER)
    target_include_directories(
      ${mcu_lower}_hal
      PUBLIC
        ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
        ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Include
        ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Inc)
    add_transitive_object_library(stm32::_${mcu_lower}_hal ${mcu_lower}_hal)
  endif()

  # build HAL libraries
  foreach(driver IN LISTS hal_drivers)
    add_library(
      ${mcu_lower}_hal_${driver} OBJECT
      ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Src/stm32${type_core_lower}xx_hal_${driver}.c
    )
    target_link_libraries(${mcu_lower}_hal_${driver}
                          PUBLIC stm32::_${mcu_lower}_hal)
    add_transitive_object_library(stm32::${mcu_lower}_hal_${driver}
                                  ${mcu_lower}_hal_${driver})
  endforeach()

  # build LL libraries
  foreach(driver IN LISTS ll_drivers)
    add_library(
      ${mcu_lower}_ll_${driver} OBJECT
      ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Src/stm32${type_core_lower}xx_ll_${driver}.c
    )
    set(defs -D${mcu_upper}xx)
    if(NOT (${driver} IN_LIST hal_drivers))
      # some HAL drivers are dependent on a portion of an LL driver. only use
      # the full LL driver if associated HAL driver is not used
      list(APPEND defs -DUSE_FULL_LL_DRIVER)
    endif()
    target_compile_definitions(${mcu_lower}_ll_${driver} PUBLIC ${defs})
    target_include_directories(
      ${mcu_lower}_ll_${driver}
      PUBLIC
        ${STM32CUBE_PATH}/Drivers/CMSIS/Core/Include
        ${STM32CUBE_PATH}/Drivers/CMSIS/Device/ST/STM32${type_core_upper}xx/Include
        ${STM32CUBE_PATH}/Drivers/STM32${type_core_upper}xx_HAL_Driver/Inc)
    add_transitive_object_library(stm32::${mcu_lower}_ll_${driver}
                                  ${mcu_lower}_ll_${driver})
  endforeach()
endfunction()

set(STM32Cube_VERSION 0.2.0)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  STM32Cube
  VERSION_VAR STM32Cube_VERSION
  HANDLE_COMPONENTS)
