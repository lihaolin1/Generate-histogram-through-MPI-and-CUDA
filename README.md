# Generate-histogram-through-MPI-and-CUDA 
Generate histogram for a sequence with MPI and CUDA  
Inorder to run these code:  
1.copy these code to your Linux system  
2.inorder to compile MPI file, run "mpicc xx1.c -o xx1"(please make sure you already have "openmpi" in your system)  
3.inorder to compile CUDA file, run "nvcc xx2.cu -o xx2"(please make sure you already have "cuda 9.0"in your system and have an GPU in your computer)  
4. use "mpirun xx1" to run mpi code, and use "./xx2" to run cuda code.  

The result of my code is:  
1.shown you all random number been generated in ascend order, and the class they been allocated in the histogram.  
2.how many numbers eacch class have in the histogram.  

still have some bugs in my code
