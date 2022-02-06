## STM32 Support for CMake

This repository intends to add generic STM32 support to CMake. This includes `arm-none-eabi` toolchain support as well as support for ST's Cube libraries. The goal of this repository compared to other existing repositories is to allow one project to easily support multiple STM32 models.

See `examples` for project templates.

NOTE: The STM32L4 family is currently the only supported family.

### Usage
CMake variables can be passed over the command line at configuration time by appending `-D<VARIABLE>=<VALUE>`. To configure, the following options should be specified:

- The path to to the toolchain file for your STM32 model.
  - `-DCMAKE_TOOLCHAIN_FILE=<path/to/cortex-mX.cmake>`

- The path to the STM32Cube libraries you are using in your project. This should either be an absolute path or a path relative to the file that calls `generate_stm32cube`.
  - `-DSTM32CUBEXX_PATH=<path/to/STM32CubeXX>`

Optionally, specify `-DCMAKE_BUILD_TYPE` as `Debug`, `Release`, `RelWithDebInfo` or `MinSizeRel`. By default, CMake uses an "empty" build type which does no optimization and does not include debug symbols.

As an example, the following will compile the `blinky` project with the STM32CubeL4 located in `examples/blinky`
```bash
cmake -B build -DCMAKE_TOOLCHAIN_FILE=../../cmake/cortex-m4.cmake -DCMAKE_BUILD_TYPE=Debug -DSTM32CUBEL4_PATH=../../../STM32CubeL4
cmake --build build
```
