#!/usr/bin/env perl6
use v6;
use Test;
plan 1;
use C::Parser::CAST;
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
    isa_ok($ast.ast, TranslationUnit, 'gives a TranslationUnit');
}
