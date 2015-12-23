# Coding style conventions #

## Tabs & spaces ##

  * Use spaces instead of tabs for indentation (soft tabs)
  * A "tab" is 4 spaces

## Comments ##

  * Document each function's parameter, usage, and etc
  * Inline comment should be put as a separate line above the statement with the same indent

## Braces ##

  * Use the K&R style for bracing
  * A reference link can be found at [Wikipedia](http://en.wikipedia.org/wiki/Indent_style)

## Blank ##

  * One blank between operator and brace
  * No blank between brace and operand

## Other Perlisms ##

  * Don't precede functions with ampersands. This is a legacy Perl-ism in the code and should be expunged.

# Testing conventions #
  * Before committing, run an "ant alltest"
  * When adding support for a new language, add an example file to lib/examples and add a test.