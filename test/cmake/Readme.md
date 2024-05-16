# Quick start
```
cd build
cmake ..
# cmake .. -DCMAKE_CUDA_ARCHITECTURES=86  
```
Here `86` means _Compute Capability 8.6_ that is decided by your hardware. 

If you use Visual Studio, open _cmake_and_cuda.sln_ solution, build and run _seqCuda_ project.  


# MISC
> empty CUDA_ARCHITECTURES not allowed

`nvidia-smi` command-line utility comes with NVIDIA driver lists your GPU model. Find compute capability by GPU type on [cuda-gpus](https://developer.nvidia.com/cuda-gpus). For example `RTX A4500` has Compute Capability`8.6`. Passing the argument `-DCMAKE_CUDA_FLAGS="-arch=sm_86"` passes `-arch=sm_86` to `nvcc` that target the Ampere microarchitecture GPU in my computer. 