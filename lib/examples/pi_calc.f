C SLOC (NCLOC) = 35
C CLOC = 46
C ---------------------------------------------------------------
C  Serial pi Calculation - Fortran Version 
C  FILE: ser_pi_calc.f  
C  DESCRIPTION:  pi calculation example program.  Fortran Version.
C    This program calculates pi using a "dartboard" algorithm.  See
C    Fox et al.(1988) Solving Problems on Concurrent Processors, vol.1
C    page 207.  All processes contribute to the calculation, with the
C    master averaging the values for pi.
C  AUTHOR: Roslyn Leibensperger/  Rosanne Arnowitz (03/21/94 serial version) 
C  LAST REVISED: 11/25/95 Blaise Barney 
C
C --------------------------------------------------------------- 
C Explanation of constants and variables used in this program:
C   DARTS               = number of throws at dartboard
C   ROUNDS              = number of times "DARTS" is iterated
C   homepi              = value of pi calculated by current task
C   pisum               = sum of tasks' pi values
C   pi                  = average of pi for this iteration
C   avepi               = average pi value for all iterations
C   seednum             = seed number - based on mytid
C  ------------------------------------------------------------------------

	program pi_calc

	integer  DARTS, ROUNDS
	parameter(DARTS = 5000)
	parameter(ROUNDS = 10)
        real*4    seednum
        real*8    homepi, pi, avepi, pisum, dboard

	seednum = 5
   	call srand (seednum)

 	avepi = 0
	do 40 i = 1, ROUNDS
	  pi = dboard(DARTS)

C Calculates the average value of pi over all iterations */

          avepi = ((avepi*(i-1)) + pi)/ i  
          write(*,32) DARTS*i, avepi
 32       format('   After',i6,' throws, average value of pi = ',f10.8)

 40	continue

	end

C  ------------------------------------------------------------------------
C  dboard.f
C  see pi_send.f and pi_reduce.f
C  ------------------------------------------------------------------------
C Explanation of constants and variables used in this function:
C   darts       = number of throws at dartboard
C   score       = number of darts that hit circle
C   n           = index variable
C   r           = random number between 0 and 1
C   x_coord     = x coordinate, between -1 and 1
C   x_sqr       = square of x coordinate
C   y_coord     = y coordinate, between -1 and 1
C   y_sqr       = square of y coordinate
C   pi          = computed value of pi
C  ------------------------------------------------------------------------

      real*8    function dboard(darts)
      integer   darts, score, n
      real*4    r
      real*8    x_coord, x_sqr, y_coord, y_sqr, pi

      score = 0

C     Throw darts at board.  Done by generating random numbers
C     between 0 and 1 and converting them to values for x and y
C     coordinates and then testing to see if they "land" in
C     the circle."  If so, score is incremented.  After throwing the
C     specified number of darts, pi is calculated.  The computed value
C     of pi is returned as the value of this function, dboard.
C     Note:  the seed value for rand() is set in pi_calc.

      do 10 n = 1, darts
        r = rand()
        x_coord = (2.0 * r) - 1.0
        x_sqr = x_coord * x_coord

        r = rand()
        y_coord = (2.0 * r) - 1.0
        y_sqr = y_coord * y_coord

        if ((x_sqr + y_sqr) .le. 1.0) then
          score = score + 1
        endif

 10   continue

      pi = 4.0 * score / darts
      dboard = pi
      end

