#include <stdio.h>
#include <time.h>
#include <stdlib.h>

void func(int m, int n, int p) {
	int i;
	int* A = (int*)malloc(m * n * sizeof(int));
	int* B = (int*)malloc(n * p * sizeof(int));
	for (i = 0; i < m * n; i++)
        A[i] = 1;
	for (i = 0; i < n * p; i++)
        B[i] = 1;

	float cpu1,cpu2;
	cpu1 = ((float) clock())/CLOCKS_PER_SEC;

    int* C = (int*)malloc(m * p * sizeof(int));
	for (i = 0; i < m * p; i++)
        C[i] = 0;
	
	int r, c;
    for (r = 0; r < m; r++) {
        for (c = 0; c < p; c++) {
            for (i = 0; i < n; i++) {
                C[r*p + c] += A[r*n + i] * B[i*p + c];
            }
        }
    }
	cpu2 = ((float) clock())/CLOCKS_PER_SEC;
  	printf("%d, Execution time (s) = %le\n",m,cpu2-cpu1);
	// Print results
	// printf("A = \n");
	// for (i = 0; i < m; i++) {
	// 	for (j = 0; j < n; j++) {
    //     	printf("%d ", A[i*n+j]);
	// 	}
	// 	printf("\n");
	// }
	// printf("B = \n");
	// for (i = 0; i < n; i++) {
	// 	for (j = 0; j < p; j++) {
    //     	printf("%d ", B[i*p+j]);
	// 	}
	// 	printf("\n");
	// }
	// printf("C = \n");
	// for (i = 0; i < m; i++) {
	// 	for (j = 0; j < p; j++) {
    //     	printf("%d ", C[i*p+j]);
	// 	}
	// 	printf("\n");
	// }

	// Cleanup
	free(A);
	free(B);
	free(C);
}
int main(void) {
	int i;
	for (i = 1; i < 1025; i*=2)
		func(i,i,i);
	
	return 0;
}