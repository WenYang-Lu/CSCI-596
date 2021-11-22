void vectors_add(double* a, double* b, double* res, int n)
{
	for (int i = 0; i < n; i++)
		res[i] = a[i] + b[i];
}
void vectors_sub(double* a, double* b, double* res, int n)
{ 
	for (int i = 0; i < n; i++)
		res[i] = a[i] - b[i];
}
void vectors_scalar_mult(double* a, double b, double* res, int n)
{
	for (int i = 0; i < n; i++)
		res[i] = a[i] * b;
}
void vectors_scalar_div(double* a, double b, double* res, int n)
{
	for (int i = 0; i < n; i++)
		res[i] = a[i] / b;
}
double vectors_dot_prod(double* x, double* y, int n)
{
	double res = 0.0;
	for (int i = 0; i < n; i++)
		res += x[i] * y[i];

	return res;
}
void matrix_vector_mult(double** Mtx, double* vec, double* res, int rows, int cols)
{ 
	for (int i = 0; i < rows; i++)
		res[i] = vectors_dot_prod(Mtx[i], vec, cols);
}
void copyArray(double* copy, int* arr, int size)
{
	for (int i = 0; i < size; ++i)
		copy[i] = arr[i];
}

double* myGraphCheby_op(double** Mtx, double* c, double* signal, double* arange, bool flag_L)
{
/*************************************************************/
// Usage: y = myGraphCheby_op(Mtx, c, signal, arange, flag_L)
//
// Input parameters :
// Mtx : graph representation matrix
// c : chebyshev coefficients
// signal : signal to be filtered
// arange : eigenvalue range
// flag_L : Laplacian(true) or adjacency(false)
// Output parameters
// y : result of filtering
/*************************************************************/
	int N = sizeof(signal) / sizeof(signal[0]); //signal length
	int M = sizeof(c) / sizeof(c[0]); // filter length
	double a1, a2;
	double *Twf_old, *Twf_cur, *Twf_new;
	double *y;
	double *vec1; // vector container 
	Twf_old = (double*)malloc(N * sizeof(double));
	Twf_cur = (double*)malloc(N * sizeof(double));
	Twf_new = (double*)malloc(N * sizeof(double));
	y = (double*)malloc(N * sizeof(double));
	vec1 = (double*)malloc(N * sizeof(double));
	vec2 = (double*)malloc(N * sizeof(double));
	vec3 = (double*)malloc(N * sizeof(double));

	if (flag_L){ // using Laplacian matrix
		a1 = (arange[1] - arange[0]) / 2.0;
		a2 = (arange[1] + arange[0]) / 2.0;
	}
	else{ // using adjacency matrix
		a1 = -(arange[1] - arange[0]) / 2.0;
		a2 = -(arange[1] + arange[0]) / 2.0;
	}

	// iteration 1; Twf_old = signal
	copyArray(Twf_old, signal, N);

	// iteration 2; Twf_cur = (Mtx * signal - a2 * signal) / a1 
	matrix_vector_mult(Mtx, signal, Twf_cur, N, N);
	vectors_scalar_mult(signal, a2, vec1, N);
	vectors_sub(Twf_cur, vec1, Twf_cur, N);
	vectors_scalar_div(Twf_cur, a1, Twf_cur, N);

	// y = c(1) * Twf_old + 2 * c(2) * Twf_cur;
	vectors_scalar_mult(Twf_old, c[0], y, N);
	vectors_scalar_mult(Twf_cur, 2.0*c[1], vec1, N);
	vectors_add(y, vec1, y, N);

	for (int k = 2; k < M; k++){
		// Twf_new = (2 / a1) * (Mtx * Twf_cur - a2 * Twf_cur) - Twf_old;
		matrix_vector_mult(Mtx, Twf_cur, Twf_new, N, N);
		vectors_scalar_mult(Twf_cur, a2, vec1, N);
		vectors_sub(Twf_new, vec1, Twf_new, N);
		vectors_scalar_mult(Twf_new, 2.0 / a1, Twf_new, N);
		vectors_sub(Twf_new, Twf_old, Twf_new, N);

		// y = y + 2 * c(k) * Twf_new;
		vectors_scalar_mult(Twf_new, 2*c[k], vec1, N);
		vectors_add(y, vec1, y, N);

		// Twf_old = Twf_cur;
		copyArray(Twf_old, Twf_cur, N);

		// Twf_cur = Twf_new;
		copyArray(Twf_cur, Twf_new, N);

	}

	return y;
}
/*
Twf_old = signal;% iteration 1
Twf_cur = (Mtx * signal - a2 * signal) / a1;% iteration 2
y = c(1) * Twf_old + 2 * c(2) * Twf_cur;
for k = 3:numel(c) % iterative filtering
	Twf_new = (2 / a1) * (Mtx * Twf_cur - a2 * Twf_cur) - Twf_old;
	y = y + 2 * c(k) * Twf_new;
	Twf_old = Twf_cur;
	Twf_cur = Twf_new;
end
*/
