#!/usr/bin/perl
#
# sclc -- source code line counter (actually it counts more than just lines)
#
# Created 06/09/95 by Brad Appleton <bradapp@enteract.com>
# Patched for Matlab and ZPL 11/01/04 by Bill Mann <wfmann@alum.mit.edu>
# Patched for FORTRAN 11/03/04 by Bill Mann <wfmann@alum.mit.edu>
#
#-------------------------------------------------------------------------
# COPYING
# =======
# This file/program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself. Please refer to the
# license that came with your Perl distribution for more details.
#
# DISCLAIMER
# ===========
# This software is distributed in the hope that it will be useful, but
# is provided "AS IS" WITHOUT WARRANTY OF ANY KIND, either expressed or
# implied, INCLUDING, without limitation, the implied warranties of
# MERCHANTABILITY and FITNESS FOR A PARTICULAR PURPOSE.
#
# The ENTIRE RISK as to the quality and performance of the software
# IS WITH YOU (the holder of the software).  Should the software prove
# defective, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
# CORRECTION.
#
# IN NO EVENT WILL ANY COPYRIGHT HOLDER OR ANY OTHER PARTY WHO MAY CREATE,
# MODIFY, OR DISTRIBUTE THE SOFTWARE BE LIABLE OR RESPONSIBLE TO YOU OR TO
# ANY OTHER ENTITY FOR ANY KIND OF DAMAGES (no matter how awful - not even
# if they arise from known or unknown flaws in the software).
##########################################################################

package Sclc;

use strict;
use Config;
use File::Basename qw(&basename &dirname);

## Get basename and dirname of program path
my $Is_WinDos     = ( (uc $Config{'osname'}) =~ /(?:MSDOS|MSWIN|WIN32)/ );
my $Path_Sep      = ( $Is_WinDos ? "\\" : "/" );
my $PathList_Sep  = ( $Is_WinDos ? ";" : ":" );
my ($NAME, $EXECDIR) = (basename($0), dirname($0) || ".");

my @Languages = (
      'Ada',
      'Assembly',
      'Awk',
      'C',
      'C++',
      'Eiffel',
      'FORTRAN',
      'Java',
      'Lisp',
      'Matlab',
      'Pascal',
      'Perl',
      'Tcl',
      'ZPL',
      'shell',
      'make',
);

=head1 NAME

sclc -- Source-code line counter

=head1 SYNOPSIS

 sclc [-delim-ignore] [-counts SPEC] [-sections SPEC] [-language [EXT=]LANG]
      [-name REGEXP] [-except REGEXP] [-recurse] [-filelist] [-ignore]
      [-diff] [-fromversion SELECTOR] [-toversion SELECTOR] [-pred]
      [-prefix REGEXP] [-separate REGEXP] [-vcstring STRING] [-output FILE]
      [FILE ...]

=head1 OPTIONS AND ARGUMENTS

=over 6

=item B<-Help>

Print this help message and exit.

=item B<-language> [I<EXT>=]I<LANG>

Assume that any file with a suffix of "I<EXT>" is a C<LANG> source file
(note that you must supply any leading '.'). If the "I<EXT>" begins
with a slash ('/'), then the name that follows it is considered to
be the name of an interpreter that is invoked using "#!I<path>/I<EXT>"
as the first line of the script (and if the language can't be determined
from the extension, then the first line of the file will be used). If
"I<EXT>=" is omitted then C<LANG> will be the default language for any files
whose language cannot be determined.  C<LANG> must be one of the following:

=over 3

=item S<>

Ada,
Assembly,
Awk,
C,
C++,
Eiffel,
FORTRAN,
Java,
Lisp,
Matlab,
Pascal,
Perl,
Tcl,
ZPL,
shell,
make

=back

Language names may I<not> be abbreviated. This option may be specified
multiple times.

=item B<-delim-ignore>

Ignore all statement delimiters. This means that lines containing
nothing but statement delimiters/terminators are *not* considered
lines of code. For C/C++ this would have the effect of ignoring
lines containing nothing but ';', '{', and '}'.

=item B<-diff>

Treat the input as output from B<diff(1)> and report counts for both
inserted and deleted source. Note that the B<-diff> option is implied
by any of B<-pred>, B<-fromversion> or B<-toversion>.

=item B<-ignore>

Don't bother with files whose language can't be determined.

=item B<-filelist>

Assume that the source files to read are listed in the contents of
the files given on the command line (filelist is read from standard
input if no files are given). This is useful if you wish to use the
output of commands Like B<find(1)> as input to this command.

=item B<-name> I<REGEXP>

Only look at files whose filename (not including the directory path)
completely match the given perl-style regular expression. Does not
apply to directories when B<-recurse> is used. May be specified
multiple times (for a description of Perl's regular expression
syntax, invoke C<man perlre> or C<perldoc perlre>).

=item B<-except> I<REGEXP>

Don't look at files whose filename (not including the directory path)
completely match the given perl-style regular expression (even if
it would be matched by a B<-name> expression). Does not apply to
directories when B<-recurse> is used. May be specified multiple
times  (for a description of Perl's regular expression
syntax, invoke C<man perlre> or C<perldoc perlre>).

=item B<-prefix> I<REGEXP>

Ignore/strip the leading portion of each line that matches the given
perl-style regular expression. Do I<not> use a leading '^' unless you
mean to match the caret character itself (for a description of Perl's
regular expression syntax, invoke C<man perlre> or C<perldoc perlre>)

=item B<-recurse>

For every "source" file that is actually a directory, read all
source files in the directory.

=item B<-fromversion> I<SELECTOR>

When used with B<-diff>, assumes that I<SELECTOR> is a valid ClearCase
version selector and uses it in conjunction with B<cdiff> as the
"from" version of each file specified. Only one of C<-fromversion>
and C<-pred> may be specified!

=item B<-toversion> I<SELECTOR>

When used with B<-diff>, assumes that I<SELECTOR> is a valid ClearCase
version selector and uses it in conjunction with B<cdiff> as the
"to" version of each file specified.

=item B<-pred>

When used with B<-diff>, assumes that each file is an element in a
ClearCase VOB and uses it in conjunction with B<cdiff> as the "from"
version of each file specified (note that the predecessor version
is chosen relative to the "to" version of the file). Only one of
B<-pred> and B<-fromversion> may be specified!

=item B<-separate> I<REGEXP>

Assume that whenever a source line is encountered that completely
matches the given perl-style regular expression, it indicates the
end of the current source context. Useful if you are trying to
count lines from the output of a command like B<diff(1)> and you
dont want a comment or quote in one changed section to be treated
as if it continued into the next block of modifications. May be
specified multiple times (for a description of Perl's regular expression
syntax, invoke C<man perlre> or C<perldoc perlre>).

=item B<-counts> I<SPEC>

Specify which counts/columns to display in the output. I<SPEC>
may contain any of the following (separated by '+'):

   "Lines" : print the total # of lines
   "Blank" : print the total # of blank-lines
   "Cmnts" : print the total # of comments
   "NCSL"  : print the total # of non-comment source lines
   "AESL"  : print the total # of assembly-equivalent source lines

The above keywords may be abbreviated to a unique prefix if desired.
If the B<-counts> option is I<not> specified, then
C<Lines+Blank+Cmnts+NCSL> is implied.

=item B<-sections> I<SPEC>

Specify the sections in the output. I<SPEC> may contain any
of the following (separated by '+'):

   "Header"     : the column labels and separator bar
   "Files"      : the counts for each input file
   "LangTotals" : the totals for each language encountered.
   "Totals"     : the totals for all files.

The above keywords may be abbreviated to a unique prefix
if desired. If the B<-sections> option is I<NOT> specified,
then C<Header+Files+LangTotals+Totals> is implied.

=item B<-vcstring> I<STRING>

Specify that I<STRING> is the delimiter used by your version control
system and that the file suffix should be determined by only
considering the portion of the file path that precedes the first
occurrence of I<STRING>.

=item B<-output> I<FILE>

