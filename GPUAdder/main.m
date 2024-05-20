//
//  main.m
//  GPUAdder
//
//  Created by Saksham Khatod on 3/10/24.
//

#import <Foundation/Foundation.h>
#import "MetalKit/MetalKit.h"

#define count 300000000

float *getRandomArray(void);
void computeWay(float *arr1, float *arr2);
void basicForLoopWay(float *arr1, float *arr2);
void basicForLoopWayMultiThreaded(float *arr1, float *arr2);

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        float *array1 = getRandomArray();
        float *array2 = getRandomArray();
        
        computeWay(array1, array2);
        basicForLoopWay(array1, array2);
        basicForLoopWayMultiThreaded(array1, array2);
        
        return 0;
    }
    return 0;
}

float* getRandomArray(void) {
    float* dataPtr = malloc(sizeof(float) * count);
    for(unsigned long i=0; i<count; i++) {
        dataPtr[i] = (float)rand()/RAND_MAX;
    }
    return dataPtr;
}

void computeWay(float *arr1, float *arr2) {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    id<MTLDevice> gpu = MTLCreateSystemDefaultDevice();
    
    id<MTLCommandQueue> commandQueue = [gpu newCommandQueue];
    id<MTLLibrary> gpuFunctionLibrary = [gpu newDefaultLibrary];
    
    id<MTLFunction> additionGPUFunction = [gpuFunctionLibrary newFunctionWithName:@"addition_compute_function"];
    
    NSError *error;
    id<MTLComputePipelineState> additionComputePipelineState = [gpu newComputePipelineStateWithFunction:additionGPUFunction error:&error];
    if(error) {
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    
    NSLog(@"\nOff to the GPU!");
    
    id<MTLBuffer> arr1Buffer = [gpu newBufferWithBytes:arr1 length:sizeof(float) * count options:MTLResourceStorageModeShared];
    id<MTLBuffer> arr2Buffer = [gpu newBufferWithBytes:arr2 length:sizeof(float) * count options:MTLResourceStorageModeShared];
    id<MTLBuffer> resultBuffer = [gpu newBufferWithLength:sizeof(float) * count options:MTLResourceStorageModeShared];
    
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
    [commandEncoder setComputePipelineState:additionComputePipelineState];
    
    [commandEncoder setBuffer:arr1Buffer offset:0 atIndex:0];
    [commandEncoder setBuffer:arr2Buffer offset:0 atIndex:1];
    [commandEncoder setBuffer:resultBuffer offset:0 atIndex:2];
    
    MTLSize threadsPerGrid = MTLSizeMake(count, 1, 1);
    NSUInteger maxThreadsPerThreadGroup = [additionComputePipelineState maxTotalThreadsPerThreadgroup];
    NSLog(@"\nThreads per thread group : %lu", (unsigned long)maxThreadsPerThreadGroup);
    
    if(maxThreadsPerThreadGroup > count) {
        maxThreadsPerThreadGroup = count;
    }
    
    MTLSize threadsPerThreadGroup  = MTLSizeMake(maxThreadsPerThreadGroup, 1, 1);
    
    [commandEncoder dispatchThreads:threadsPerGrid threadsPerThreadgroup:threadsPerThreadGroup];
    [commandEncoder endEncoding];
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    float *resultBufferPointer = (float *)[resultBuffer contents];
    for(int i=0; i<3; i++) {
        NSLog(@"%f + %f = %@", arr1[i], arr2[i], @(resultBufferPointer[i]));
    }
    
    CFAbsoluteTime timeElapsed = CFAbsoluteTimeGetCurrent() - startTime;
    NSLog(@"Time Elapsed : %@", @(timeElapsed));
    NSLog(@"\n");
    
}

void basicForLoopWayMultiThreaded(float *arr1, float *arr2) {
    NSLog(@"Off to the CPU (Multi-threaded)!");
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    float* result = malloc(sizeof(float) * count);
    
    dispatch_apply(count, concurrentQueue, ^(size_t i) {
        result[i] = arr1[i] + arr2[i];
    });
    
    for (int i = 0; i < 3; i++) {
        NSLog(@"%f + %f = %f", arr1[i], arr2[i], result[i]);
    }
    
    CFAbsoluteTime timeElapsed = CFAbsoluteTimeGetCurrent() - startTime;
    NSLog(@"Time Elapsed : %@", @(timeElapsed));
    NSLog(@"\n");
}


void basicForLoopWay(float *arr1, float *arr2) {
    NSLog(@"Off to the CPU!");
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    float *result = malloc(sizeof(float) * count);
    for(unsigned long i=0; i<count; i++) {
        result[i] = arr1[i] + arr2[i];
    }
    
    for(int i=0; i<3; i++) {
        NSLog(@"%f + %f = %f", arr1[i], arr2[i], result[i]);
    }
    
    CFAbsoluteTime timeElapsed = CFAbsoluteTimeGetCurrent() - startTime;
    NSLog(@"Time Elapsed : %@", @(timeElapsed));
    NSLog(@"\n");
}
