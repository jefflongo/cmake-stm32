set(HAL_DRIVERS_L4
    adc can comp cortex crc cryp dac dcmi dfsdm dma dma2d dsi exti firewall 
    flash flash_ramfunc gfxmmu gpio hash hcd i2c irda iwdg lcd lptim ltdc mmc 
    nand nor opamp ospi pcd pka pssi pwr qspi rcc rng rtc sai sd smartcard smbus 
    spi sram swpmi tim tsc uart usart wwdg
)

# TODO: fmc/sdmmc/usb requires HAL conf for some reason
set(LL_DRIVERS_L4
    adc comp crc crs dac dma dma2d exti gpio i2c lptim lpuart opamp pka pwr 
    rcc rng rtc spi swpmi tim usart utils
)

function(find_stm32cubel4 mcu)
  # TODO: validate input

  string(TOUPPER ${mcu} mcu_upper)
  string(TOLOWER ${mcu} mcu_lower)

  # build CMSIS
  add_library(${mcu_lower} STATIC
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/gcc/startup_${mcu_lower}xx.s
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Source/Templates/system_stm32l4xx.c
  )
  target_compile_definitions(${mcu_lower} PUBLIC -D${mcu_upper}xx)
  target_include_directories(${mcu_lower} PUBLIC
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Core/Include
    ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Include
  )

  # build HAL libraries
  # foreach(driver IN LISTS HAL_DRIVERS_L4)
  #   add_library(stm32l4_hal_${driver} STATIC
  #     ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_${driver}.c)
  #   target_compile_definitions(stm32l4_hal_${driver} PUBLIC -D${mcu_upper}xx -DUSE_HAL_DRIVER)
  #   target_include_directories(stm32l4_hal_${driver} PUBLIC
  #     ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Core/Include
  #     ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Include
  #     ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Inc
  #   )
  # endforeach()

  # build LL libraries
  foreach(driver IN LISTS LL_DRIVERS_L4)
    add_library(stm32l4_ll_${driver} STATIC
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_ll_${driver}.c)
    target_compile_definitions(stm32l4_ll_${driver} PUBLIC -D${mcu_upper}xx -DUSE_FULL_LL_DRIVER)
    target_include_directories(stm32l4_ll_${driver} PUBLIC
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Core/Include
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/CMSIS/Device/ST/STM32L4xx/Include
      ${CMAKE_SOURCE_DIR}/STM32CubeL4/Drivers/STM32L4xx_HAL_Driver/Inc
    )
  endforeach()
endfunction()
