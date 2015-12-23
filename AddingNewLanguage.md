# Introduction #

Here's how to add a new language to sclc. As an example, we'll use [IDL](http://en.wikipedia.org/wiki/IDL_(programming_language)), a language often used by scientists for visualizing data.

What we need to know about IDL:

  * Files end in the .pro extension
  * The semicolon (;) indicates a comment line
  * strings are either single-quoted (') or double-quoted (")
  * Keywords are: pro, return, begin, end, if, then, else, endif, for, do, endfor, case, of, endcase

## What to do (short version) ##

```
my @Languages = (
...
      'IDL'
);

...
=item S<>

Ada,
...
Text,
IDL

=back

...

my %IDL_KEYWORDS;
@IDL_KEYWORDS{
    qw(pro return begin end 
       if then else endif
       for do endfor 
       case of endcase)} = undef;

my @IDL_EVALS = (
's/;/\001/g',   ## denote ';' comments with \001
);

my %IDL_DEFNS = ( 'AESL'         => 15.0,
                  'START_STATE'  =>"[\001'\"]",
                  '"QUOTE_STATE' => '\\\\.|"',
                  'END_"'        => '"',
                  "'QUOTE_STATE" => "\\\\.|'",
                  "END_'"        => "'",
                   "\001"        => $EolCmnt,
                   "'"           => $BeginQuote,
                   '"'           => $BeginQuote,
                   'KEYWORD'     => 'exists $IDL_KEYWORDS{$1}'
           );
$LANG_RULES{'IDL'} = [ \@IDL_EVALS, \%IDL_DEFNS ];	
...
my %Suffixes = (
   ...
   ## IDL
      ".pro" => "IDL",
   ...
);
```



## What to do (long version) ##

Here are the changes you need to make to the src/sclc file.

Add the language to the @Languages array:

```
my @Languages = (
...
      'IDL'
);
```

Add the language to the POD documentation comment:

```
=item S<>

Ada,
...
Text,
IDL

=back
```


Create an %IDL\_KEYWORDS hash, where the keys are keywords in the IDL language, and the value mapped to is undef.

```
my %IDL_KEYWORDS;
@IDL_KEYWORDS{
    qw(pro return begin end 
       if then else endif
       for do endfor 
       case of endcase)} = undef;
```

Create an @IDL\_EVALS array. The elements of this array are regular expressions that are applied to IDL source code.

For IDL, all we need to do is transform the semicolon (;) to \001. This is the language-independent comment delimiter used internally by sclc.

```
my @IDL_EVALS = (
's/;/\001/g',   ## denote ';' comments with \001
);
```

The %IDL\_DEFNS hash contains a number of different values.

The first entry, _AESL_, stands for assembly-equivalent source lines. It represents how many lines of assembly you would typically have to write per line of IDL. This value is intended to take into account the fact that higher-level languages are more powerful than lower-level languages. We never actually use this value, but by convention we choose "15" since what has been chosen for shell scripts.

```
my %IDL_DEFNS = ( 'AESL'         => 15.0,
```

Sclc works as a state machine. It assumes that the text is source code until it reaches a delimiter that would indicate a change of state to a comment or a quoted string. the _START\_STATE_ entry is a regular expression that tells sclc to switch states. We use it here to switch states to a comment (\001) or to a quoted string (single or double quotes)


```
                  'START_STATE'  =>"[\001'\"]",

```

We need to inform sclc how to behave when inside a quoted string. For specifying behavior for the double quote, we use the **"QUOTE\_STATE and _END_"** entries in the hash. (Note that the first one starts with double-quote, and the second one ends with double-quote).

I confess that I do not know why the **"QUOTE\_STATE** will also match the pattern \\\\.

```
                  '"QUOTE_STATE' => '\\\\.|"',
                  'END_"'        => '"',

```

Similarly, for single-quoted strings:

```
                  "'QUOTE_STATE" => "\\\\.|'",
                  "END_'"        => "'",
```

We all specify the tokens that indicate single-line comments and quotes:
```
                   "\001"         => $EolCmnt,
                   "'"            => $BeginQuote,
                   '"'            => $BeginQuote,
```

We pass in our hash of keywords:
```
                   'KEYWORD'      => 'exists $IDL_KEYWORDS{$1}'
           );
	
```

Finally, we add the IDL rules to sclc:
```
$LANG_RULES{'IDL'} = [ \@IDL_EVALS, \%IDL_DEFNS ];	
```


Add an entry to the %Suffixes hash to indicate that files that end in .pro are IDL files:


```
my %Suffixes = (
   ...
   ## IDL
      ".pro" => "IDL",
   ...
```