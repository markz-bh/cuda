
# CMake and CUDA
## C++ Language Level
You can easily require a specific version of the CUDA compiler through either `CMAKE_CUDA_STANDARD` or the `target_compile_features` command. To make `target_compile_features` easier to use with CUDA, CMake uses the same set of C++ feature keywords for CUDA C++.
The following code shows how to request C++ 11 support for the `particles` target, which means that any CUDA file used by the `particles` target will be compiled with CUDA C++ 11 enabled (`--std=c++11` argument to `nvcc`).
```
# Request that particles be built with --std=c++11
# As this is a public compile feature anything that links to particles
# will also build with -std=c++11
target_compile_features(particles PUBLIC cxx_std_11)
```
## Enabling Position-Independent Code
When working on large projects it is common to generate one or more shared libraries. Each object file that is part of a shared library usually needs to be compiled with position-independent code enabled, which is done by setting the `fPIC` compiler flag. Unfortunately `fPIC` isn’t consistently supported across all compilers, so CMake abstracts away the issue by automatically enabling position-independent code when building _shared_ libraries. 
In the case of _static_ libraries that will be linked into _shared_ libraries, position-independent code needs to be _explicitly enabled_ by setting the `POSITION_INDEPENDENT_CODE` target property as follows.
```
set_target_properties(particles PROPERTIES POSITION_INDEPENDENT_CODE ON)
```
CMake 3.8 supports the `POSITION_INDEPENDENT_CODE` property for CUDA compilation, and builds all host-side code as relocatable when requested. This is great news for projects that wish to use CUDA in cross-platform projects or inside shared libraries, or desire to support esoteric C++ compilers.

## Separable Compilation
By default the CUDA compiler uses whole-program compilation. Effectively this means that all device functions and variables needed to be located inside a single file or compilation unit. Separate compilation and linking was introduced in CUDA 5.0 to allow components of a CUDA program to be compiled into separate objects. For this to work properly any library or executable that uses separable compilation has two linking phases. First it must do device linking for all the objects that contain CUDA device code, and then it must do the host side linking, including the results of the previous link phase.

Separable compilation not only allows projects to maintain a code structure where independent functions are kept in separate locations, it helps improve incremental build performance (a feature of all CMake based projects). Incremental builds allow recompilation and linking of only units that have been modified, which reduces build times. The primary drawback of sepable compilation is that certain function call optimizations are disabled for calls to functions that reside in a different compilation bit, since the compiler has no knowledge of the details of the function being called.

CMake now fundamentally understands the concepts of separate compilation and device linking. Implicitly, CMake defers device linking of CUDA code as long as possible, so if you are generating static libraries with relocatable CUDA code the device linking is deferred until the static library is linked to a shared library or an executable. This is a significant improvement because you can now compose your CUDA code into multiple static libraries, which was previously impossible with CMake. To control separable compilation in CMake, turn on the `CUDA_SEPARABLE_COMPILATION` property for the target as follows.
```
set_target_properties(particles PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
```

If you need separable compilation device linking to occur before consumption by a shared library or executable,you can explicitly request CMake to invoke device linking by setting the target property `CUDA_RESOLVE_DEVICE_SYMBOLS`.

## PTX Generation
If you want to package PTX files for load-time JIT compilation instead of compiling CUDA code into a collection of libraries or executables, you can enable the `CUDA_PTX_COMPILATION` property as in the following example. This example compiles some `.cu` files to PTX and then specifies the installation location.
```
add_library(CudaPTX OBJECT kernelA.cu kernelB.cu)
set_property(TARGET CudaPTX PROPERTY CUDA_PTX_COMPILATION ON)

install(TARGETS CudaPTX
   OBJECTS DESTINATION bin/ptx 
)
```
To make PTX generation possible, CMake was extended so that all OBJECT libraries are capable of being installed, exported, imported, and referenced in generator expressions. This also enables PTX files to be converted or processed by tools such as bin2c and then embedded as C-strings into a library or executable. 
