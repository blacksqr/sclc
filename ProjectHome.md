## Overview ##

SCLC (Source Code Line Counter) counts the size of different types of source code files, providing the number of comment, non-comment, blank, and total lines. In addition, a count of "tokens" is provided for organizations where code layout variability makes line-oriented size counts unreliable for analysis purposes.

The latest stable release of SCLC supports the following file types:

|Ada | Assembly | Awk  |
|:---|:---------|:-----|
| C  | C++      | Chapel |
| CSharp | CSS      | Eiffel |
| FORTRAN | HTML     | Java  |
| JavaScript | Jess     | JSP  |
| Lisp   | make     | Matlab |
|Pascal  | Perl     | PHP  |
| Python | shell    | SQL  |
| Tcl    | Template | XML  |
| ZPL |          |      |

## History ##

There are at least two flavors of SCLC in circulation.  The "original" SCLC was developed by Brad Appleton, and the home page for this flavor is at: http://www.cmcrossroads.com/bradapp/clearperl/sclc-cdiff.html.

This "University of Hawaii Edition" of SCLC, hosted here, has been developed in response to additional needs we had for SCLC, including support for XML output and high performance computing languages.

## Documentation ##

| [User Guide](http://code.google.com/p/sclc/wiki/UserGuide) | Provides installation instructions and development guidelines. |
|:-----------------------------------------------------------|:---------------------------------------------------------------|
| [SCLC PerlDoc](http://sclc.googlecode.com/svn/trunk/perldoc/sclc.html) | Standard Perl usage documentation                              |
| [SCLC Discussion Group](http://groups.google.com/group/sclc-discuss) | Mailing list for users and developers of SCLC.                 |

## Example Use and Output ##

Here, as an example, is the result of invoking SCLC on a recent SCLC distribution:

```
admin01:~/sclc-2.6.1116/$ perl src/sclc -recurse -default_exclude .
sclc: Can't determine programming language for ./.project
 Lines  Blank  Cmnts   NCSL TPtoks 
====== ====== ====== ====== ====== ============================================
    59      8      5     46    348 ./build.xml  (XML)
    28      0      6     22     70 ./lib/examples/AdventureWorks.sql  (SQL)
    61     10      5     46    348 ./lib/examples/build.xml  (XML)
    78      6     11     61    478 ./lib/examples/ConfirmProjectSettings.jsp  (JSP)
    18      9      3      6     70 ./lib/examples/functions.css  (CSS)
    32      0      0     32    298 ./lib/examples/hackyinstaller.xsd  (XML)
    16      1      4     11     30 ./lib/examples/HelloWorld.cs  (CSharp)
    51     13     14     29    194 ./lib/examples/jacobi.zh  (ZPL)
    80     11     29     52    175 ./lib/examples/JessActionTemplates.clp  (Jess)
     4      0      1      3      5 ./lib/examples/list.sh  (shell)
    36      4     13     19    165 ./lib/examples/markov.m  (Matlab)
    54      4     25     32    287 ./lib/examples/matrix_multiply.c  (C)
    56      9     18     29    228 ./lib/examples/matrix_multiply.f  (FORTRAN)
   311     28     52    231   1731 ./lib/examples/mpi_mandel_step4.c  (C)
   126     13     22     91    699 ./lib/examples/mpi_mm.f  (FORTRAN)
    77      8     22     55    448 ./lib/examples/omp_mm.c  (C)
    82     11     19     52    389 ./lib/examples/omp_mm.f  (FORTRAN)
    88     11     41     46    274 ./lib/examples/pi_calc.c  (C)
    99     18     46     35    211 ./lib/examples/pi_calc.f  (FORTRAN)
   138     14      7    117   1345 ./lib/examples/README.html  (HTML)
    83     13     17     53    292 ./lib/examples/sample.js  (JavaScript)
    28      7      5     16     82 ./lib/examples/sample.py  (Python)
  1955    164    722   1101   4375 ./lib/examples/sclc1.pl  (Perl)
    51     12     21     18    155 ./lib/examples/sensor-utils.el  (Lisp)
    54     11     22     21    124 ./lib/examples/socket.tcl  (Tcl)
    39      3      3     34    279 ./lib/examples/sort-array.p  (Pascal)
   168     26      6    136    877 ./lib/examples/T01_MpiConstructs.cc  (C++)
   443     80     28    335   2137 ./lib/examples/T02_Inner.java  (Java)
    25      3     11     11     34 ./lib/examples/temp2final.awk  (Awk)
   230     20     91    119    801 ./lib/examples/test.java  (Java)
    54      7     19     28    198 ./lib/examples/TestStack.java  (Java)
    92     27     19     52    316 ./lib/examples/thdruspi.ada  (Ada)
    56      9     38     29    196 ./lib/examples/theta_logistic.m  (Matlab)
    38      4      4     30    151 ./lib/examples/TryMe.e  (Eiffel)
   165     19      0    146   1353 ./README.html  (HTML)
  2830    232   1013   1666   8770 ./src/sclc  (Perl)
   284     36      4    244   2538 ./test.build.xml  (XML)
    38      4      4     30    151 ----- Eiffel -----  (1 file)
    92     27     19     52    316 ----- Ada -----  (1 file)
  4785    396   1735   2767  13145 ----- Perl -----  (2 files)
    18      9      3      6     70 ----- CSS -----  (1 file)
    51     13     14     29    194 ----- ZPL -----  (1 file)
   436     54     14    368   3532 ----- XML -----  (4 files)
    92     13     51     48    361 ----- Matlab -----  (2 files)
   530     51    140    364   2740 ----- C -----  (4 files)
     4      0      1      3      5 ----- shell -----  (1 file)
   727    107    138    482   3136 ----- Java -----  (3 files)
    83     13     17     53    292 ----- JavaScript -----  (1 file)
   303     33      7    263   2698 ----- HTML -----  (2 files)
    25      3     11     11     34 ----- Awk -----  (1 file)
    28      0      6     22     70 ----- SQL -----  (1 file)
   363     51    105    207   1527 ----- FORTRAN -----  (4 files)
    39      3      3     34    279 ----- Pascal -----  (1 file)
    54     11     22     21    124 ----- Tcl -----  (1 file)
    28      7      5     16     82 ----- Python -----  (1 file)
   168     26      6    136    877 ----- C++ -----  (1 file)
    78      6     11     61    478 ----- JSP -----  (1 file)
    80     11     29     52    175 ----- Jess -----  (1 file)
    16      1      4     11     30 ----- CSharp -----  (1 file)
    51     12     21     18    155 ----- Lisp -----  (1 file)
  8089    851   2366   5054  30471 ***** TOTAL *****  (37 files)
```
