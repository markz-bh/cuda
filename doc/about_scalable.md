There are three key abstractions to develop software that transparently scales its parallelism to leverage the increasing number of processor cores: _a hierarchy of thread groups_, _shared memories_, and _barrier synchronization_. 
These abstractions provide fine-grained data parallelism and thread parallelism, nested within coarse-grained data parallelism and task parallelism. They guide the programmer to partition the problem into coarse sub-problems that can be solved independently in parallel by blocks of threads, and each sub-problem into finer pieces that can be solved cooperatively in parallel by all threads within the block. 

A GPU is built around an array of Streaming Multiprocessors (SMs). A multithreaded program is partitioned into blocks of threads that execute independently from each other, so that a GPU with more multiprocessors will automatically execute the program in less time than a GPU with fewer multiprocessors. 

This decomposition preserves language expressivity by allowing threads to cooperate when solving each sub-problem, and at the same time enables automatic scalability. Indeed, each block of threads can be scheduled on any of the available multiprocessor within a GPU, in any order, concurrently or sequentially, so that a compiled CUDA program can execute on any number of multiprocessors, and only the runtime system needs to know the physical multiprocessor count. 

This scalable programming model allows the GPU architecture to span a wide market range by simply scaling the number of multiprocessors and memory partitions. 

## Kernels
 when called, are executed N times in parallel by N different CUDA threads, as opposed to only once like regular C++ functions. It is defined by `__global__` declaration specifier and the number of CUDA threads that execute that kernel for a given kernel call is specified by a new `<<<...>>>` executation configuration syntax. Each thread that executes the kernel is given a unique thread ID that is accessible within the kernel through built-in variables.

## Thread Hierarchy
 The index of a thread and its thread ID relate to each other in a straightforward way: For a one-dimensional block, they are the same; for a two-dimensional block of size $(Dx, Dy)$, the thread ID of a thread of index $(x, y)$ is $(x + y Dx)$; for a three-dimensional block of size $(Dx, Dy, Dz)$, the thread ID of a thread of index $(x, y, z)$ is $(x + y Dx + z Dx Dy)$.

There is a limit to the number of threads per block, since all threads of a block are expected to reside on the same streaming multiprocessor core and must share the limited memory resources of that core. On current GPUs, a thread block may contain up to __1024__ threads.
However, a kernel can be executed by multiple equally-shaped thread blocks, so that the total number of threads is equal to the number of threads per block times the number of blocks.

Blocks are organized into a one-dimensional, two-dimensional, or three-dimensional grid of thread blocks 
![](figure/grid-of-thread-blocks.png)

The number of thread blocks in a grid is usually dictated by the size of the data being processed, which typically exceeds the number of processors in the system. The number of threads per block and the number of blocks per grid specified in the `<<<...>>>` syntax can be of type `int` or `dim3`. 
```
    ...
    // Kernel invocation
    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks(N / threadsPerBlock.x, N / threadsPerBlock.y);
    MatAdd<<<numBlocks, threadsPerBlock>>>(A, B, C);
    ...
```
A thread block size of $16x16$ (256 threads), although arbitrary in this case, is a common choice.

### shared memory
Thread blocks are required to execute independently: It must be possible to execute them in any order, in parallel or in series. This independence requirement allows thread blocks to be scheduled in any order across any number of cores, enabling programmers to write code that scales with the number of cores.

Threads within a block can cooperate by sharing data through some shared memory and by synchronizing their execution to coordinate memory accesses. More precisely, one can specify synchronization points in the kernel by calling the `__syncthreads()` intrinsic function; `__syncthreads()` acts as a barrier at which all threads in the block must wait before any is allowed to proceed. In addition to `__syncthreads()`, the Cooperative Groups API provides a rich set of thread-synchronization primitives.

For efficient cooperation, the shared memory is expected to be a low-latency memory near each processor core (much like an L1 cache) and `__syncthreads()` is expected to be lightweight.

### Thread block clusters
In GPUs with compute capability 9.0, all the thread blocks in the cluster are guaranteed to be co-scheduled on a single GPU Processing Cluster (GPC) and allow thread blocks in the cluster to perform hardware-supported synchronization using the Cluster Group API cluster.sync(). Cluster group also provides member functions to query cluster group size in terms of number of threads or number of blocks using num_threads() and num_blocks() API respectively. The rank of a thread or block in the cluster group can be queried using dim_threads() and dim_blocks() API respectively.

Thread blocks that belong to a cluster have access to the Distributed Shared Memory. Thread blocks in a cluster have the ability to read, write, and perform atomics to any address in the distributed shared memory.

## Memory ~~Hierarchy~~
![](figure\memory-hierarchy.png)