#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>

#define max_num 1000

__global__ void count(int* vector, int* result, int* class_vector,int n, int b)
{
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int stride = blockDim.x*gridDim.x;
	
	while(i < n)
	{
		atomicAdd(&result[vector[i]],1);

		atomicAdd(&class_vector[vector[i]/b],1);
		
		i += stride;
	}
	
}

int main(void)
{
	int i,b;
	int num_num;
	int num_class;
	int *vector_CPU;
	int *vector_GPU;
	int *result;
	int *final_result;
	int *class_vector;
	int *GPU_class_vector;
	cudaError_t err;
	struct timeval start,end;
	final_result = (int*)malloc(max_num*sizeof(int));
	for(i = 0; i < max_num; i++)
	{
		final_result[i] = 0;
	}
	
	printf("How many numbers you want to use?\n");
	scanf("%d",&num_num);
	printf("How many class you will use?\n");
	scanf("%d",&num_class);
	vector_CPU = (int*)malloc(num_num*sizeof(int));
	class_vector = (int*)malloc(num_class*sizeof(int));
	cudaMalloc((void**)&vector_GPU, num_num*sizeof(int));
	cudaMalloc((void**)&result, max_num*sizeof(int));
	cudaMalloc((void**)&GPU_class_vector, num_class*sizeof(int));
	srand((unsigned int)time(NULL));
	for(i = 0; i < num_num; i++) 	
	{
		vector_CPU[i] = rand()%max_num;
	}
	for(i = 0; i < num_class; i++)
	{
		class_vector[i] = 0;
	}

	gettimeofday(&start,NULL);
	
	err = cudaMemcpy(vector_GPU, vector_CPU, num_num*sizeof(int), cudaMemcpyHostToDevice);
	if(err != cudaSuccess)
	{printf("error1, code: %d, error: %s\n", err, cudaGetErrorString(err));}
	
	err = cudaMemcpy(GPU_class_vector, class_vector, num_class*sizeof(int), cudaMemcpyHostToDevice);
	if(err != cudaSuccess)
	{printf("error1.5, code %d, error: %s\n", err, cudaGetErrorString(err));}
	
	int threadsPerBlock = 256;
	int blocksPerGrid = (num_num + threadsPerBlock - 1)/threadsPerBlock;
	int share_size = (max_num+num_class)*sizeof(int);
	b = max_num / num_class;
	
	count<<<blocksPerGrid,threadsPerBlock,share_size>>>(vector_GPU, result, GPU_class_vector, num_num, b);
	err = cudaGetLastError();
	if(err != cudaSuccess)
	{printf("GPU failed to process!\n");}
		
	err = cudaMemcpy(final_result, result, max_num*sizeof(int), cudaMemcpyDeviceToHost);
	if(err != cudaSuccess)
	{printf("error2, code: %d, error: %s\n", err, cudaGetErrorString(err));}
	
	err = cudaMemcpy(class_vector, GPU_class_vector, num_class*sizeof(int),cudaMemcpyDeviceToHost);
	if(err != cudaSuccess)
	{printf("error3, code: %d, error: %s\n", err, cudaGetErrorString(err));}
	
	gettimeofday(&end,NULL);
	int k = 0;
	for(i = 0; i < max_num; i++)
	{
		if(final_result[i] != 0)
		{
			printf("Have %d number %d in class %d; ", final_result[i],i+1, (i+1)/b);
			k = k + 1;
			if(k == 2)
			{
				printf("\n");
				k = 0;
			}
		}
	}
	if(k < 4)
	{printf("\n");}
	k = 0;
	for(i = 0 ; i < num_class; i++)
	{
		printf("class %d have %d numbers; ", i+1, class_vector[i]);
		k = k + 1;
		if(k == 2);
		{printf("\n");
		k = 0;}
	}
	if(k!= 2)
	{printf("\n");}
	printf("Time is: %d us\n", end.tv_usec - start.tv_usec);
	cudaFree(vector_GPU);
	cudaFree(result);
	cudaFree(GPU_class_vector);
	free(vector_CPU);
	free(final_result);
	free(class_vector);
	return 0;
}
