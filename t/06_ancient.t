#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use C::Parser::StdC11Parser;

our $source = q<<<
    int printf(const char *, ...);
    
    int main(argc, argv)
        int argc; char * argv[];
    {
        printf("Hello %s!", argv[1]);
        return 0;
    }
>>>;

{
    my $match = C::Parser::StdC11Parser.parse($source);
    isa_ok($match, Match, 'gives a Match');
}
