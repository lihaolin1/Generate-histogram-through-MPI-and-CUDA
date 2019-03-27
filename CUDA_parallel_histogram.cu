#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>

#define max_num 1000 //the maximum number the program can randomly generte

__global__ void count(int* vector, int* result, int* class_vector,int n, int b) //cuda kernal function
{
	int i = threadIdx.x + blockDim.x * blockIdx.x;
	int stride = blockDim.x*gridDim.x;
	
	while(i < n)
	{
		atomicAdd(&result[vector[i]],1); //this is the atomic add, it is very important in histogram generating when we using cuda 

		atomicAdd(&class_vector[vector[i]/b],1);// result is used to save the number we have, class_vector is used to save how many number in each class
		
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
	vector_CPU = (int*)malloc(num_num*sizeof(int)); //used to save the randomly generated value
	class_vector = (int*)malloc(num_class*sizeof(int)); //used to save how many numbers in eacch class
	cudaMalloc((void**)&vector_GPU, num_num*sizeof(int)); // assign memory to the vector which will be used in GPU
	cudaMalloc((void**)&result, max_num*sizeof(int));
	cudaMalloc((void**)&GPU_class_vector, num_class*sizeof(int));
	srand((unsigned int)time(NULL)); // used to generate randm number
	for(i = 0; i < num_num; i++) 	
	{
		vector_CPU[i] = rand()%max_num; //generate random number
	}
	for(i = 0; i < num_class; i++)
	{
		class_vector[i] = 0; //initial vector
	}

	gettimeofday(&start,NULL); //save time
	
	err = cudaMemcpy(vector_GPU, vector_CPU, num_num*sizeof(int), cudaMemcpyHostToDevice);
	if(err != cudaSuccess) //check whether our memory allocation is correct
	{printf("error1, code: %d, error: %s\n", err, cudaGetErrorString(err));}
	
	err = cudaMemcpy(GPU_class_vector, class_vector, num_class*sizeof(int), cudaMemcpyHostToDevice);
	if(err != cudaSuccess)
	{printf("error1.5, code %d, error: %s\n", err, cudaGetErrorString(err));}
	
	int threadsPerBlock = 256; //number of threads in each block
	int blocksPerGrid = (num_num + threadsPerBlock - 1)/threadsPerBlock; //number of blocks per grid
	int share_size = (max_num+num_class)*sizeof(int); //we don't need it, you can delete this sentence
	b = max_num / num_class; //this means how many numbers will assgn in each class
	
	count<<<blocksPerGrid,threadsPerBlock,share_size>>>(vector_GPU, result, GPU_class_vector, num_num, b);
	err = cudaGetLastError();
	if(err != cudaSuccess) //check whether the kernal function runs right or not
	{printf("GPU failed to process!\n");}
		
	err = cudaMemcpy(final_result, result, max_num*sizeof(int), cudaMemcpyDeviceToHost); //copy vector back
	if(err != cudaSuccess)
	{printf("error2, code: %d, error: %s\n", err, cudaGetErrorString(err));}
	
	err = cudaMemcpy(class_vector, GPU_class_vector, num_class*sizeof(int),cudaMemcpyDeviceToHost);
	if(err != cudaSuccess)
	{printf("error3, code: %d, error: %s\n", err, cudaGetErrorString(err));}
	
	gettimeofday(&end,NULL);
	int k = 0;
	//print all the information
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
	//free the memory, never forget this step
	cudaFree(vector_GPU);
	cudaFree(result);
	cudaFree(GPU_class_vector);
	free(vector_CPU);
	free(final_result);
	free(class_vector);
	return 0;
}
