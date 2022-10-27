


using namespace std;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <cuda.h>

// ----------------------------------------------------------------------------
char* aloca_sequencia(int n)
{
	char* seq;

	seq = (char*)malloc((n + 1) * sizeof(char));
	if (seq == NULL)
	{
		printf("\nErro na alocação de estruturas\n");
		exit(1);
	}
	return seq;
}
// ----------------------------------------------------------------------------
int** aloca_matriz(int n, int m)
{
	int** mat,
		i;

	mat = (int**)malloc((n + 1) * sizeof(int*));
	if (mat == NULL)
	{
		printf("\nErro na alocação de estruturas\n");
		exit(1);
	}
	for (i = 0; i <= n; i++)
	{
		mat[i] = (int*)malloc((m + 1) * sizeof(int));
		if (mat[i] == NULL)
		{
			printf("\nErro na alocação de estruturas\n");
			exit(1);
		}
	}
	return mat;
}
// ----------------------------------------------------------------------------
void distancia_edicao(int n, int m, char* s, char* r, int** d)
{
	int t, a, b, c, min, i, j;

	for (i = 1; i <= n; i++)
	{
		for (j = 1; j <= m; j++)
		{
			t = (s[i] != r[j] ? 1 : 0);
			a = d[i][j - 1] + 1;
			b = d[i - 1][j] + 1;
			c = d[i - 1][j - 1] + t;
			// Calcula d[i][j] = min(a, b, c)
			if (a < b)
				min = a;
			else
				min = b;
			if (c < min)
				min = c;
			d[i][j] = min;
		}
	}
}

//cuda
__global__ void calcula_adiagonal(int* tamMaxAdiag, int* indexLinhaInferior, char** r, char** s, int* indexColunaInferior, int* n, int* m, int*** d) 
{
	//calcular threadId e subtrair ele da linha e somar na coluna. assim, encontramos os index da matriz pelos quais cada thread é responsável
	int threadId = threadIdx.x + blockIdx.x * blockDim.x;

	//check if there are more threads than elements to compute
	if(threadID > tamMaxAdiag[0]) {
		return;
	}

	int i = indexLinhaInferior[0] - threadId;
	int j = indexColunaInferior[0] + threadId;
	
	int t, a, b, c, min;

	t = (s[i] != r[j] ? 1 : 0);
	a = d[i][j - 1] + 1;
	b = d[i - 1][j] + 1;
	c = d[i - 1][j - 1] + t;

	// Calcula d[i][j] = min(a, b, c)
	if(a < b) {
		min = a;
	}else {
		min = b;
	}if (c < min) {
		min = c;
	}
	d[i][j] = min;
}

// ----------------------------------------------------------------------------
int distancia_edicao_adiagonal(int n, int m, char* s, char* r, int** d) //função alterada de void para int de forma a retornar a distancia
{
	int nADiag,			// Número de anti-diagonais
		tamMaxADiag,	// Tamanho máximo (número máximo de células) da anti-diagonal
		aD,				// Anti-diagonais numeradas de 2 a nADiag + 1
		k, i, j,
		t, a, b, c, min;

	nADiag = n + m - 1;
	tamMaxADiag = n;

	//Para cada anti-diagonal
	//lançar threads aqui, transformar o conteúdo desse for em uma função CUDA
	for (aD = 2; aD <= nADiag + 1; aD++)
	{
		//invocar kernel
	}
}

// ----------------------------------------------------------------------------
void libera(int n, char* s, char* r, int** d)
{
	int i;

	free(s);
	free(r);
	for (i = 0; i <= n; i++)
	{
		free(d[i]);
	}
}
// ----------------------------------------------------------------------------
int main(int argc, char** argv)
{
	int n,	// Tamanho da sequência s
		m,	// Tamanho da sequência r
		** d,	// Matriz de distâncias com tamanho (n+1)*(m+1)
		i, j;
	char* s,	// Sequência s de entrada (vetor com tamanho n+1)
		* r;	// Sequência r de entrada (vetor com tamanho m+1)
	FILE* arqEntrada;	// Arquivo texto de entrada

	if (argc != 2)
	{
		printf("O programa foi executado com argumentos incorretos.\n");
		printf("Uso: ./dist_seq <nome arquivo entrada>\n");
		exit(1);
	}

	// Abre arquivo de entrada
	arqEntrada = fopen(argv[1], "rt");

	if (arqEntrada == NULL)
	{
		printf("\nArquivo texto de entrada não encontrado\n");
		exit(1);
	}

	// Lê tamanho das sequências s e r
	fscanf(arqEntrada, "%d %d", &n, &m);

	// Aloca vetores s e r
	s = aloca_sequencia(n);
	r = aloca_sequencia(m);

	// Aloca matriz d
	d = aloca_matriz(n, m);

	// Lê sequências do arquivo de entrada
	s[0] = ' ';
	r[0] = ' ';
	fscanf(arqEntrada, "%s", &(s[1]));
	fscanf(arqEntrada, "%s", &(r[1]));

	// Fecha arquivo de entrada
	fclose(arqEntrada);

	//TODO: CUDA MALLOCS AQUI
	// Inicializa matriz de distâncias d
	for (i = 0; i <= n; i++)
	{
		d[i][0] = i;
	}
	for (j = 1; j <= m; j++)
	{
		d[0][j] = j;
	}

	
	// Calcula distância de edição entre sequências s e r
	//distancia_edicao(n, m, s, r, d);

	/* Paralelizar aqui
	ideia: jogar as matrizes e entradas para memoria compartilhada
	lançar threads de acordo com o numero de antidiagonais
	*/
	// Calcula distância de edição entre sequências s e r, por anti-diagonais
	int dist = distancia_edicao_adiagonal(n, m, s, r, d);


	printf("Distância=%d\n",dist);
	//printf("Tempo CPU = %.2fms\n", tempo);

	// Libera vetores s e r e matriz d
	libera(n, s, r, d);

	return 0;
}
// ----------------------------------------------------------------------------