Redirect output to the named file (should have the same effect as
redirecting STDOUT on the cmdline using "> I<FILE>").

=item I<FILE>

Name of an input file.

=back

Option names are case insensitive and only a unique prefix is required.

=head1 DESCRIPTION

B<sclc> will count the number of lines, blank-lines, comments, non-comment
source lines (NCSL), and assembly equivalent source lines (AESL) in the
given input files (which are assumed to be free of syntax errors). The
output format will look something like the following:

  <header with column titles and separator line>
  <count1> <count2> ... <filename>  (<language>)
    ...      ...           ...         ...
  <total1> <total2> ... ----- <language> -----  (# files)
    ...      ...           ...         ...
  <total1> <total2> ... ***** TOTAL *****  (# files)

If the B<-diff> option is given than two lines are printed for each set of
counts: one for deleted lines and one for inserted lines (and the C<DELETED>
or C<INSERTED> keyword will appear on each output-line). If B<-pred> or
B<-fromversion> or B<-toversion> is given then B<-diff> is implied and B<cdiff>
command is invoked with the B<-blank_ignore> option to compare file versions.

The B<-counts> and B<-sections> options may be used to control which counts
and/or sections to print. The counts are always printed in an order such that:

     lines --> blank-lines --> comments --> NCSL --> AESL

where "X --> Y" means that the count of Xs always precedes the count of Ys.

=head1 EXAMPLES

The typical use for B<sclc> would be to just give it the filenames on
the command line:

  $ sclc dir.c dir.h
  Lines  Blank  Cmnts   NCSL     AESL     
  =====  =====  =====  =====  ==========  =============================
    215     26     14    158       395.0  dir.c  (C)
     41      8     16     24        60.0  dir.h  (C)
    256     34     30    182       455.0  ----- C -----  (2 files)

There are options to control which columns you do/dont want to see.
The C<NCSL> column is for "non-comment source lines". The C<AESL> column
is for "assembly equivalent source lines" (it calculates this using
assembly-equivalence factors published by Software Productivity Research).
If all you care about is NCSL, you could simply invoke it as:

  $ sclc -counts ncsl dir.[ch]
   NCSL  
  =====  ==============================================================
    158  dir.c  (C)
     24  dir.h  (C)
    182  ----- C -----  (2 files)

If you dont want the header columns, and want to see the overall totals
instead of the totals per programming language (B<sclc> can handle C, C++,
Java, Perl, Assembly, Pascal, and several other languages) then you could
simply say:

  $ sclc -counts ncsl -sections file+totals *.[ch]

    158  dir.c  (C)
     24  dir.h  (C)
    182  ***** TOTAL *****  (2 files)

If you want to know the number of lines of code that have changed
between versions of files, you can use the B<-pred> option, or a
combination of the B<-fromversion> and B<-toversion> options. If
you simply want to know the number of new and changed lines of code
between a set of files and their immediate predecessors, use the B<-pred>
option:

  $ sclc -pred *.[ch]

  Lines  Blank  Cmnts   NCSL     AESL     
  =====  =====  =====  =====  ==========  ===============================
      3      1      0      2         5.0  dir.c DELETED  (C)
      5      1      0      4        10.0  dir.c INSERTED  (C)
      1      0      0      1         2.5  dir.h DELETED  (C)
      2      0      0      2         5.0  dir.h INSERTED  (C)
      4      1      0      3         7.5  ----- C DELETED -----  (2 files)
      7      1      0      6        15.0  ----- C INSERTED -----  (2 files)

Again, if you want to limit the output to include only the NCSL counts for
the individual files and their totals, add the B<-counts> and B<-sections>
options into the fold:

  $ sclc -pred -counts ncsl -sections file+totals *.[ch]

      2  dir.c DELETED  (C)
      4  dir.c INSERTED  (C)
      1  dir.h DELETED  (C)
      2  dir.h INSERTED  (C)
      3  ***** TOTAL DELETED *****  (2 files)
      6  ***** TOTAL INSERTED *****  (2 files)

If you want to count the difference in source lines between specific
versions (not just the predecessor) you may use the B<-fromversion>
option to specify the base ("from") version to use for all comparisons.
If the base version is not explicitly specified, it defaults to whatever
version is selected in the users view. Similarly, the B<-toversion>
option may be used to specify the target ("to") version to use for all
comparisons. If the target version is not specified, then (like the base
version) it defaults to whatever version is selected in the users view.

So if I want to count the changed lines of code between what is in my
view and what was on the C<REL1.0.0> label, I would do the following:

  $ sclc -fromver REL1.0.0 *.[ch]

And if I wanted to count the changed lines of code between files on
my C</main/rel1/mychanges> branch and the REL1.0.0 baseline label they
where branched off from, I would use:

  $ sclc -fromver REL1.0.0 -tover .../mychanges/LATEST *.[ch]

If I wanted to see the difference in lines of code for files on to
different labels I would do something like:

  $ sclc -fromver REL1.0.0 -tover REL2.0.0 *.[ch]

If I wanted to do the same as the above, but my view was already selecting
everything in the REL1.0.0 baseline, then I could simply do:

  $ sclc -tover REL2.0.0 *.[ch]

Hopefully, this "tutorial" should have provided you with a good set of
cookbook examples for using B<sclc>. if you ever want to see this manual
page, you need only invoke B<sclc> using the B<-help> option:

  $ sclc -help

=head1 SEE ALSO

L<cdiff> -- B<sclc> uses B<cdiff> to compare versions of files.

=head1 AUTHOR

Brad Appleton  E<lt>bradapp@computer.orgE<gt>

=cut

## Globals (yuck!)
my %OPTS   = ();
my %CNTS   = ();
my %SECS   = ();
my $ERRORS = 0;
my %KIND   = ();
my %Lines  = ();
my %Blank  = ();
my %Cmnts  = ();
my %NCSL   = ();
my %AESL   = ();
my $DEFAULT_LANG = "";
my $LANG_NAME    = "";
my $LANG_REF     = "";
my %LANG_RULES   = ();
my $NumSources   = 0;
my %NumSources   = ();

##----------------------------------------------------------------------
## DESIGN:
##
## [ Okay listen up and listen good. Here is the strategy we use ... ]
## 
## Basically, foreach language we "know" we only care about the following:
##   - comments (ones that are delimited and ones that continue to end-of-line)
##   - quotations
##   - statement-terminators
##   - block-statement terminators
##
## Therefore for each language, we need to know which characters to pay
## attention to if we are inside a comment, quotations, or neither. Hence
## we will use two arrays for each language:
##
##   1) An array of substitutions to perform any necessary preprocessing
##      for this particular language. We need this to do things like 
##      editing potentially confusing constructs (like replacing the keyword
##      'end' with a single token that is the same regardless of case, or 
##      to deal with things like substitions and variable names in perl).
##
##   2) An associative with the following keys:
##         $Array{'AESL'} -- Assembly Equivalent multiplier for determining
##                           AESL from NCSL. These values are obtained from
##                           the Programming Language Tables at Capers Jones'
##                           Software Productivity Research, Inc. from the
##                           URL http://www.spr.com/library/langtbl.htm
##
##         $Array{'START_STATE'} -- A regular expression that will match
##            only the tokens I am interested in if I am not inside a
##            comment or a quotation.
##
##         $Array{'CMMNT_STATE'} -- A regular expression that will match
##            only the tokens I am interested in if I am inside a comment
##            whose end is delimited by something other than a newline
##
##         $Array{'CMMNT_NESTING'} -- true or false, depending on whether
##            or not comments are allowed to nest.
##
##         $Array{'<token>QUOTE_STATE'} -- A regular expression that will
##            match only the tokens I am interested in if I am inside a
##            quoted context whose beginning was denoted by <token>.
##
##         $Array{END_<token>} -- The string/character that corresponds to the
##            end of a quoted context whose beginning was denoted by <token>.
##
##         $Array{<token>} -- This should be one of the following predefined
##            constants:
##
my ($EolCmnt,    ## A comment that continues until end-of-line
    $BeginCmnt,  ## Beginning of a delimited comment
    $EndCmnt,    ## End of a delimited comment
    $BeginQuote) ## The beginning of a quoted/literal context
      = (1, 2, 3, 4);
##
##            For each <token> that we will ever match, $Array{<token>}
##            will yield the token type (its semantic meaning).
##

## Need the following array for when the LANG_DEFNS array has to correspond
## to more than one language with a different AESL multiplier for each. The
## Index should be the LANG_NAME.
##
my %AssemblyEquivalence = ('C++', 6.0);

##
##----------------------------------------------------------------------

                    ### BEGIN LANGUAGE DEFINITIONS ###

##----------------------------------------------------------------------
## Assembly language definitions
##   NOTE: these are pretty generic and may not work for all assembly languages
my @ASSEMBLY_EVALS = ('s/^\s*\*/;/');  ## Treat '*' at beginning as a comment
my %ASSEMBLY_DEFNS = ('AESL', 1.0,
                      'START_STATE', ";",
                      'CMMNT_STATE', "",
                      'CMMNT_NESTING', "",
                      ';', $EolCmnt,
                     );
$LANG_RULES{'ASSEMBLY'} = [ \@ASSEMBLY_EVALS, \%ASSEMBLY_DEFNS ];

##----------------------------------------------------------------------
## C/C++ language definitions
my @C_EVALS = (
               's/[{;}]/ /g  if ($OPTS{delim_ignore})'
              );
my %C_DEFNS = ('AESL', 2.5,
               'START_STATE', "/[\\*/]|[\"']",
               'CMMNT_STATE', "\\*/",
               'CMMNT_NESTING', "",
               '"QUOTE_STATE', '\\\\.|"',
               'END_"', '"',
               "'QUOTE_STATE", "\\\\.|'",
               "END_'", "'",
               '//', $EolCmnt,
               '/*', $BeginCmnt,
               '*/', $EndCmnt,
               "'", $BeginQuote,
               '"', $BeginQuote,
              );
$LANG_RULES{'C'} = [ \@C_EVALS, \%C_DEFNS ];

##----------------------------------------------------------------------
## Java language definitions
my @JAVA_EVALS = (
                  's/[{;}]/ /g  if ($OPTS{delim_ignore})'
                 );
my %JAVA_DEFNS = ('AESL', 6,
                  'START_STATE', "/[\\*/]|[\"']",
                  'CMMNT_STATE', "/\\*|\\*/",
                  'CMMNT_NESTING', 1,
                  '"QUOTE_STATE', '\\\\.|"',
                  'END_"', '"',
                  "'QUOTE_STATE", "\\\\.|'",
                  "END_'", "'",
                  '//', $EolCmnt,
                  '/*', $BeginCmnt,
                  '*/', $EndCmnt,
                  "'", $BeginQuote,
                  '"', $BeginQuote,
                 );
$LANG_RULES{'JAVA'} = [ \@JAVA_EVALS, \%JAVA_DEFNS ];

##----------------------------------------------------------------------
## Shell language definitions
my @SHELL_EVALS = (
                   's/(^|\s+)#/\001/g',   ## denote '#' comments with \001
                   's/\.//g',             ## remove escaped characters
                   's/[\({;}\)]/ /g  if ($OPTS{delim_ignore})'
                  );
my %SHELL_DEFNS = ('AESL', 15.0,
                   'START_STATE',"[\001\`\"']",
                   '"QUOTE_STATE', '\\\\.|"',
                   'END_"', '"',
                   "'QUOTE_STATE", "\\\\.|'",
                   "END_'", "'",
                   "`QUOTE_STATE", "\\\\.|\`",
                   "END_`", "\`",
                   "\001", $EolCmnt,
                   "'", $BeginQuote,
                   '"', $BeginQuote,
                   '`', $BeginQuote,
                  );
$LANG_RULES{'SHELL'} = [ \@SHELL_EVALS, \%SHELL_DEFNS ];

##----------------------------------------------------------------------
## Make language definitions
my @MAKE_EVALS = (
                  's/^\s*#/\001/g',    ## denote '#' comments with \001
                  's/[\({;}\)]/ /g  if ($OPTS{delim_ignore})'
                 );
my %MAKE_DEFNS = ('AESL', 15.0,
                  'START_STATE',"[\001\`\"']",
                  '"QUOTE_STATE', '\\\\.|"',
                  'END_"', '"',
                  "'QUOTE_STATE", "\\\\.|'",
                  "END_'", "'",
                  "`QUOTE_STATE", "\\\\.|\`",
                  "END_`", "\`",
                  "\001", $EolCmnt,
                  "'", $BeginQuote,
                  '"', $BeginQuote,
                  '`', $BeginQuote,
                 );
$LANG_RULES{'MAKE'} = [ \@MAKE_EVALS, \%MAKE_DEFNS ];

##----------------------------------------------------------------------
## Awk language definitions
my @AWK_EVALS = ('s/(^|\s+)#/\001/g',   ## denote '#' comments with \001
                 's/\.//g',             ## remove escaped characters
                 's/[{;}]/ /g  if ($OPTS{delim_ignore})'
                );
my %AWK_DEFNS = ('AESL', 15.0,
                 'START_STATE',"[\001\"']",
                 '"QUOTE_STATE', '\\\\.|"',
                 'END_"', '"',
                 "'QUOTE_STATE", "\\\\.|'",
                 "END_'", "'",
                 "\001", $EolCmnt,
                 "'", $BeginQuote,
                 '"', $BeginQuote,
                );
$LANG_RULES{'AWK'} = [ \@AWK_EVALS, \%AWK_DEFNS ];

##----------------------------------------------------------------------
## Tcl language definitions
my @TCL_EVALS = ('s/(^|\s+)#/\001/g',   ## denote '#' comments with \001
                 's/\.//g',             ## remove escaped characters
                 's/[\[{;}\]]/ /g  if ($OPTS{delim_ignore})'
                );
my %TCL_DEFNS = ('AESL', 5.0,
                 'START_STATE',"[\001\`\"'{;}]",
                 '"QUOTE_STATE', '\\\\.|"',
                 'END_"', '"',
                 "'QUOTE_STATE", "\\\\.|'",
                 "END_'", "'",
                 "`QUOTE_STATE", "\\\\.|\`",
                 "END_`", "\`",
                 "\001", $EolCmnt,
                 "'", $BeginQuote,
                 '"', $BeginQuote,
                 '`', $BeginQuote,
                );
$LANG_RULES{'TCL'} = [ \@TCL_EVALS, \%TCL_DEFNS ];

##----------------------------------------------------------------------
## Perl language definitions
##
##    NOTE: I tried to put in some substitutions and definitions to treat
##          stuff between quotes (double and single) and between slashes
##          (for matches *and* substitutions) as literals, but it is too
##          complex to get it all right and I get better results without
##          looking for literals (although still not great).
##
my @PERL_EVALS = ('s/(^|\s+)#/\001/g',   ## denote '#' comments with \001
                  's/^=cut\s*/\003/g',   ## end pod comments with \003
                  's/^=[a-z]+/\002/g',         ##   and start them with \002
                  's/\.//g;',            ## remove escaped characters
                  's/[{;}]/ /g  if ($OPTS{delim_ignore})'
                );
my %PERL_DEFNS = ('AESL', 15.0,
                  'START_STATE', '[\001\002]',
                  'CMMNT_STATE', '^\003',
                  'CMMNT_NESTING', "",
                  "\001", $EolCmnt,
                  "\002", $BeginCmnt,
                  "\003", $EndCmnt,
                 );
$LANG_RULES{'PERL'} = [ \@PERL_EVALS, \%PERL_DEFNS ];

##----------------------------------------------------------------------
## Ada language definitions
my @ADA_EVALS = (
                 "s/';'//g",  ## the only single-quote we need to worry about
                 's/begin|end|is|;/ /gi  if ($OPTS{delim_ignore})'
                );
my %ADA_DEFNS = ('AESL', 6.5,
                 'START_STATE',"[\"]|--",
                 'CMMNT_STATE', "",
                 'CMMNT_NESTING', "",
                 '"QUOTE_STATE', '""|"',
                 'END_"', '"',
                 "--", $EolCmnt,
                 '"', $BeginQuote,
               );
$LANG_RULES{'ADA'} = [ \@ADA_EVALS, \%ADA_DEFNS ];

##----------------------------------------------------------------------
## Eiffel language definitions
my @EIFFEL_EVALS = (
                    's/end|is|;/ /gi  if ($OPTS{delim_ignore})'
                   );
my %EIFFEL_DEFNS = ('AESL', 15.0,
                    'START_STATE',"[\"']|--",
                    'CMMNT_STATE', "",
                    'CMMNT_NESTING', "",
                    '"QUOTE_STATE', '%"|"',
                    'END_"', '"',
                    "'QUOTE_STATE", '%[%"]|"',
                    "END_'", "'",
                    "--", $EolCmnt,
                    "'", $BeginQuote,
                    '"', $BeginQuote,
                   );
$LANG_RULES{'EIFFEL'} = [ \@EIFFEL_EVALS, \%EIFFEL_DEFNS ];

##----------------------------------------------------------------------
## Pascal language definitions
my @PASCAL_EVALS = (
                    's/begin|end|;/ /gi  if ($OPTS{delim_ignore})'
                   );
my %PASCAL_DEFNS = ('AESL', 3.5,
                    'START_STATE',"[']|{|\\(\\*",
                    'CMMNT_STATE', '}|\*\)',
                    'CMMNT_NESTING', 1,
                    "'QUOTE_STATE", "''|'",
                    "END_'", "'",
                    '(*', $BeginCmnt,
                    '*)', $EndCmnt,
                    '{', $BeginCmnt,
                    '}', $EndCmnt,
                    "'", $BeginQuote,
                   );
$LANG_RULES{'PASCAL'} = [ \@PASCAL_EVALS, \%PASCAL_DEFNS ];

##----------------------------------------------------------------------
## Lisp language definitions
my @LISP_EVALS = (
                  's/[\(\)]/ /g  if ($OPTS{delim_ignore})'
                 );
my %LISP_DEFNS = ('AESL', 5.0,
                  'START_STATE', "[;\"]",
                  'CMMNT_STATE', "",
                  'CMMNT_NESTING', "",
                  '"QUOTE_STATE', '\"|"',
                  'END_"', '"',
                  ";", $EolCmnt,
                  '"', $BeginQuote,
                 );
$LANG_RULES{'LISP'} = [ \@LISP_EVALS, \%LISP_DEFNS ];

##----------------------------------------------------------------------

##----------------------------------------------------------------------
## Matlab/Octave language definitions
my @MATLAB_EVALS = (
               's/end|;/ /g  if ($OPTS{delim_ignore})'
              );
my %MATLAB_DEFNS = ('AESL', 15,	# who knows ...
               'START_STATE', "[%']",
               'CMMNT_STATE', "",
               'CMMNT_NESTING', "",
               "'QUOTE_STATE", "'",
               "END_'", "'",
               '%', $EolCmnt,
               "'", $BeginQuote,
              );
$LANG_RULES{'MATLAB'} = [ \@MATLAB_EVALS, \%MATLAB_DEFNS ];

                    ### END OF LANGUAGE DEFINITIONS ###

##----------------------------------------------------------------------
## ZPL language definitions
my @ZPL_EVALS = (
               's/begin|end|;/ /g  if ($OPTS{delim_ignore})'
              );
my %ZPL_DEFNS = ('AESL', 15,	# who knows ...
               'START_STATE', "/\\*|--|[\"']",
               'CMMNT_STATE', "\\*/",
               'CMMNT_NESTING', "",
               '"QUOTE_STATE', '"',
               'END_"', '"',
               "'QUOTE_STATE", "'",
               "END_'", "'",
               '!', $EolCmnt,
               "'", $BeginQuote,
               '"', $BeginQuote,
              );
$LANG_RULES{'ZPL'} = [ \@ZPL_EVALS, \%ZPL_DEFNS ];

##----------------------------------------------------------------------
## FORTRAN language definitions
my @FORTRAN_EVALS =
              ('s/^[c\\*]/!/gi', ## denote 'c ...' comments with !
               's/^\s*end[^!\n]*/ /gi  if ($OPTS{delim_ignore})'
              );
my %FORTRAN_DEFNS = ('AESL', 5,	# who knows ...
               'START_STATE', "!|[\"']",
               'CMMNT_STATE', "",
               'CMMNT_NESTING', "",
               '"QUOTE_STATE', '\\\\.|"',
               'END_"', '"',
               "'QUOTE_STATE", "\\\\.|'",
               "END_'", "'",
               '!', $EolCmnt,
               '/*', $BeginCmnt,
               '*/', $EndCmnt,
               "'", $BeginQuote,
               '"', $BeginQuote,
              );
$LANG_RULES{'FORTRAN'} = [ \@FORTRAN_EVALS, \%FORTRAN_DEFNS ];

## Default language extensions
##----------------------------------------------------------------------
## GLOBAL:
##
## DESCRIPTION:
##
##----------------------------------------------------------------------
my %Suffixes = (
   ## Assembler
      ".s",   "Assembly",
      ".S",   "Assembly",
      ".as",  "Assembly",
      ".AS",  "Assembly",
      ".asm", "Assembly",
      ".ASM", "Assembly",
   ## C
      ".c", "C",
      ".C", "C",  ## We have some special rules we use later on so we
      ".h", "C",   ## don't mistake a C++ file for a C file.
      ".H", "C",
   ## C++
      ".cc",  "C++",
      ".cxx", "C++",
      ".cpp", "C++",
      ".hh",  "C++",
   ## Ada
      ".a",   "Ada",
      ".ada", "Ada",
      ".Ada", "Ada",
      ".ADA", "Ada",
   ## Eiffel
      ".e",   "Eiffel",
      ".efl", "Eiffel",
      ".Efl", "Eiffel",
      ".EFL", "Eiffel",
   ## FORTAN
      ".f",   "FORTRAN",
      ".for", "FORTRAN",
      ".f90", "FORTRAN",
      ".F",   "FORTRAN",
      ".F90", "FORTRAN",
   ## Java
      ".java",  "Java",
      ".jav",   "Java",
      ".JAV",   "Java",
   ## Lisp
      ".l",   "Lisp",
      ".lsp", "Lisp",
      ".Lsp", "Lisp",
      ".LSP", "Lisp",
   ## Matlab
      ".m",   "Matlab",
   ## Pascal
      ".p",   "Pascal",
      ".pas", "Pascal",
      ".Pas", "Pascal",
      ".PAS", "Pascal",
   ## Perl
      ".pl",  "Perl",
      ".PL",  "Perl",
      ".plt", "Perl",
      ".PLT", "Perl",
      ".ph",  "Perl",
      ".PH",  "Perl",
      ".pm",  "Perl",
      ".PM",  "Perl",
   ## shell
      ".sh",   "shell",
      ".bash", "shell",
      ".csh",  "shell",
      ".ksh",  "shell",
      ".tcsh", "shell",
      ".zsh",  "shell",
   ## make
      ".mk",        "make",
      ".MK",        "make",
      ".make",      "make",
      ".MAKE",      "make",
   ## Awk
      ".awk",  "Awk",
      ".AWK",  "Awk",
   ## Tcl
      ".tcl",   "Tcl",
      ".Tcl",   "Tcl",
      ".TCL",   "Tcl",
      ".tclsh", "Tcl",
      ".TCLSH", "Tcl",
      ".tk",    "Tcl",
      ".Tk",    "Tcl",
      ".TK",    "Tcl",
      ".wish",  "Tcl",
      ".WISH",  "Tcl",
   ## ZPL
      ".z",     "ZPL",
      ".zh",    "ZPL",
);

## Default language interpreters
##----------------------------------------------------------------------
## GLOBAL:
##
## DESCRIPTION:
##
##----------------------------------------------------------------------
my %Interpreters = (
   ## Perl
      "per5", "Perl",
      "perl", "Perl",
      "Perl", "Perl",
      "PERL", "Perl",
   ## Awk
      "awk",  "Awk",
   ## shell
      "sh",   "shell",
      "bash", "shell",
      "csh",  "shell",
      "ksh",  "shell",
      "tcsh", "shell",
      "zsh",  "shell",
   ## Tcl
      "tcl",   "Tcl",
      "Tcl",   "Tcl",
      "TCL",   "Tcl",
      "tclsh", "Tcl",
      "TCLSH", "Tcl",
      "tk",    "Tcl",
      "Tk",    "Tcl",
      "TK",    "Tcl",
      "wish",  "Tcl",
      "WISH",  "Tcl"
);


##----------------------------------------------------------------------
## FUNCTION:
##   ErrorMsg -- Print an error message (prefixed by "$NAME: ").
##
## SYNOPSIS:
##   &ErrorMsg("message text");
##
## ARGUMENTS:
##   A single string containing the message text.
##
## RETURN VALUE: None.
##
## PRECONDITIONS:
##   The global variable $NAME should be set to the name of the running
##   script.
##
## SIDE EFFECTS:
##   - Prints to STDERR
##----------------------------------------------------------------------
sub ErrorMsg {
   print STDERR ("${NAME}: ", @_, "\n");
}

##----------------------------------------------------------------------
## FUNCTION:
##   FatalMsg -- Print an error message and then abort
##
## SYNOPSIS:
##   &FatalMsg("message text");
##
## ARGUMENTS:
##   A single string containing the message text.
##
## RETURN VALUE: None.
##
## PRECONDITIONS:
##   The global variable $NAME should be set to the name of the running
##   script.
##
## SIDE EFFECTS:
##   - Prints an error message
##   - Exits the script using exit(2)
##----------------------------------------------------------------------
sub FatalMsg {
   &ErrorMsg(@_);
   exit(2);
}

##----------------------------------------------------------------------
## FUNCTION:
##   Usage -- Print a Usage message and then exit with the specified
##            exit-value. If the exit-value is > 1, then usage is terse
##            (synopsis only) and goes to STDERR. Otherwise, usage is
##            verbose and goes to STDOUT.
##
## SYNOPSIS:
##   &Usage([$val]);
##
## ARGUMENTS:
##   $val : (optional) The integer exit value to use (defaults to 2).
##
## RETURN VALUE: None.
##
## PRECONDITIONS: None.
##
## SIDE EFFECTS:
##   Exits the script using exit with the given exit-status.
##----------------------------------------------------------------------
sub Usage {
   local($_) = shift;
   my ($exitval, $message) = (1, '');
   ## Collect arguments
   if ( /^[-+]?\d+$/ ) {
      ($exitval, $message) = ($_, '');
   }
   elsif (defined $_  and  length $_) {
      ($exitval, $message) = (2, $_);
   }
   printf STDERR ("%s: %s\n", basename($0), $message)  if ($message);
   $ENV{PATH} .= $PathList_Sep . $Config{bin};
   system( $Config{bin} . $Path_Sep . 'perldoc', $0 );
   exit($exitval);
}

##----------------------------------------------------------------------
## FUNCTION:
##   DbgPrint -- Print debugging output. Prints the specified arguments
##               only if '-debug' was specified on the command-line.
##
## SYNOPSIS:
##   &DbgPrint(">debug message text\n");
##
## ARGUMENTS:
##   The string containing the debug message text (a newline is not
##   automatically printed so include it yourself if you need it).
##
## RETURN VALUE: None.
##
## PRECONDITIONS:
##   Assumes that the global variable named $OPTS{'debug'} will evaluate to
##   TRUE if '-debug' was given on the command-line.
##
## SIDE EFFECTS:
##   Prints to STDERR
##----------------------------------------------------------------------
sub DbgPrint {
   print STDERR (@_) if ($OPTS{'debug'});
}

## Match a string against a set of keywords (case insensitive and
## allowing unique prefixes). Return the list of matching elements.
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub MatchKwd {
   my($str, @keywords) = @_;
   local $_;
   my @matches = grep( m/^${str}$/i, @keywords );
   @matches = grep( m/^${str}/i, @keywords ) if ( @matches == 0 );
   @matches;
}

## Validate -language option
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub CheckLanguage {
   my(@extspecs) = @_;
   local($_);
   foreach (@extspecs) {
      my ($ext, $lang) = ('', $_);
      ($ext, $lang) = ($1, $2) if (/^([^=]*)=(.+)$/);
      if (! $lang) {
         &ErrorMsg("invalid -language argument \"$_\"");
         ++$ERRORS;
         next;
      }
      my $expr = $lang;
      $expr =~ s/\W/\\$&/g;
      my @matches = grep(/^${expr}$/i, @Languages);
      if (@matches == 0) {
         &ErrorMsg("Unknown programming language: \"$lang\"");
         ++$ERRORS;
      }
      $lang = $matches[$[];
      if (! $ext) {
         $DEFAULT_LANG = $lang;
      }
      elsif ($ext =~ m|^/(.*)$|) {
         $Interpreters{$1} = $lang;
      }
      else {
         $Suffixes{$ext} = $lang;
      }
   }
}

## Validate -sections option
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub CheckSections {
   local($_);
   my @secspecs = split(/\W/, $OPTS{'sections'});
   if (0 == @secspecs) {
      &ErrorMsg("invalid sections specifier \"$OPTS{'sections'}\"");
      ++$ERRORS;
   }
   else {
      my @matches = ();
      foreach (@secspecs) {
         @matches = &MatchKwd($_, "header", "files", "langtotals", "totals");
         if (@matches == 1) {
            ++$SECS{$matches[0]};
         }
         elsif (@matches == 0) {
            &ErrorMsg("invalid sections specifier \"$_\"");
            ++$ERRORS;
         }
         else {
            &ErrorMsg("ambiguous sections specifier \"$_\"");
            ++$ERRORS;
         }
      }
   }
}

## Validate -counts option
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub CheckCounts {
   local($_);
   my @cntspecs = split(/\W/, $OPTS{'counts'});
   if (0 == @cntspecs) {
      &ErrorMsg("invalid counts specifier \"$OPTS{'counts'}\"");
      ++$ERRORS;
   }
   else {
      my @matches = ();
      foreach (@cntspecs) {
         @matches = &MatchKwd($_, "lines", "blank", "cmnts", "ncsl", "aesl");
         if (@matches == 1) {
            ++$CNTS{$matches[0]};
         }
         elsif (@matches == 0) {
            &ErrorMsg("invalid counts specifier \"$_\"");
            ++$ERRORS;
         }
         else {
            &ErrorMsg("ambiguous counts specifier \"$_\"");
            ++$ERRORS;
         }
      }
   }
}

##----------------------------------------------------------------------
## FUNCTION:
##   SplitPath -- Split a pathname into dirname and basename components
##
## SYNOPSIS:
##   ($dirname, $basename, $vcsuffix) = &SplitPath($pname);
##
## ARGUMENTS:
##   $pname : The pathname of a file
##
## RETURN VALUE:
##   Returns the array ($dirname, $basename, $vcsuffix)
##   where $vcsuffix is the portion of the string (if any) the follows
##   the first occurrence of $OPTS{'vcstring'}
##
## PRECONDITIONS:
##   Assumes the global $OPTS{'vcstring'} is the version-control systems
##   separator text for splitting a pathname from its version.
##
## SIDE EFFECTS: None.
##----------------------------------------------------------------------
sub SplitPath {
   local($_) = @_;
   my($dirname, $basename, $vcsuffix, $i);
   if ($OPTS{'vcstring'}) {
      $i = index($_, $OPTS{'vcstring'});
      unless ($i < 0) {
         $vcsuffix = substr($_, $i+1);
         $_ = substr($_, 0, $i);
      }
   }
   ($dirname, $basename) = ('.', $_);
   $i = rindex($_, $Path_Sep);
   unless ($i < 0) {
      $dirname = substr($_, 0, $i);
      $basename = substr($_, $i+1);
   }
   ($dirname, $basename, $vcsuffix);
}

##----------------------------------------------------------------------
## FUNCTION:
##   ExcludeFile -- See if a file should be excluded from processing.
##
## SYNOPSIS:
##   if (&ExcludeFile($pname)) { ... }
##
## ARGUMENTS:
##   $pname : The pathname of a file that we may wish to process.
##
## RETURN VALUE:
##   TRUE if the file should be excluded from processing,
##   FALSE otherwise.
##
## PRECONDITIONS:
##   Uses the following globals:
##      $OPTS{'except'} -- list of regexps matching files to exclude
##      $OPTS{'name'} -- list of regexps matching files to include
##
## SIDE EFFECTS: None.
##----------------------------------------------------------------------
sub ExcludeFile {
   local($_) = @_;
   ## see if we should exclude this file from the list
   if ((@{ $OPTS{'name'} } > 0) || (@{ $OPTS{'except'} } > 0)) {
      my($dirname, $basename) = &SplitPath($_);
      my @matches = grep($basename =~ /^$_$/, @{ $OPTS{'except'} });
      return 1  if (@matches > 0);  ## this is an exception
      if (@{ $OPTS{'name'} } > 0) {
         ## only accept if we have a match
         @matches = grep($basename =~ /^$_$/, @{ $OPTS{'name'} });
         return 1  if (@matches == 0);  ## no match
      }
   }
   0;
}

## Return the reference name for the language-definition arrays
## of this language.
##
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub RefLanguage {
   my($lang) = @_;
   local($_) = $lang;
   ## Figure out the language-specific pair of arrays to use
   if ($lang) {
      $_ = "C" if ($lang eq "C++");  ## C & C++ use the same arrays
      ## Arrays are named <LANG>_DEFNS and <LANG>_EVALS where <LANG> is
      ## all uppercase with non-alphanumerics removed
      s/\W//g;
      s/[a-z]/\U$&/g;
   }
   $_;
}

## Guess the language based on the contents of the given text line
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub GuessLanguage {
   local($_) = @_;
   my($lang);
   if ($DEFAULT_LANG) {
      $lang = $DEFAULT_LANG;
   }
   elsif (m/^\s*#\s*(include|if|ifdef|define)\b/) {
      $lang = "C";
   }
   elsif (m|^\s*/\*\*\s*$|) {
      $lang = "Java";
   }
   elsif (m|^\s*/\*|) {
      $lang = "C";
   }
   elsif (m|^\s*//|) {
      $lang = "C++";
   }
   elsif (/^\s*\(\*/) {
      $lang = "Pascal";
   }
   elsif (/^\s*{/) {
      $lang = "Pascal";
   }
   elsif (/^\s*--/) {
      $lang = "Ada";  ## or it could be Eiffel
   }
   elsif (/^\s*[\(;]/) {
      $lang = "Lisp";
   }
   elsif (/^\s*\*/) {
      $lang = "Assembly";
   }
   elsif (m|^\s*#\s*\!\s*\S+$Path_Sep([^$Path_Sep\s]+)\s*|) {
      my $execname = $1;   ## get the name of the program to exec
         ## Remove the extension if we cant find its name
      $execname =~ s/\.[^.]*$//   unless (defined $Interpreters{$execname});
         ## Remove trailing numbers if we still cant find its name
      $execname =~ s/\d[.\d]*$//  unless (defined $Interpreters{$execname});
      $lang = $Interpreters{$execname} if (defined $Interpreters{$execname});
   }
   elsif (/^\s*#/) {
      $lang = "shell";
   }

   $lang = $DEFAULT_LANG if ($DEFAULT_LANG && (! $lang));

   my $ref = &RefLanguage($lang);
   ($LANG_NAME, $LANG_REF) = ($lang, $ref);
}

## Determine the source language based on the filename
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub SetLanguage {
   my ($filepath) = @_;
   local($_) = $filepath;
   my $lang = "";
   my ($dirname, $basename) = &SplitPath($_);
   ## First see if we have a '.' suffix
   if ($basename =~ /.+(\.[^.]+)$/) {
      $lang = $Suffixes{$1} if (defined $Suffixes{$1});
   }
   elsif ($basename =~ /^makefile/i) {
      $lang = "make";
   }
   elsif ($filepath ne '-') {
      ## Not a normal '.' suffix, have to look at all of them
      my %seen = ();
      foreach (keys %Suffixes) {
         next unless ($_);
         next if (defined $seen{$_});
         ++$seen{$_};
         s/\W/\\$&/g;  ## escape regexp meta-characters
         $lang = $Suffixes{$_} if ($basename =~ m|^.+$_$|);
         last if ($lang);
      }
   }
   if ($lang) {
      $lang = "C++" if (($lang eq "C") && ($DEFAULT_LANG eq "C++"));
      my $ref = &RefLanguage($lang) || "";
      ($LANG_NAME, $LANG_REF) = ($lang, $ref);
   }
   else {
      ## If we still dont know the language -- see if we can tell by
      ## looking at the contents of the first non-blank line
      if ($filepath eq '-') {
         $_ = '';
      }
      elsif (open(FILEPATH, $filepath)) {
         while (<FILEPATH>) {
            chomp;
            last unless (/^\s*$/);
         }
         close(FILEPATH);
      }
      &GuessLanguage($_);
   }
}

## See if the given line matches a -separate expression from the command-line
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub IsSeparator {
   local($_) = @_;
   return 0 if (@{ $OPTS{'separate'} } == 0);
   my $regexp;
   foreach $regexp (@{ $OPTS{'separate'} }) {
      return 1 if (/^${regexp}$/);
   }
   0;
}

## SourceCount -- Count the lines, blank-lines, comments, NCSL, and AESL
##                in the given source file (a filename of '-' means use STDIN).
##
## returns the array %counts upon success,
## If the file can't be opened, then returns ('Error', "Error")
##
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
use vars qw(@langEvals %langDefns);

sub SourceCount {
   my $filename = shift;
   local(*langEvals, *langDefns) = @_;
   my %error = ('Error', "Error");
   my $filehandle;
   local($_);
   my $diffType;  ## one of '' or '<' or '>'
   my ($inComment, $inQuote) = (0, '');
   my %counts = (
      'Lines'  => 0, 'Blank'  => 0, 'Cmnts'  => 0, 'NCSL'  => 0, 'AESL'  => 0,
      '<Lines' => 0, '<Blank' => 0, '<Cmnts' => 0, '<NCSL' => 0, '<AESL' => 0,
      '>Lines' => 0, '>Blank' => 0, '>Cmnts' => 0, '>NCSL' => 0, '>AESL' => 0
   );
   ## Open input
   if (($filename eq "-") && !($OPTS{'filelist'} && (@ARGV == 0))) {
      $filehandle = \*STDIN;
   }
   else {
      if ($OPTS{'pred'} || $OPTS{'fromversion'} || $OPTS{'toversion'}) {
         ## invoke cdiff using ClearCase version selectors
         my $from_pname = $filename;
         my $to_pname   = $filename;
         $from_pname      .= "\@\@$OPTS{'fromversion'}"  if ($OPTS{'fromversion'});
         $to_pname        .= "\@\@$OPTS{'toversion'}"    if ($OPTS{'toversion'});
         my $cdiff_cmd  = ${EXECDIR} . $Path_Sep . 'cdiff';
         $cdiff_cmd       .= " -unlimited -noprolog -blank_ignore";
         $cdiff_cmd       .= ($OPTS{'pred'}) ? " -pred" : " $from_pname";
         $cdiff_cmd       .= " $to_pname";
         $filename = "$cdiff_cmd |";
      }
      $filehandle = \*INPUT;
      unless (open(INPUT, $filename)) {
         &ErrorMsg("Can't open $filename for reading: $!");
         return %error;
      }
   }

   while (<$filehandle>) {
      chomp;
      $diffType = '';
      ## See if this is a context separator.
      if (&IsSeparator($_)) {
         ## Yes, reset context and get the next line.
         ($inComment, $inQuote) = (0, '');
         next;
      }
      ## Strip any leading prefix
      s/^$OPTS{'prefix'}// if ($OPTS{'prefix'});

      ## If this is diff(1) output, do some special stuff
      if ($OPTS{'diff'}) {
         if (/^([<>])\s+/) {
            ## line was inserted or deleted (strip the prefix)
            $diffType = $1;
            $_ = $';
         }
         else {
            ## Reset context and get the next line.
            ($inComment, $inQuote) = (0, '');
            next;
         }
      }

      ## Check for a blank line
      ++$counts{"${diffType}Lines"};
      ++$counts{"Lines"} if ($diffType);  ## count total lines in a diff
      if (/^\s*$/) {
         ++$counts{"${diffType}Blank"};
         next;
      } 

      ## The following is a KLUGE to distinguish C++ from C
      if ($LANG_NAME eq "C" && !($inComment || $inQuote)) {
         $LANG_NAME = "C++"
            if  m/(?: ^\s*
                      (?: \:\:\s*\w |
                          (?: class |
                              public \s* : |
                              private \s* : |
                              protected \s* : |
                              template \s* < | 
                              virtual | 
                              throw \s* [\(;] |
                              try \s* [{}] |
                              catch \s* \( |
                              dynamic_cast
                           )
                       )
                  \b) |
                  (?: ^[^\/"']*
                      (?: \b
                          (?: throw \s* [\(;] |
                              try \s* [{}] |
                              catch \s* \( |
                              dynamic_cast
                          )\b |
                          \:\:
                      )
                  )/x;
      }

      ## Perform any language-specific preprocessing
      my $expr;
      foreach $expr (@langEvals) {
         eval $expr;
      }
      ## See how many comments & statements are on this line
      my ($hasSource, $hasComment) = (0, 0);
      while ($_) {
         if ($inComment > 0) {
            ++$hasComment;
            if (m/$langDefns{'CMMNT_STATE'}/) {
               $_ = $';
               if (m/$langDefns{'CMMNT_NESTING'}/) {
                  --$inComment if ($langDefns{$&} eq $EndCmnt);
                  ++$inComment if (($langDefns{$&} eq $BeginCmnt) &&
                                   ($LANG_REF ne "C") && ($LANG_REF ne "Perl"));
               }
               else {
                  $inComment = 0  if ($langDefns{$&} eq $EndCmnt);
                  $inComment = 1  if ($langDefns{$&} eq $BeginCmnt);
               }
            }
            else {
               $_ = '';
            }
         }
         elsif ($inQuote) {
            ++$hasSource;
            if (m/$langDefns{"${inQuote}QUOTE_STATE"}/) {
               $_ = $';
               $inQuote = '' if ($& eq $langDefns{"END_${inQuote}"});
            }
            else {
               $_ = '';
            }
         }
         elsif (m/$langDefns{'START_STATE'}/) {
            $_ = $';
            if ($langDefns{$&} eq $EolCmnt) {
               ++$hasComment;
               ++$hasSource if ($` =~ /\S/);
               $_ = '';
            }
            elsif ($langDefns{$&} eq $BeginCmnt) {
               ++$hasComment;
               ++$hasSource if ($` =~ /\S/);
               $inComment = 1;
            }
            else {
               ++$hasSource;
               if ($langDefns{$&} eq $BeginQuote) {
                  $inQuote = $&;
               }
            }
         }
         else {
            ++$hasSource if (/\S/);
            $_ = '';
         }
      }
      ++$counts{"${diffType}NCSL"}  if ($hasSource);
      ++$counts{"${diffType}Cmnts"} if ($hasComment);
   }

   close($filehandle) unless ($filename eq '-');

   ## Determine Assembly Eqivalent counts
   my $aeFactor = $AssemblyEquivalence{$LANG_NAME};
   $aeFactor = $langDefns{'AESL'} unless ($aeFactor);
   $counts{'AESL'}  = ($counts{'NCSL'}  * $aeFactor) if ($counts{'NCSL'});
   $counts{'<AESL'} = ($counts{'<NCSL'} * $aeFactor) if ($counts{'<NCSL'});
   $counts{'>AESL'} = ($counts{'>NCSL'} * $aeFactor) if ($counts{'>NCSL'});

   %counts;
}

## Print a report line or header. We know it is a header if
## the first argument is a string and not a number.
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub PrintCounts {
   my ($lines, $blank, $cmnts, $ncsl, $aesl, $fname, $language) = @_;
   local $_;
   my ($fwidth, @nums);
   my $ll = 79;
   my $nwidth = 5;
   my $aewidth = 10;
   my ($ntype, $nfmt);
   if ($lines =~ /^\d+$/) {
      $ntype = 'd';
      $nfmt = "%${nwidth}${ntype}  ";
   }
   else {
      $ntype = 's';
      $nfmt = "%-${nwidth}${ntype}  ";
   }
   foreach ("lines", "blank", "cmnts", "ncsl", "aesl") {
      my $set = $CNTS{$_};
      next unless ($set);
      my $val = eval "\$$_";
      if (($ntype eq 'd') && ($_ eq "aesl")) {
         printf("%${aewidth}.1f  ", $val);
      }
      else {
         printf($nfmt, $val);
      }
      push(@nums, $_);
   }
   print "${fname}";
   print "  ($language)" if ($language);
   print "\n";
   if ($ntype eq 's') {
      ## need to print a header-bar
      my $fwidth = $ll;
      foreach (@nums) {
         my $width = ($_ eq "aesl") ? $aewidth : $nwidth;
         printf("%-${width}s  ", '=' x $width);
         $fwidth -= ($width + 2);
      }
      my $fbar = '=' x $fwidth;
      print "${fbar}\n";
   }
}

##----------------------------------------------------------------------
## FUNCTION:
##   ExpandDirectory -- Expand a directory into all its elements
##
## SYNOPSIS:
##   @elements = &ExpandDirectory($dir);
##
## ARGUMENTS:
##   $dir : The pathname of a directory
##
## RETURN VALUE:
##   An array containing the pathname of all elements in the directory
##   (NOT including '.' or '..').
##
## PRECONDITIONS:
##   Uses the global %TRAVERSED to keep track of which directories
##   have already been expanded (so we dont get into an infinite
##   directory exandning loop).
##
## SIDE EFFECTS:
##   Records the traversed directory in %TRAVERSED.
##----------------------------------------------------------------------
my %TRAVERSED = ();
sub ExpandDirectory {
   my($dir) = @_;
   my($absdir, @elements);
   local($_);
   unless ($Is_WinDos) {
       ## On Unix, make sure we dont traverse this directory twice
       ## due to symlinks
      my($absdir);
      chomp($absdir = `cd $dir && /bin/pwd`);
      return @elements if (defined $TRAVERSED{$absdir});
      ++$TRAVERSED{$absdir};
   }
   ## Open the directory for reading
   unless (opendir(DIRECTORY, $dir)) {
      &error_msg("Can't traverse directory $dir: $!");
      return @elements;
   }
   $dir = '' if ($dir eq $Path_Sep);  ## might be root
   ## Read all the directory entries
   while ($_ = readdir(DIRECTORY)) {
      next if (/^\.*$/);  ## ignore . and ..
      push(@elements, "${dir}${Path_Sep}$_");
   }
   closedir(DIRECTORY);
   (@elements);
}

##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub CountFiles {
   my @files = @_;
   local ($_);
   foreach (@files) {
      if (-d $_  && $OPTS{'recurse'}) {
         my @entries = &ExpandDirectory($_);
         &CountFiles(@entries);
         next;
      }
      ## See if we should exclude this file from the list
      next if (&ExcludeFile($_));
      if (-d $_  && $OPTS{'recurse'}) {
         &ErrorMsg("$_ is a directory.") unless ($OPTS{'ignore'});
         next;
      }
      if (-B _) {
         &ErrorMsg("$_ is a binary file.") unless ($OPTS{'ignore'});
         next;
      }
      ## See if we can determine the programming language
      ($LANG_NAME, $LANG_REF) = ('', '');
      &SetLanguage($_);
      &ErrorMsg("Can't determine programming language for $_")
            unless ($LANG_REF || $OPTS{'ignore'});
      next unless (exists $LANG_RULES{$LANG_REF});
      my %counts = &SourceCount($_, @{ $LANG_RULES{$LANG_REF} });
      next if ($counts{'Error'} || ($counts{'Lines'} == 0));
      &PrintCounts("Lines", "Blank", "Cmnts", " NCSL", "   AESL   ", "")
            if ((++$NumSources == 1) && $SECS{'header'});
      ++$NumSources{$LANG_NAME};
      my (@kindList, $kind) = ("");
      @kindList = ('<', '>') if ($OPTS{'diff'});
      for $kind (@kindList) {
         &PrintCounts($counts{"${kind}Lines"},
                      $counts{"${kind}Blank"},
                      $counts{"${kind}Cmnts"},
                      $counts{"${kind}NCSL"},
                      $counts{"${kind}AESL"},
                      "$_$KIND{$kind}", $LANG_NAME)
            if ($SECS{'files'});
         $Lines{"${kind}$LANG_NAME"} += $counts{"${kind}Lines"};
         $Blank{"${kind}$LANG_NAME"} += $counts{"${kind}Blank"};
         $Cmnts{"${kind}$LANG_NAME"} += $counts{"${kind}Cmnts"};
         $NCSL{"${kind}$LANG_NAME"}  += $counts{"${kind}NCSL"};
         $AESL{"${kind}$LANG_NAME"}  += $counts{"${kind}AESL"};
      }
   }
}

## Report the totals for each language and overall
##----------------------------------------------------------------------
## FUNCTION:
##
## SYNOPSIS:
##
## ARGUMENTS:
##
## RETURN VALUE:
##
## PRECONDITIONS:
##
## SIDE EFFECTS:
##----------------------------------------------------------------------
sub PrintTotals {
   local $_;
   my $str;
   my @languages = (keys %NumSources);
   my (@kindList, $kind) = ("");
   @kindList = ('<', '>') if ($OPTS{'diff'});
   my %totals = (
      'Lines'  => 0, 'Blank'  => 0, 'Cmnts'  => 0, 'NCSL'  => 0, 'AESL'  => 0,
      '<Lines' => 0, '<Blank' => 0, '<Cmnts' => 0, '<NCSL' => 0, '<AESL' => 0,
      '>Lines' => 0, '>Blank' => 0, '>Cmnts' => 0, '>NCSL' => 0, '>AESL' => 0
   );
   foreach (@languages) {
      for $kind (@kindList) {
         if ($SECS{'langtotals'}) {
            $str = sprintf("%s  (%d %s)",
                           "----- $_$KIND{$kind} -----",
                           $NumSources{$_},
                           ($NumSources{$_} == 1) ? 'file' : 'files');
            &PrintCounts($Lines{"${kind}$_"},
                         $Blank{"${kind}$_"},
                         $Cmnts{"${kind}$_"},
                         $NCSL{"${kind}$_"},
                         $AESL{"${kind}$_"},
                         $str);
         }
         $totals{"${kind}Lines"} += $Lines{"${kind}$_"};
         $totals{"${kind}Blank"} += $Blank{"${kind}$_"};
         $totals{"${kind}Cmnts"} += $Cmnts{"${kind}$_"};
         $totals{"${kind}NCSL"}  += $NCSL{"${kind}$_"};
         $totals{"${kind}AESL"}  += $AESL{"${kind}$_"};
      }
   }
   for $kind (@kindList) {
      $str = sprintf("%s  (%d %s)",
                     "***** TOTAL$KIND{$kind} *****",
                     $NumSources,
                     ($NumSources == 1) ? 'file' : 'files');
      &PrintCounts($totals{"${kind}Lines"},
                   $totals{"${kind}Blank"},
                   $totals{"${kind}Cmnts"},
                   $totals{"${kind}NCSL"},
                   $totals{"${kind}AESL"},
                   $str)
         if ($SECS{'totals'} && ((!$SECS{'langtotals'}) || (@languages > 1)));
   }
}

use Getopt::Long;

## main -- procedural interface to the script.
sub main {
   local @ARGV = @_;
   local $_;

   ## Default options
   $OPTS{'debug'}        = 0;
   $OPTS{'help'}         = 0;
   $OPTS{'delim_ignore'} = 0;
   $OPTS{'diff'}         = 0;
   $OPTS{'filelist'}     = 0;
   $OPTS{'ignore'}       = 0;
   $OPTS{'pred'}         = 0;
   $OPTS{'recurse'}      = 0;
   $OPTS{'counts'}       = "lines+blank+cmnts+ncsl";
   $OPTS{'sections'}     = "header+files+langtotals+totals";
   $OPTS{'fromversion'}  = "";
   $OPTS{'prefix'}       = "";
   $OPTS{'toversion'}    = "";
   $OPTS{'vcstring'}     = "";
   $OPTS{'language'}     = [];
   $OPTS{'name'}         = [];
   $OPTS{'except'}       = [];
   $OPTS{'separate'}     = [];

   ## Parse options
   my $rc = &GetOptions( \%OPTS,
      "debug",
      "help",
      "output=s",
      "counts=s",
      "delim_ignore|delim-ignore",
      "diff",
      "except=s@",
      "filelist",
      "fromversion=s",
      "ignore",
      "language=s@",
      "name=s@",
      "pred",
      "prefix=s",
      "recurse",
      "sections=s",
      "separate=s@",
      "toversion=s",
      "vcstring=s"
   );
   &Usage(1) if ($OPTS{'help'});
   &Usage(2) unless ($rc);
   &Usage(2) if ((@ARGV == 0) && (-t STDIN));

   ## Check for syntax errors
   if ($OPTS{'pred'} && $OPTS{'fromversion'}) {
      &ErrorMsg("The '-pred' and '-fromversion' options are incompatible!");
      ++$ERRORS;
   }
   &CheckLanguage(@{ $OPTS{'language'} }) if (@{ $OPTS{'language'} } > 0);
   &CheckSections($OPTS{'sections'}) if ($OPTS{'sections'});
   &CheckCounts($OPTS{'counts'}) if ($OPTS{'counts'});

   &Usage(2) if ($ERRORS);

   ## Redirect STDOUT if requested
   if ($OPTS{'output'}) {
      close STDOUT;
      open(STDOUT, ">$OPTS{'output'}")
         or &FatalMsg("Unable to redirect STDOUT to $OPTS{'output'}: $!");
   }

   if ($OPTS{'pred'} || $OPTS{'fromversion'} || $OPTS{'toversion'}) {
      ## Set mandatory options for using cdiff
      $OPTS{'diff'}     = 1;
      $OPTS{'separate'} = ['-----'];
   }
   %KIND = (
      '' , '',
      '<', ' DELETED',
      '>', ' INSERTED'
   );

   if (! $OPTS{'filelist'}) {
      @ARGV = ('-') if (0 == @ARGV);
      &CountFiles(@ARGV);
   }
   else {
      ## have to read list of filenames from input
      while (<>) {
         chomp;
         &CountFiles($_);
      }
   }
   &PrintTotals if (($SECS{'totals'} || $SECS{'langtotals'}) &&
                      ((! $SECS{'files'}) || ($NumSources > 1)));
}

#---------------------------------------------------------------------
package main;

&Sclc::main(@ARGV);   ##  unless ($DO_NOT_EXECUTE)


