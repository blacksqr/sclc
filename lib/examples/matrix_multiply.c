// SLOC (NCLOC) = 32
// CLOC = 18
/******************************************************************************
* Serial Matrix Multiply - C Version
* FILE: ser_mm.c
* DESCRIPTION:  Sequential version of a matrix multiply
*   To make this a parallel processing progam this program would be divided into
*   two parts - the master and the worker section.  The master task would
*   distributes a matrix multiply  operation to numtasks-1 worker tasks.
*   NOTE1:  C and Fortran versions of this code differ because of the way
*   arrays are stored/passed.  C arrays are row-major order but Fortran
*   arrays are column-major order.
* AUTHOR: George Gusciora
* LAST REVISED: 11/25/95 Blaise Barney
******************************************************************************/
#include <stdio.h>

#define NRA 62 			/* number of rows in matrix A */
#define NCA 15			/* number of columns in matrix A */
#define NCB 7   		/* number of columns in matrix B */
main()
{
int    i, j, k;			/* misc */
double a[NRA][NCA], 		/* matrix A to be multiplied */
       b[NCA][NCB],      	/* matrix B to be multiplied */
       c[NRA][NCB];		/* result matrix C */

   /* Initialize A, B, and C matrices */
   for (i=0; i<NRA; i++)
      for (j=0; j<NCA; j++)
         a[i][j]= i+j;
   for (i=0; i<NCA; i++)
      for (j=0; j<NCB; j++)
         b[i][j]= i*j;
   for(i=0;i<NRA;i++)
      for(j=0;j<NCB;j++)
         c[i][j] = 0.0;

   /* Perform matrix multiply */
   for(i=0;i<NRA;i++)
      for(j=0;j<NCB;j++)
         for(k=0;k<NCA;k++)
            c[i][j]+= a[i][k] * b[k][j];

   /* Okay, it's a trivial program */
   printf("Here is the result matrix\n");
   for (i=0; i<NRA; i++)
   {
      printf("\n");
      for (j=0; j<NCB; j++)
         printf("%6.2f   ", c[i][j]);
   }
   printf ("\n");
}
