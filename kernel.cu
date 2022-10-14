#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#define arraySize 1000

__global__ void addKernel(int* c, const int* a, const int* b)
{
	int i = threadIdx.x;

	if (i < arraySize)
		c[i] = a[i] + b[i];
}

int main()
{
	int a[arraySize];
	int b[arraySize];
	int c[arraySize];

	int* dev_a = 0;
	int* dev_b = 0;
	int* dev_c = 0;

	for (int i = 0; i < arraySize; i++) {
		a[i] = i;
		b[i] = i;
	}

	cudaMalloc((void**)&dev_c, arraySize * sizeof(int));
	cudaMalloc((void**)&dev_a, arraySize * sizeof(int));
	cudaMalloc((void**)&dev_b, arraySize * sizeof(int));

	cudaMemcpy(dev_a, a, arraySize * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b, arraySize * sizeof(int), cudaMemcpyHostToDevice);

	addKernel KERNEL_ARGS2 (1, arraySize) (dev_c, dev_a, dev_b);
	cudaDeviceSynchronize();

	cudaMemcpy(c, dev_c, arraySize * sizeof(int), cudaMemcpyDeviceToHost);

	for (int i = 0; i < arraySize; i++) {
		printf("%d + %d = %d\n", a[i], b[i], c[i]);
	}

	cudaFree(dev_c);
	cudaFree(dev_a);
	cudaFree(dev_b);

	return 0;
}