#include <stdio.h>
#include <string.h>
#include <mpi.h>

int main(int argc, char** argv) {

int my_rank, p, source, dest, tag = 0;
char message [100];
MPI_Status status;
MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
MPI_Comm_size(MPI_COMM_WORLD, &p);

if (my_rank != 0) {
	sprintf (message, "Greetings from process %d!", my_rank);
	dest = 0;
	MPI_Send(message, strlen(message ) + 1, MPI_CHAR, dest, tag, MPI_COMM_WORLD);
}
else 
{
	for ( source = 1; source < p; source++) 
	{
	MPI_Recv(message, 100, MPI_CHAR, source, tag, MPI_COMM_WORLD, &status );
	printf ("%s \n", message );
	}
}

MPI_Finalize ( );
	return 0;
}

/*
Save the following code as hello.c on /mirror/mpiu

3. Compile and link the code using MPICH2 C compiler mpicc10.
4. To run code in parallel mode, host and number of processors has to provided. 

We will be running the code on all the three compute nodes using 10 processors -

$ mpiexec -np 10 -host Node1,Node2,Node3 ./hello

*/