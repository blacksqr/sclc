/**
 * Parallel implementation of the Mandelbrot 2D set using
 * hybrid simple space partitioning with MPI and OpenMP. 
 * <p>
 * This program requires six command line arguments:
 * <ol>
 * <li>xmin - the minimum x value</li>
 * <li>xmax - the maximum x value</li>
 * <li>yMin - the minimum y value</li>
 * <li>yMax - the maximum y value</li>
 * <li>imageHeight - the height of the image</li>
 * <li>fileName - the name of the file to output</li>
 * </ol>
 * 
 * @author Mike Paulding
 * @version 1.0 31-Oct-2005
 */

#define MASTER 0
#define FROM_MASTER 0
#define FROM_WORKER 1

#define NUM_ITER  5000
#define MAX_VALUE 3000

#include "mpi.h"

#include <math.h>
#include <omp.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

double walltime(double* t0);

/*
 * Computes the Mandelbrot binary value by determining whether an
 * (x,y) coordinate is in the set.  The constant max value chosen 
 * below is somewhat arbitrary and may be overkill, but let's keep it as is 
 * for the purpose of this exercise.
 * 
 * @author Henri Casanova
 * @param x The x coordinate value.
 * @param y The y coordinate value.
 * @return Zero or one as a character depending on whether (x,y) is in the set.
 */
char computeMandel(double x, double y) {
  int i;
  double zr = x, zi = y;
  double newzr, newzi;

  for (i = 0; i < NUM_ITER; i++) {
    newzr = zr * zr - zi * zi + x;
    newzi = 2 * zr * zi + y;
    if ((fabs(newzr - zr) > MAX_VALUE) || (fabs(newzi - zi) > MAX_VALUE))
      return (char) 0;
    zr = newzr;
    zi = newzi;
  }
  return (char) 1;
}

/**
 * Generates a PBM (Portable Bit Map) file for the corresponding 
 * black and white image for a 2-D Mandlebrot set.
 * 
 * @author Henri Casanova
 * @param pbmFile The PBM file to be created.
 * @param matrix The matrix of binary values from which the file is created.
 * @param rows The number of rows in the matrix (the height of the image).
 * @param cols The number of columns in the matrix (the width of the image).
 */
void generatePbmFile(FILE* pbmFile, char *matrix, int rows, int cols) 
{
  int i;
  int colLength = cols + 8;
  fprintf(pbmFile, "P4\n");
  fprintf(pbmFile, "%d %d\n", cols, rows);  
  for (i = rows - 1; i >= 0; i--) 
  {
    int index = 0;
    while(index < cols) {
      char buffer[9];
      char value;
      char *s;
      long r=0;
      sprintf(buffer,"%d%d%d%d%d%d%d%d",
        matrix[i * colLength + index], matrix[i * colLength + index + 1],
        matrix[i * colLength + index + 2], matrix[i * colLength + index + 3],
        matrix[i * colLength + index + 4], matrix[i * colLength + index + 5],
        matrix[i * colLength + index + 6], matrix[i * colLength + index + 7]);
      s = buffer;
      for (; *s; r = (r<<1) | (*s++ - '0'));
      value = (char) r;
      fwrite(&value, 1, sizeof(char), pbmFile);
      index += 8; 
    }
  }
  return;
}

/**
 * Driver that executes the parallel implementation for computing
 * a 2-D Mandlebrot set.
 * 
 * @author Mike Paulding
 * @param argc The number of arguments specified on the command line.
 * @param argv The collection of arguments specified on the command line.
 */
