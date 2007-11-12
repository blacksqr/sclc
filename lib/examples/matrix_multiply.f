C SLOC (NCLOC) = 29
C CLOC = 18
C******************************************************************************
C SERIAL MATRIX MULTIPLY - Fortran Version
C FILE: ser_mm.f
C DESCRIPTION: This is the serial version of the matrix multiply example.
C   To make this a parallel processing progam this program would be divided into
C   two parts - the master and the worker section.  The master task would 
C   distributes a matrix multiply  operation to numtasks-1 worker tasks.
C   NOTE1:  C and Fortran versions of this code differ because of the way
C   arrays are stored/passed.  C arrays are row-major order but Fortran
C   arrays are column-major order.
C AUTHOR: Ros Leibensperger / Blaise Barney / Rosanne Arnowitz 
C LAST REVISED:  11/25/95 Blaise Barney 
C******************************************************************************

      program mm

      parameter (NRA = 62)
      parameter (NCA = 15)
      parameter (NCB = 7)

      integer 	cols,avecol,i,j,k
      real*8	a(NRA,NCA), b(NCA,NCB), c(NRA,NCB)


C     Initialize A and B 
      do 30 i=1, NRA
        do 30 j=1, NCA
        a(i,j) = (i-1)+(j-1)
 30   continue
      do 40 i=1, NCA
        do 40 j=1, NCB
	b(i,j) = (i-1)*(j-1)
 40   continue

C     Do matrix multiply
       do 50 k=1, NCB 
         do 50 i=1, NRA
         c(i,k) = 0.0
           do 50 j=1, NCA
           c(i,k) = c(i,k) + a(i,j) * b(j,k)
  50       continue

C     Print results 
       print*, '"Here is the result matrix: '	
       do 90 i=1, NRA
         do 80 j = 1, NCB
         write(*,70)c(i,j)
  70     format(2x,f8.2,$)
  80     continue
       print *, ' '
  90   continue


      end
