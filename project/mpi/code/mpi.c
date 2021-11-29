#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <mpi.h>
#define ROW 319
#define COLUMN 319

double vectors_dot_prod(double* x, double* y, int n)
{
        double res = 0.0;
        for (int i = 0; i < n; i++)
                res += x[i] * y[i];
        return res;
}

int main(int argc, char *argv[]){
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


//MPI 
	int rank, numprocs
	MPI_Init(&argc, &argv);//MPI Initialize
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&numprocs);


        cpu1 = MPI_Wtime();
	MPI_Bcast(&ROW, 1, MPI_INT, 0, MPI_COMM_WORLD);
        for (int i = 0; i < ROW; i++)
        {
            
	MPI_Bcast(res[i], ROW, MPI_INT, 0, MPI_COMM_WORLD);
		//res[i] =vectors_dot_prod(Mtx[i], signal, COLUMN);
        //printf("res[%d] is computed by thread number : %d\n", i, thread_id);
	}
	for (int i = rank; i<COLUMN; i+=numprocs){
		res[i] =vectors_dot_prod(Mtx[i], signal, COLUMN);
	}




    // print the array after parallel computing
   
   
	//cpu2 = MPI_Wtime();
	//int procs =omp_get_num_procs();
	//printf("Processor: %d\n", procs);
	//printf("Time: %le\n", cpu2-cpu1);

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
