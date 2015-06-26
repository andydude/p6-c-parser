#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use C::AST;
use C::Parser;

our $source = q<<<
    typedef union {
        char __mbstate8[128];
    } __mbstate_t;
>>>;

{
    my $ast = C::Parser.parse($source);
    isa-ok($ast, C::AST::TransUnit, 'gives a C::AST::TransUnit');
}
