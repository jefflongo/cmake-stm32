## STM32 Support for CMake

This repository intends to add generic STM32 support to CMake. This includes `arm-none-eabi` toolchain support as well as support for ST's Cube libraries. The goal of this project compared to other existing repositories is to allow one project to support multiple STM32 models.

See the example `blinky` project for a template. 

### Building
to configure, specify the path to the STM32Cube library with the `-DSTM32CUBEXX_PATH` flag. See the following example for the `blinky` project

configure
```
cmake -B build -DSTM32CUBEL4_PATH=STM32CubeL4
```

build
```
cmake --build build
```
