## STM32 Support for CMake

This repository intends to add generic STM32 support to CMake. This includes `arm-none-eabi` toolchain support as well as support for ST's Cube libraries. The goal of this repository compared to other existing repositories is to allow one project to easily support multiple STM32 models.

See `examples` for project templates.

NOTE: The STM32L4 and STM32G4 families are only currently supported.

### Usage

CMake variables can be passed over the command line at configuration time by appending `-D<VARIABLE>=<VALUE>`. To configure, the following options should be specified:

- The path to to the toolchain file for your STM32 model.
  - `-DCMAKE_TOOLCHAIN_FILE=<path/to/cortex-mX.cmake>`

- The path to the STM32Cube libraries you are using in your project. This should either be an absolute path or a path relative to the file that calls `generate_stm32cube`.
  - `-DSTM32CUBEXX_PATH=<path/to/STM32CubeXX>`

Optionally, specify `-DCMAKE_BUILD_TYPE` as `Debug`, `Release`, `RelWithDebInfo` or `MinSizeRel`. By default, CMake uses an "empty" build type which does no optimization and does not include debug symbols.


### Example Projects

As an example, the following will compile the `blinky-hal` project with the STM32CubeL4 located in `examples/blinky-hal`
```bash
cd examples/blinky-hal
cmake -B build -DCMAKE_TOOLCHAIN_FILE=../../cmake/cortex-m4f.cmake -DCMAKE_BUILD_TYPE=Debug -DSTM32CUBEL4_PATH=STM32CubeL4
cmake --build build
```


### Creating a Custom Project

To create a custom CMake project, the root `CMakeLists.txt` should append the path to `cmake/FindSTM32.cmake` to `CMAKE_MODULE_PATH` then call `find_package(STM32Cube)`. Afterwards, any CMake file may call `generate_stm32cube` to use the STM32Cube library in your CMake project.

If using the HAL library, `CMAKE_INCLUDE_CURRENT_DIR` should be enabled before `generate_stm32cube` is called so that the `stm32XXxx_hal_conf.h` file is included while generating the HAL libraries.

`generate_stm32cube` has a required first argument of the 9-character stm32 model. This should look something like `stm32l412`. This first argument generates the CMSIS library for the provided model. The optional argument `HAL_DRIVERS` is a list of drivers in the HAL library to generate. The optional argument `LL_DRIVERS` is a list of drivers in the LL library to generate. The driver names are the suffixes of the STM32Cube library files (i.e. gpio, tim, adc).

Following the call to `generate_stm32cube`, the generated libraries will be of the form `stm32::<your_stm32_model>_cmsis` for the CMSIS library and `stm32::<your_stm32_model>_<hal/ll>_<driver>` for HAL/LL libraries.

A linker script should be linked when building the executable. This can be done by specifying the `-T` flag in `target_link_libraries`, i.e. `-T/path/to/linker_script.ld`.
