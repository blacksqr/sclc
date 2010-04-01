/**
 * Hello world MPI program
 *
 **/
 
#include <mpi.h>
#include <stdio.h>

 /* MPI_AAA */

int main(int argc, char* argv[]) {
    int rank, size;
    
    MPI_Init(&argc, &argv);

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    printf("Hello from %d of %d\n", rank, size);
    
    
    /* If there are more than one of us, rank 0 sends to rank 1 */
    if(size>1) {
        int message = -1;
        switch(rank) {
            case 0:
                message = 0;
                MPI_Send(&message,1,MPI_INT,1,0,MPI_COMM_WORLD);
                
                break;
            case 1:
                MPI_Recv(&message,1,MPI_INT,0,0,MPI_COMM_WORLD);
                break;
            default:
                /* no-op */
        }
    }
    MPI_Finalize();
    return 0;
}
 
 