# GPUAdder

GPUAdder is a macOS application that demonstrates various methods for performing vector addition, utilizing both CPU and GPU capabilities. This project showcases the efficiency and performance differences between single-threaded CPU, multi-threaded CPU, and GPU-based computations using Metal.

With the advent of modern processors and graphics cards, parallel processing has become a critical aspect of computational performance. GPUAdder explores three different approaches to vector addition on macOS:

- Single-threaded CPU computation
- Multi-threaded CPU computation using Grand Central Dispatch
- GPU computation using Metal

The project aims to illustrate how different computing resources can be harnessed for parallel processing and the resultant performance gains.

The program generates two large arrays filled with random floating-point numbers and performs vector addition using three different methods. The results and the time taken for each method are logged to the console.
