p6-c-parser
===========

Grammar for Parsing C in Perl6


Introduction
------------

*WARNING* This parser is not production ready. It is experimental, and a work in progress.
If you would like to try it out, the recommended way is:
`my $match = C::Parser::StdC11Parser.parse($source);`
because I have plans to add non-standard extensions, such as Apple, GNU, MS, etc.

Another thing to note is that it doesn't provide any understanding of C preprocessor
directives, so you will have to use `gcc -E` (or the like) before parsing it. This
can usually be accomplished by:

`gcc -E FILE.c | grep -v '^#' | bin/cdump.pl6 -`

Conclusion
----------

Don't write a compiler with this just yet.

