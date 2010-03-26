int main (int argc, char const *argv[])
{
        MPI_Init(&argc, &argv);
        /*
         MPI_Init(&argc, &argv);
        */
        MPI_Finalize();
        return 0;
}