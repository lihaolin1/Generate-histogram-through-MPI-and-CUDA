#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>
#include<mpi.h>

#define max_num 1000

int main(int argc, char* argv[])
{
	int i, j, k;
	int result[max_num];
	int result1[max_num];
	int num_num;
	int num_class;
	int *class_vector;
  int b;
	int name_len;
	int rank, size;
	int ime;
	int *num;
	int start = 0;
  int end = 0;
	int change_num;
 
  int class_per_node;
  int class_now; //
  int num_per_class; 
  
  int class_max_node;
  int last_class_max;
 
	struct timeval start_t, end_t;
	char processor_name[MPI_MAX_PROCESSOR_NAME];
	MPI_Status status;

	for (i = 0; i < max_num; i++)
	{
		result[i] = 0;
	}

	srand((unsigned int)time(NULL));
	
	MPI_Init(&argc, &argv);
	MPI_Barrier(MPI_COMM_WORLD);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	gethostname(processor_name, &name_len); //get the name of node
	if (size == 1) //increase the robust of my program
	{
		printf("How may numbers you want?\n");
		scanf("%d", &num_num);
    printf("How many classes you have?(should be smaller than numbers you have)\n");
		scanf("%d", &num_class);
		num = (int*)malloc(num_num * sizeof(int));
    class_vector = (int*)malloc((num_class) * sizeof(int));
    b = max_num/num_class;
		for (i = 0; i < num_num; i++)
		{
			num[i] = rand() % max_num;// + 1;
      result[num[i] - 1] += 1;
      class_vector[num[i]/b] += 1;
		}
    for (i = 0; i < max_num; i++)
		{
			if (result[i] != 0)
			{
        b = max_num/num_class;
				printf("Have %d numbers of %d in class %d; " ,result[i], i+1, (i+1)/b);
				if ((k + 1) % 2 == 0)
				{
					printf("\n");
				}
				k = k + 1;			
			}
		}
		printf("\nOther elements are all zeros.\n");
		for(i = 0; i < num_class; i++)
		{
			printf("In class %d, we have %d numbers\n", i, class_vector[i]);
		}
    printf("You just use one processor!\n");
		MPI_Finalize();
		return 0;
	}
	if (rank == 0)
	{
		printf("How many number you want?\n");
		scanf("%d", &num_num);
		printf("How many classes you have?(should be smaller than numbers you have)\n");
		scanf("%d", &num_class);
		num = (int*)malloc((num_num) * sizeof(int));
		class_vector = (int*)malloc((num_class) * sizeof(int));
		for (i = 0; i < num_num; i++)
		{
			num[i] = rand() % max_num + 1;
		}
		printf("Vector created success!\n");
    
		for(i = 0; i < num_class; i++)
		{
			class_vector[i] = 0; //initialize class_vector
		}	
		start = 0;
		change_num = num_num;
    class_max_node = 0;
      ///
    if(num_class >= size)
    {class_per_node = (num_class-class_max_node)/(size-rank);}////////////////
    else
    {class_per_node = (num_class-class_max_node)/(num_class-rank);}
      
    class_max_node += class_per_node;
		
    end = num_num;
    class_now = 0;
    
		gettimeofday(&start_t, NULL);
    b = max_num/num_class; 
    for(i = start; i < end; i++)
    {
       if(num[i]/b < class_max_node)
       {
         result[num[i]] += 1;
         class_vector[num[i]/b] += 1;
       }
       
    }
    
		MPI_Send(&start, 1, MPI_INT, 1, 99, MPI_COMM_WORLD);
    MPI_Send(&class_max_node, 1, MPI_INT, 1, 99, MPI_COMM_WORLD);
    MPI_Send(&num_class, 1,MPI_INT,1,99,MPI_COMM_WORLD);
		MPI_Send(&num_num, 1, MPI_INT, 1, 99, MPI_COMM_WORLD);
		MPI_Send(&change_num, 1, MPI_INT, 1, 99, MPI_COMM_WORLD);
		MPI_Send(&num[0], num_num, MPI_INT, 1, 99, MPI_COMM_WORLD);
    MPI_Send(&result[0], max_num, MPI_INT, 1, 99, MPI_COMM_WORLD);
    MPI_Send(&class_vector[0], num_class, MPI_INT,1,99,MPI_COMM_WORLD);
		
    i = size - 1;
		
		MPI_Recv(&start, 1, MPI_INT, i, 99, MPI_COMM_WORLD, &status);
    MPI_Recv(&class_now, 1, MPI_INT, i, 99, MPI_COMM_WORLD, &status);
    MPI_Recv(&num_class, 1, MPI_INT, i, 99, MPI_COMM_WORLD, &status);
		MPI_Recv(&num_num, 1, MPI_INT, i, 99, MPI_COMM_WORLD, &status);
		MPI_Recv(&change_num, 1, MPI_INT, i, 99, MPI_COMM_WORLD, &status);
		MPI_Recv(&num[0], num_num, MPI_INT, i, 99, MPI_COMM_WORLD, &status);
			
	  MPI_Recv(&result[0], max_num, MPI_INT, i, 99, MPI_COMM_WORLD, &status);
      
    MPI_Recv(&class_vector[0], num_class, MPI_INT, i, 99, MPI_COMM_WORLD, &status);
		
		
		gettimeofday(&end_t, NULL);
		k = 0;
		printf("The result is:\n");
		for (i = 0; i < max_num; i++)
		{
			if (result[i] != 0)
			{
        b = max_num/num_class;
				printf("Have %d numbers of %d in class %d; " ,result[i], i+1, (i+1)/b);
				if ((k + 1) % 2 == 0)
				{
					printf("\n");
				}
				k = k + 1;
				
			}
		}
		printf("\nOther elements are all zeros.\n");
		for(i = 0; i < num_class; i++)
		{
			printf("In class %d, we have %d numbers\n", i, class_vector[i]);
		}
		printf("Running time is: %d us\n", end_t.tv_usec - start_t.tv_usec);
	}
	if (rank >= 1)
	{
		MPI_Recv(&start, 1, MPI_INT, rank - 1, 99, MPI_COMM_WORLD, &status);
    MPI_Recv(&class_max_node, 1, MPI_INT, rank - 1, 99, MPI_COMM_WORLD, &status);
 	  MPI_Recv(&num_class, 1, MPI_INT, rank - 1, 99, MPI_COMM_WORLD, &status);
		MPI_Recv(&num_num, 1, MPI_INT, rank - 1, 99, MPI_COMM_WORLD, &status);
		MPI_Recv(&change_num, 1, MPI_INT, rank - 1, 99, MPI_COMM_WORLD, &status);

		num = (int*)malloc((num_num) * sizeof(int));
		MPI_Recv(&num[0], num_num, MPI_INT, rank - 1, 99, MPI_COMM_WORLD, &status);
    MPI_Recv(&result[0], max_num, MPI_INT, rank - 1, 99, MPI_COMM_WORLD, &status);
    class_vector = (int*)malloc((num_class)*sizeof(int));
		MPI_Recv(&class_vector[0], num_class, MPI_INT, rank - 1, 99, MPI_COMM_WORLD, &status);
    
		if (class_max_node < num_class)
		{
      if(num_class>= size)
      {class_per_node = (num_class-class_max_node)/(size-rank);}////////////////
      else
      {class_per_node = (num_class-class_max_node)/(num_class-rank);}
        ////
      end = num_num;
      last_class_max = class_max_node;
      class_max_node += class_per_node;
      
			for (i = start; i < end; i+=1)
			{
        b = max_num/num_class;
        
        if(num[i]/b < class_max_node && num[i]/b >= last_class_max)
        {
          result[num[i]] += 1;
          class_vector[num[i]/b] += 1;
        }
        
			}
			//printf("%d for loop is okay!\n", rank);
		}
	
    MPI_Send(&start, 1, MPI_INT, (rank + 1) % size, 99, MPI_COMM_WORLD);
    MPI_Send(&class_max_node, 1,MPI_INT,(rank + 1) % size, 99, MPI_COMM_WORLD);
    MPI_Send(&num_class, 1,MPI_INT,(rank + 1) % size, 99, MPI_COMM_WORLD);
		MPI_Send(&num_num, 1, MPI_INT, (rank + 1) % size, 99, MPI_COMM_WORLD);
		MPI_Send(&change_num, 1, MPI_INT, (rank + 1) % size, 99, MPI_COMM_WORLD);
		MPI_Send(&num[0], num_num, MPI_INT, (rank + 1) % size, 99, MPI_COMM_WORLD);
		MPI_Send(&result[0], max_num, MPI_INT, (rank + 1) % size, 99, MPI_COMM_WORLD);
    MPI_Send(&class_vector[0], num_class, MPI_INT,(rank + 1) % size,99,MPI_COMM_WORLD);
	}

	free(num);
  free(class_vector);
	MPI_Barrier(MPI_COMM_WORLD);
	MPI_Finalize();
	return 0;
}





