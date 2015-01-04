#!/usr/bin/env perl6
use v6;
use Test;
plan 8;
use C::Parser::StdC11Lexer;

#{
#    my $source = q<<< char newline = '\n'; >>>;
#    my $ast = C::Parser::StdC11Lexer.parse($source);
#    isa_ok $ast, Match, 'gives a Match';
#}
#
#{
#    my $source = q<<< char *name = "world"; >>>;
#    my $ast = C::Parser::StdC11Lexer.parse($source);
#    isa_ok $ast, Match, 'gives a Match';
#}

{
    my $source = q<<< int number = 5; >>>;
    my $ast = C::Parser::StdC11Lexer.parse($source);
    isa_ok $ast, Match, 'gives a Match';

    my @tokens = $ast{'c-tokens'}{'c-token'};
    say @tokens.perl;
    say @tokens;
    is @tokens[0].Str, 'char ',     '1st token';
    is @tokens[1].Str, 'newline ',  '2nd token';
    is @tokens[2].Str, '= ',        '3rd token';
    is @tokens[3].Str, "'\n'",		'4th token';
    is @tokens[4].Str, ";\n",		'5th token';
}

{
    my $source = q<<< double pi64 = 3.14; >>>;
    my $ast = C::Parser::StdC11Lexer.parse($source);
    isa_ok $ast, Match, 'gives a Match';
}