int main(int argc, char* argv[]) {
  int mpiReturnCode, numTasks, numWorkers, taskId;
  int taskIndex, rowIndex, endRow, row, col;
  int imgHeight, imgWidth;
  int totalRows, totalCols, stripRows, stripCols;
  int chunkSize, numThreads;
  int stripBoundaries[2];
  double xMin, xMax, xRange;
  double yMin, yMax, yRange;
  double displacement, xVal, yVal;
  
  mpiReturnCode = MPI_Init(&argc, &argv);
  mpiReturnCode |= MPI_Comm_size(MPI_COMM_WORLD, &numTasks);
  mpiReturnCode |= MPI_Comm_rank(MPI_COMM_WORLD, &taskId);
  numWorkers = numTasks - 1;
  
  if (mpiReturnCode != MPI_SUCCESS) {
    printf("Error initializing MPI and obtaining task ID information.\n");
    MPI_Abort(MPI_COMM_WORLD, mpiReturnCode);
  }

  if (argc != 9) {
    printf("Mandelbrot program requires exactly 8 arguments in the following order:\n");
    printf("\txmin, xmax, ymin, ymax, image height, image file name, chunk size, number of threads\n");
    return -1;
  }

  xMin = strtod(argv[1], NULL);
  xMax = strtod(argv[2], NULL);
  xRange = xMax - xMin;
  if (xRange <= 0) {
    printf("The xmin value must be less than xmax.\n");
    return -1;
  }

  yMin = strtod(argv[3], NULL);
  yMax = strtod(argv[4], NULL);
  yRange = yMax - yMin;
  if (yRange <= 0) {
    printf("The ymin value must be less than ymax.\n");
    return -1;
  }

  imgHeight = atoi(argv[5]);
  if (imgHeight < numTasks) {
    printf("The image height must be a positive integer value greater than the number of tasks.\n");
    return -1;
  }
  
  chunkSize = atoi(argv[7]);
  if (chunkSize < 0 || chunkSize > imgHeight) {
    printf("The chunk size must be a positive integer less than the image height (%d).\n", imgHeight);
    return -1;
  }
  
  numThreads = atoi(argv[8]);
  if (numThreads > omp_get_max_threads()) {
    printf("The number of threads must be less than the maximum of %d.\n", omp_get_max_threads());
    return -1;
  }
  omp_set_num_threads(numThreads);
  
  displacement = yRange / imgHeight;
  imgWidth = (int) (xRange / displacement);
  totalRows = imgHeight;
  totalCols = imgWidth + 8;
  stripRows = chunkSize;
  stripCols = totalCols;

  if (taskId == MASTER) {
    int doneDistributing = 0, lastTaskId = 0;
    double clockZero = 0.0, startTime, elapsedTime;

    // Rows of the 2D array correspond to the image height (y-direction),
    // whereas cols of the array correspond to the image width (x-direction)
    char* mandelSet = (char*) calloc(totalRows * totalCols, sizeof(char));
    
    MPI_Request* sendRequests = (MPI_Request*) calloc(numWorkers, sizeof(MPI_Request));
    MPI_Request* recvRequests = (MPI_Request*) calloc(numWorkers, sizeof(MPI_Request));
    MPI_Status*  recvStatuses = (MPI_Status*) calloc(numWorkers, sizeof(MPI_Status));
    FILE* pbmFile;
    
    rowIndex = 0;
    startTime = walltime(&clockZero);
    for (taskIndex = 1; taskIndex < numTasks; taskIndex++) {
      if (rowIndex < totalRows) {
        stripBoundaries[0] = rowIndex;
        endRow = (rowIndex + stripRows < totalRows) 
          ? rowIndex + stripRows : totalRows;
        stripBoundaries[1] = endRow;
        MPI_Isend(stripBoundaries, 2, MPI_INT, taskIndex, FROM_MASTER, MPI_COMM_WORLD, &sendRequests[taskIndex - 1]);
        MPI_Irecv(mandelSet + rowIndex * stripCols, (endRow - rowIndex) * stripCols, MPI_CHAR, 
          taskIndex, FROM_WORKER, MPI_COMM_WORLD, &recvRequests[taskIndex - 1]);
        lastTaskId = taskIndex;
        rowIndex = endRow;
        if (rowIndex >= totalRows) {
          doneDistributing = 1;
        }
      }
    }
    
    while (!doneDistributing) {
      // Do some computation to mask the communication latency
      // Give master a fraction of the strip the workers are given (gets off easy:-)
      endRow = (rowIndex + (int) (stripRows / 16) < totalRows) 
        ? rowIndex + (int) (stripRows / 16) : totalRows;
      #pragma omp parallel default(none) \
        shared(mandelSet, rowIndex, stripCols, endRow, totalCols, displacement, xMin, yMin, numTasks) \
        private(row, col, xVal, yVal)
      {
        #pragma omp for schedule(static, 16)
        for (row = rowIndex; row < endRow; row++) {
          yVal = row * displacement + yMin;
          for (col = 0; col < stripCols; col++) {
            xVal = col * displacement + xMin;
            mandelSet[row * totalCols + col] = computeMandel(xVal, yVal);
          }
        }
      }
      rowIndex = endRow;
      if (rowIndex >= totalRows) {
        doneDistributing = 1;
      }
      // Now check status of workers and reassign work if ready
      for (taskIndex = 1; taskIndex <= lastTaskId; taskIndex++) {
        int recvDone = 0;
        MPI_Test(&recvRequests[taskIndex - 1], &recvDone, MPI_STATUS_IGNORE);
        if (recvDone == 1) {
          if (rowIndex >= totalRows) {
            doneDistributing = 1;
          }
          else {
            stripBoundaries[0] = rowIndex;
            endRow = (rowIndex + stripRows < totalRows) 
              ? rowIndex + stripRows : totalRows;
            stripBoundaries[1] = endRow;
            MPI_Isend(stripBoundaries, 2, MPI_INT, taskIndex, FROM_MASTER, MPI_COMM_WORLD, &sendRequests[taskIndex - 1]);
            MPI_Irecv(mandelSet + rowIndex * stripCols, (endRow - rowIndex) * stripCols, MPI_CHAR, 
              taskIndex, FROM_WORKER, MPI_COMM_WORLD, &recvRequests[taskIndex - 1]);
            rowIndex = endRow;
          }
        }
      }
    }
    MPI_Waitall(numWorkers, recvRequests, recvStatuses);
    elapsedTime = walltime(&startTime);
    
    for (taskIndex = 1; taskIndex <= lastTaskId; taskIndex++) {
      stripBoundaries[0] = -1;
      stripBoundaries[1] = -1;
      MPI_Isend(stripBoundaries, 2, MPI_INT, taskIndex, FROM_MASTER, 
        MPI_COMM_WORLD, &sendRequests[taskIndex - 1]);
    }
    pbmFile = fopen(argv[6], "w");
    generatePbmFile(pbmFile, mandelSet, imgHeight, imgWidth);
    fclose(pbmFile);
    free(mandelSet);
    free(recvRequests);
    free(recvStatuses);
    free(sendRequests);
    printf("\nTotal computation wall time = %.2fs\n", elapsedTime);
  }
  // Workers receive work, compute and send their strip back to master.
  else {
    char* strip;
    int doneComputing = 0;
    MPI_Status status;
    
    while (!doneComputing) {
      MPI_Recv(stripBoundaries, 2, MPI_INT, MASTER, FROM_MASTER, MPI_COMM_WORLD, &status);
      rowIndex = stripBoundaries[0];
      endRow = stripBoundaries[1];
      if (rowIndex >= 0 && endRow > rowIndex) {
        stripRows = endRow - rowIndex;
        strip = (char*) calloc(stripRows * stripCols, sizeof(char));      
        #pragma omp parallel default(none) \
          shared(strip, stripRows, stripCols, rowIndex, displacement, xMin, yMin) \
          private(row, col, xVal, yVal)
        {
          #pragma omp for schedule(static, 16)
          for (row = 0; row < stripRows; row++) {
            yVal = (row + rowIndex) * displacement + yMin;
            for (col = 0; col < stripCols; col++) {
              xVal = col * displacement + xMin;
              strip[row * stripCols + col] = computeMandel(xVal, yVal);
            }
          }
        }
        MPI_Send(strip, stripRows * stripCols, MPI_CHAR, MASTER, FROM_WORKER, MPI_COMM_WORLD);
        free(strip);
      }
      else {
        doneComputing = 1;
      }
    }
  }

  MPI_Finalize();
  
  return 0;
}

