# Generate-histogram-through-MPI-and-CUDA 
Generate histogram for a sequence with MPI and CUDA  
Inorder to run these code:  
1.copy these code to your Linux system  
2.inorder to compile MPI file, run "mpicc parallel_histogram.c -o parallel_histogram"(please make sure you already have "openmpi" in your system)  
3.inorder to compile CUDA file, run "nvcc CUDA_parallel_histogram.cu -o CUDA_parallel_histogram"(please make sure you already have "cuda 9.0"in your system and have an GPU in the computer you will use)  
4. use "mpirun xx1" to run mpi code, and use "./CUDA_parallel_histogram" to run cuda code.  

The result of my code is:  
1.show you all random number been generated in ascend order, and the class they been allocated in the histogram.  
2.how many numbers each class have in the histogram.  

still have some bugs in my code
