#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#define ROW 1000
#define COLUMN 1000

double vectors_dot_prod(double* x, double* y, int n)
{
        double res = 0.0;
        for (int i = 0; i < n; i++)
                res += x[i] * y[i];
        return res;
}

int main(){
    double Mtx[ROW][COLUMN];
    double signal[COLUMN];
    double res[COLUMN];
    double cpu1;
    double cpu2;
    for(int i = 0; i < ROW; i++) {
        for(int j = 0; j < COLUMN; j++) {
            Mtx[i][j] = rand() % 10;
        }
    }
    for(int j = 0; j < COLUMN; j++) {
            signal[j] = rand() % 10;
    }

        cpu1 = omp_get_wtime();
#pragma omp parallel
    {
        const int thread_id = omp_get_thread_num();
        // parallel computing for matrix multiplication
#pragma omp for
        for (int i = 0; i < ROW; i++)
        {
            
		res[i] = 0.0; 
        	for (int j = 0; j < COLUMN; j++)
                {
		res[i] += Mtx[i][j] * singnal[j];
		}

		//res[i] =vectors_dot_prod(Mtx[i], signal, COLUMN);
        //printf("res[%d] is computed by thread number : %d\n", i, thread_id);
	}
    }        
    // print the array after parallel computing
   
   
	cpu2 = omp_get_wtime();
	int procs =omp_get_num_procs();
	printf("Processor: %d\n", procs);
	printf("Time: %le\n", cpu2-cpu1);

/* 
//print matrix and vector
    printf("Matrix \n");
    for(int i = 0; i < ROW; i++) {
        for(int j = 0; j < COLUMN; j++) {
            printf("%lf\t", Mtx[i][j]);
        }
        putchar('\n');
    }
    putchar('\n');

    printf("Vector \n");
    for(int j = 0; j < COLUMN; j++) {
        printf("%lf\t", signal[j]);
        putchar('\n');
    }
    putchar('\n');

    printf("res \n");
    for (int i = 0; i < ROW; i++)
    {
        printf("%lf\t", res[i]);
        putchar('\n');
    }
*/

    return 0;
}
