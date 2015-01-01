#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use C::Parser::CASTActions;
use C::Parser::StdC11Parser;

our $source = q<<<
    int main() {
        puts("Hello World!");
        return 0;
    }
>>>;

{
    my $actions = C::Parser::CASTActions.new();
    my $ast = C::Parser::StdC11Parser.parse($source, :$actions);
    is($ast.WHAT.perl, 'TranslationUnit', 'gives a TranslationUnit');
}
