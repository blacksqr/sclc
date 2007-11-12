// SLOC (NCLOC) = 46
// CLOC = 31
/* ---------------------------------------------------------------
 *  Serial pi Calculation - C Version
 *  FILE: ser_pi_calc.c
 *  DESCRIPTION:  pi calculation example program.  C Version.
 *    This program calculates pi using a "dartboard" algorithm.  See
 *    Fox et al.(1988) Solving Problems on Concurrent Processors, vol.1
 *    page 207.  All processes contribute to the calculation, with the
 *    master averaging the values for pi.
 *  AUTHOR: George Gusciora
 *  REVISED: 06/05/96 Blaise Barney
 * --------------------------------------------------------------- */
#include <stdlib.h>
#include <stdio.h>

void srandom (unsigned seed);
double dboard (int darts);

#define DARTS 5000   	/* number of throws at dartboard */
#define ROUNDS 10    	/* number of times "darts" is iterated */

main()
{
   double pi;           	/* average of pi after "darts" is thrown */
   double avepi;        	/* average pi value for all iterations */
   int i, n;

   srandom (5);
   avepi = 0;
   for (i = 0; i < ROUNDS; i++)
   {
      /* Perform pi calculation on serial processor */
      pi = dboard(DARTS);

      avepi = ((avepi * i) + pi)/(i + 1);
      printf("   After %3d throws, average value of pi = %10.8f\n",
                 (DARTS * (i + 1)),avepi);
   }
}
/*****************************************************************************
 * dboard
 *****************************************************************************/
#define sqr(x)	((x)*(x))
long random(void);

double dboard(int darts)
{
   double x_coord,       /* x coordinate, between -1 and 1  */
          y_coord,       /* y coordinate, between -1 and 1  */
          pi,            /* pi  */
          r;             /* random number between 0 and 1  */
   int score,            /* number of darts that hit circle */
       n;
   unsigned long cconst; /* used to convert integer random number */
                           /* between 0 and 2^31 to double random number */
                           /* between 0 and 1  */

     cconst = 2 << (31 - 1);
     score = 0;

/***********************************************************************
 *     Throw darts at board.  Done by generating random numbers
 *     between 0 and 1 and converting them to values for x and y
 *     coordinates and then testing to see if they "land" in
 *     the circle."  If so, score is incremented.  After throwing the
 *     specified number of darts, pi is calculated.  The computed value
 *     of pi is returned as the value of this function, dboard.
 *     Note:  the seed value for rand() is set in pi_calc.
 ************************************************************************/

   for (n = 1; n <= darts; n++)
   {
      /* generate random numbers for x and y coordinates */
      r = (double)random()/cconst;
      x_coord = (2.0 * r) - 1.0;
      r = (double)random()/cconst;
      y_coord = (2.0 * r) - 1.0;

      /* if dart lands in circle, increment score */
      if ((sqr(x_coord) + sqr(y_coord)) <= 1.0)
         score++;
   }

   /* calculate pi */
   pi = 4.0 * (double)score/(double)darts;
   return(pi);
}
