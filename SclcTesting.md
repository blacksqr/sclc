# Introduction #

When adding code to sclc, you should also add test code to make sure that your changes are correct. There are three different kinds of automated tests you can define:
  * XML-based acceptance tests
  * non-XML-based acceptance tests
  * Unit tests

You can run all of the different tests by doing:

```
ant alltest
```


# XML-based acceptance tests #

XML-based acceptance tests can be invoked using ant by doing:
```
ant test
```


This version of sclc is mainly used as an input to [Hackystat](http://code.google.com/p/hackystat/), and since Hackystat only uses the XML output of sclc, testing is mostly focused on the XML output.

The source file inputs for the XML tests are in [lib/examples](http://code.google.com/p/sclc/source/browse/trunk/lib/examples). The expected outputs are in [sclc/test.build.xml](http://code.google.com/p/sclc/source/browse/trunk/test.build.xml). This uses the Ant infrastructure to parse the XML outptu and check if the fields match expected values

As an example, the file [lib/examples/rank\_change.php](http://code.google.com/p/sclc/source/browse/trunk/lib/examples/rank_change.php) should be classified as a PHP file of size 14 NCLC (source lines).

The following XML fragments from  [test.build.xml](http://code.google.com/p/sclc/source/browse/trunk/test.build.xml) show how the test is specified. We specify a target called _test.rank\_change.php_ that will parse the XML output of sclc, and check for sourceLines="14" and fileType="PHP":

```
  <target name="test.rank_change.php">
    <runTest property.name="rank_change.php.data" test.file="${testfile.dir}/rank_change.php" />
    <assertContains assert.num="1" property.name="rank_change.php.data" property.string="sourceLines=&quot;14&quot;" />
    <assertContains assert.num="2" property.name="rank_change.php.data" property.string="fileType=&quot;PHP&quot;" />
  </target>
```


We must also specify that the _test.rank\_change.php_ target is a dependency of the _all.test_ target:

```
  <target name="all.test" depends="init, 
    test.mpi-comment.c, test.mpi-one-line-comment.cpp, test.cplusplus-with-c-extension.c,
    test.c-one-liner.c, test.c-one-liner-with-comments.c,
    test.rank_change.php, test.teststack.java, test.pi_calc.c, test.pi_calc.f, test.matrix_multiply.f, 
    test.matrix_multiply.c, test.markov.m, test.theta_logistic.m, test.T02_Inner.java, test.mpi_mm.f, test.omp_mm.f,
    test.omp_mm.c, test.T01_MpiConstructs.cc, test.sclc1.pl, test.hello-mpi.c, test.mpi_mandel_step4.c, test.jacobi.zh, test.socket.tcl,
    test.sort-array.p, test.temp2final.awk, test.thdruspi.ada, test.sensor-utils.el, test.TryMe.e, test.build.xml,
    test.README.html, test.ConfirmProjectSettings.jsp, test.list.sh, test.AdventureWorks.sql, test.JessActionTemplates.clp,
    test.sample.py, test.HelloWorld.cs, test.hackyinstaller.xsd, test.functions.css, test.sample.js">
  </target>
```
# Non-XML-based acceptance tests #

Non-XML-based acceptance tests can be invoked using ant by doing

```
ant funtest
```

You must have the [AntUnit library](http://ant.apache.org/antlibs/antunit/) installed on your system to run these tests.

More recently, some test infrastructure has been added to check non-XML output, such as the sclc standard output, or output in TM3 format. These files live in the [t/ant](http://code.google.com/p/sclc/source/browse/trunk/t/ant) directory.

As an example, whe we run sclc on [lib/examples/hello.c](http://code.google.com/p/sclc/source/browse/trunk/lib/examples/hello.c), here's what we expect the output to look like:
```
 Lines  Blank  Cmnts   NCSL TPtoks 
====== ====== ====== ====== ====== ============================================
    13      4      3      6     31 lib/examples/hello.c  (C)
```

So we place a file in the _t/ant/expected\_output_ directory called _hello.c.out_ that contains this text.

Next, we create a file in the  _t/ant_ directory called _hello.xml_. This file uses [AntUnit](http://ant.apache.org/antlibs/antunit/) to describe the test,  including the input file, expected output, and actual output. It contains an assertion that the expected and actual output files are equal.

```
<project xmlns:au="antlib:org.apache.ant.antunit">
   <property name="testfile.relpath" value="lib/examples"/>    
   <property name="actualoutput.dir" location="${basedir}/actual-output" />
   <property name="expectedoutput.dir" location="${basedir}/expected-output" />
   <property name="outfile" value="hello.c.out" />
   
   <target name="setUp">
      <mkdir dir="${actualoutput.dir}" />
      <delete file="${actualoutput.dir}/${outfile}" />
   </target>
   
   <target name="test-hello.c-output">
        <exec executable="perl" 
              output="${actualoutput.dir}/${outfile}"
              dir="${sclcbase.dir}"> 
         <arg value="${src.dir}/sclc" />
         <arg value="${testfile.relpath}/hello.c" />
      </exec>
      <au:assertFilesMatch expected="${expectedoutput.dir}/${outfile}"
                           actual="${actualoutput.dir}/${outfile}" />
   </target>
</project>
```

The file is mostly boilerplate. If you want to make your own test, copy _hello.xml_ and modify the following three lines:
```
...
   <property name="outfile" value="hello.c.out" />
...
   <target name="test-hello.c-output">
...
         <arg value="${testfile.relpath}/hello.c" />

```



# Unit tests #

Unit tests can be invoked using ant by doing:
```
ant unit
```

Unit tests can be found in the [t/tlib/SclcTest.pm ](http://code.google.com/p/sclc/source/browse/trunk/t/tlib/SclcTest.pm) file, and can be useful if you want to test functions inside of sclc. We use the Perl [Test::Unit::Lite](http://search.cpan.org/dist/Test-Unit-Lite/lib/Test/Unit/Lite.pm) package for writing unit tests.

As an example, here are two tests for a function defined in sclc called IsCeePlusPlus that returns true if a line of code contains C++-specific directives, and false otherwise:

```
sub test_IsCeePlusPlus_with_cpp_code {
    my $self = shift;
    my $code = "class MyClass {";
    $self->assert(Sclc::IsCeePlusPlus($code));
}

sub test_IsCeePlusPlus_with_c_code {
    my $self = shift;
    my $code = "x = foo(12);";
    $self->assert(!Sclc::IsCeePlusPlus($code));
}
```

To write new tests, simply add functions to this file. However, make sure that the file ends with the following line, or tests won't run properly:
```
1;
```