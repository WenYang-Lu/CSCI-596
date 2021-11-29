// Using CUDA device to calculate pi
#include <stdio.h>
#include <cuda.h>
#include <time.h>
#include <stdlib.h>

__global__ void cal_matrix_multiplication(int* A, int* B, int* C, int m, int n, int p) {
	int r = threadIdx.x;
	int c = threadIdx.y;
	int i;
	for (i = 0; i < n; i++) {
		C[r*p + c] += A[r*n + i] * B[i*p + c];
	}
}

void func(int m, int n, int p) {
	int i;
	float cpu1,cpu2;
	int* A = (int*)malloc(m * n * sizeof(int));
	int* B = (int*)malloc(n * p * sizeof(int));

	for (i = 0; i < m * n; i++)
        A[i] = i;
	for (i = 0; i < n * p; i++)
        B[i] = i;
	
	cpu1 = ((double) clock())/CLOCKS_PER_SEC;

	dim3 dimGrid(1,1,1);  // Grid dimensions
	dim3 dimBlock(m,p,1);  // Block dimensions
	int* C = (int*)malloc(m * p * sizeof(int)); //  Allocate array on host
	int *A_dev, *B_dev, *C_dev; // Pointer to device arrays
	cudaMalloc((void **) &A_dev, m*n*sizeof(int));  // Allocate array on device
	cudaMalloc((void **) &B_dev, n*p*sizeof(int));  // Allocate array on device
	cudaMalloc((void **) &C_dev, m*p*sizeof(int));  // Allocate array on device
	cudaMemcpy(A_dev, A, m*n*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(B_dev, B, n*p*sizeof(int), cudaMemcpyHostToDevice);
	// Initialize array in device to 0
	cudaMemset(C_dev, 0, m*p*sizeof(int));
	// Do calculation on device
	cal_matrix_multiplication <<<dimGrid, dimBlock>>> (A_dev, B_dev, C_dev, m, n, p); // call CUDA kernel
	// Retrieve result from device and store it in host array
	cudaMemcpy(C, C_dev, m*p*sizeof(int), cudaMemcpyDeviceToHost);

	cpu2 = ((double) clock())/CLOCKS_PER_SEC;
  	printf("%d, Execution time (s) = %le\n",m, cpu2-cpu1);
	// Print results
	/*
	printf("A = \n");
	for (i = 0; i < m; i++) {
		for (j = 0; j < n; j++) {
        	printf("%d ", A[i*n+j]);
		}
		printf("\n");
	}
	printf("B = \n");
	for (i = 0; i < n; i++) {
		for (j = 0; j < p; j++) {
        	printf("%d ", B[i*p+j]);
		}
		printf("\n");
	}
	printf("C = \n");
	for (i = 0; i < m; i++) {
		for (j = 0; j < p; j++) {
        	printf("%d ", C[i*p+j]);
		}
		printf("\n");
	}
	*/

	// Cleanup
	free(A);
	free(B);
	free(C);

	cudaFree(A_dev);
	cudaFree(B_dev);
	cudaFree(C_dev);
}
// Main routine that executes on the host
int main(void) {
	int i;
	for (i = 1; i < 1025; i*=2)
		func(i,i,i);

	return 0;
}