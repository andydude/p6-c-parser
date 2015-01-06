#!/usr/bin/env perl6
use v6;
use Test;
plan 1;

use C::Parser::StdC11Parser;

our $source = q<<<
    typedef void * FILE;
    extern int getc (FILE *__stream);
>>>;

{
    my $match = C::Parser::StdC11Parser.parse($source);
    is($match.WHAT.perl, 'Match', 'gives a Match');
}
