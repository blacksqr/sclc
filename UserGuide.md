# 1.0 Introduction #

Source Code Line Counter (SCLC) counts the size of different types of source code files, providing the number of comment, non-comment, blank, and total lines. In addition, a count of "tokens" is provided for organizations where code layout variability makes line-oriented size counts unreliable for analysis purposes. The latest stable release of SCLC supports the following 27 file types: Ada, Assembly, Awk, C, C++, Chapel, CSharp, CSS, Eiffel, FORTRAN, HTML, Java, JavaScript, Jess, JSP, Lisp, make, Matlab, Pascal, Perl, Python, shell, SQL, Tcl, Template, XML, ZPL.

There are at least two flavors of SCLC in circulation.  The "original" SCLC was developed by Brad Appleton, and the home page for this flavor is at: http://www.cmcrossroads.com/bradapp/clearperl/sclc-cdiff.html.

Our "University of Hawaii Edition" of SCLC was developed in response to some additional needs we had for SCLC, including support for XML output and high performance computing languages.  The home page for the University of Hawaii Edition is: http://code.google.com/p/sclc/.

# 2.0 Installation #

SCLC requires Perl 5.8 and the XML::Simple module. To run the unit tests, the Test::Unit::Lite module is also required.  Both can be downloaded from [CPAN](http://www.cpan.org).

Perl source and binaries can be obtained from http://www.perl.com/download.csp. For a "ready to install" version of Perl try [ActivePerl](http://www.activestate.com/Products/activeperl/?_x=1) from ActiveState. It supports all platforms, has XML:Simple pre-installed, and is a free download.

If you are planning to use the supplied build.xml to run the demo you will need to install [Apache Ant](http://ant.apache.org/). Ant is not required to run the script by itself. Some additional tests require the [AntUnit](http://ant.apache.org/antlibs/antunit/) library, which is an add-on for ant.

## 2.1 Running SCLC on itself ##

The quickest way to check your installation of SCLC is to invoke it on itself. To do this, cd to the src/ directory, and invoke "perl sclc sclc".  Here is some example output:

```
C:\svn-csdl\sclc\src>perl sclc sclc
 Lines  Blank  Cmnts   NCSL TPtoks
====== ====== ====== ====== ====== ============================================
  2513    213    959   1418   7740 sclc  (Perl)
```

Note that the actual numbers you get for the size of SCLC may differ depending upon the version of SCLC you are using.

## 2.2 Running the SCLC validation suite ##

SCLC comes with a validation test suite that ensures that the various language processors are counting code correctly. To run the tests, install Ant, then invoke "ant -f test.build.xml".  The Ant build will fail if any of the tests do not pass.  Here is an example of a successful run of the test suite:

```
C:\svnCSDL\sclc>ant -f test.build.xml
Buildfile: test.build.xml

test.teststack.java:
     [exec]  Lines  Blank  Cmnts   NCSL TPtoks
     [exec] ====== ====== ====== ====== ====== ============================================
     [exec]     54      7     19     28    198 C:\svnCSDL\sclc\lib\examples/TestStack.java  (Java)

test.pi_calc.c:
     [exec]  Lines  Blank  Cmnts   NCSL TPtoks
     [exec] ====== ====== ====== ====== ====== ============================================
     [exec]     88     11     41     46    274 C:\svnCSDL\sclc\lib\examples/pi_calc.c  (C)

test.pi_calc.f:
     [exec]  Lines  Blank  Cmnts   NCSL TPtoks
     [exec] ====== ====== ====== ====== ====== ============================================
     [exec]     99     18     46     35    209 C:\svnCSDL\sclc\lib\examples/pi_calc.f  (FORTRAN)

test.markov.m:
     [exec]  Lines  Blank  Cmnts   NCSL TPtoks
     [exec] ====== ====== ====== ====== ====== ============================================
     [exec]     36      4     13     19    165 C:\svnCSDL\sclc\lib\examples/markov.m  (Matlab)

<Some tests not shown to reduce output>

test.sclc1.pl:
     [exec]  Lines  Blank  Cmnts   NCSL TPtoks
     [exec] ====== ====== ====== ====== ====== ============================================
     [exec]   1955    164    722   1101   4374 C:\svnCSDL\sclc\lib\examples/sclc1.pl  (Perl)

test.build.xml:
     [exec]  Lines  Blank  Cmnts   NCSL TPtoks
     [exec] ====== ====== ====== ====== ====== ============================================
     [exec]     61     10      0     51    422 C:\svnCSDL\sclc\lib\examples/build.xml  (XML)

test.README.html:
     [exec]  Lines  Blank  Cmnts   NCSL TPtoks
     [exec] ====== ====== ====== ====== ====== ============================================
     [exec]    135     14      0    121   1395 C:\svnCSDL\sclc\lib\examples/README.html  (HTML)

test.ConfirmProjectSettings.jsp:
     [exec]  Lines  Blank  Cmnts   NCSL TPtoks
     [exec] ====== ====== ====== ====== ====== ============================================
     [exec]     75      6      0     69    531 C:\svnCSDL\sclc\lib\examples/ConfirmProjectSettings.jsp  (JSP)

all.test:

BUILD SUCCESSFUL
Total time: 10 seconds
```

It is quite easy to extend the test suite to handle tests for new languages.  To write the test, create a test file in the language of choice, then manually count the number of lines, comments, tokens, and whatever else is important to check in the output.  Then write an Ant target using the supplied 

&lt;runTest&gt;

 and 

&lt;assertContains&gt;

 macros to invoke SCLC on your file and check the output for the required data.  Here's an example test for a sample Fortran file:

```
  <target name="test.pi_calc.f">
    <runTest property.name="pi_calc.f.data" test.file="${testfile.dir}/pi_calc.f" />
    <assertContains  assert.num="1" property.name="pi_calc.f.data" property.string="sourceLines=&quot;35&quot;" />
    <assertContains  assert.num="2" property.name="pi_calc.f.data" property.string="commentLines=&quot;46&quot;" />
  </target>
```

See SclcTesting for more details.

# 3.0 Usage #

To see the complete list of options available for SCLC please run "perldoc sclc". The output will contain all the options available, their descriptions, and some examples of the more advanced features.