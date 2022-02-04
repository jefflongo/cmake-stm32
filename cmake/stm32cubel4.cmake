set(HAL_DRIVERS_L4
    adc can comp cortex crc cryp dac dcmi dfsdm dma dma2d dsi exti firewall 
    flash flash_ramfunc gfxmmu gpio hash hcd i2c irda iwdg lcd lptim ltdc mmc 
    nand nor opamp ospi pcd pka pssi pwr qspi rcc rng rtc sai sd smartcard smbus 
    spi sram swpmi tim tsc uart usart wwdg
)

set(LL_DRIVERS_L4
    adc comp crc crs dac dma dma2d exti fmc gpio i2c lptim lpuart opamp pka pwr 
    rcc rng rtc sdmmc spi swpmi tim usart usb utils
)

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

  # build CMSIS
  set(library_name ${mcu_lower}_cmsis)
  add_library(${library_name} STATIC
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/gcc/startup_${mcu_lower}xx.s
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/system_stm32l4xx.c
  )
  target_compile_definitions(${library_name} PUBLIC -D${mcu_upper}xx)
  target_include_directories(${library_name} PUBLIC
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Core/Include
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Include
  )

  # build HAL libraries
  foreach(driver IN LISTS hal_drivers)
    set(libray_name ${mcu_lower}_hal_${driver})
    add_library(${libray_name} STATIC
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_${driver}.c)
    target_compile_definitions(${libray_name} PUBLIC -D${mcu_upper}xx -DUSE_HAL_DRIVER)
    target_include_directories(${libray_name} PUBLIC
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Core/Include
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Include
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Inc
    )
  endforeach()

  # build LL libraries
  foreach(driver IN LISTS ll_drivers)
    set(libray_name ${mcu_lower}_ll_${driver})
    add_library(${libray_name} STATIC
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_${driver}.c)
    target_compile_definitions(${libray_name} PUBLIC -D${mcu_upper}xx -DUSE_FULL_LL_DRIVER)
    target_include_directories(${libray_name} PUBLIC
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Core/Include
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Include
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Inc
    )
  endforeach()
endfunction()
