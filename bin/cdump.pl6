#!/usr/bin/env perl6 -I lib
use v6;
use C::Parser::CASTActions;
use C::Parser::StdC11Lexer;
use C::Parser::StdC11Parser;

sub MAIN (Str $input = "-",
#    Str :$output = "-",
#    Str :$inlang = "c11",
    Str :$oformat = "nil",
    Str :$actions = "nil",
    Bool :$lexonly = False,
    Bool :$preproc = False)
{
    my $source = ($input eq "-") ?? slurp($*IN) !! slurp($input);
    my $parser = $lexonly ?? C::Parser::StdC11Lexer !! C::Parser::StdC11Parser;
    my $ast;

    #if $preproc {
    #    # preprocess
    #}

    given $actions {
        when "nil" {
            $ast = $parser.parse($source);
        }
        when "cast" {
            my $actions = C::Parser::CASTActions.new();
            $ast = $parser.parse($source, :$actions);
        }
        default {
            die "unknown $actions, must be one of: nil, cast."
        }
    }

    given $oformat {
        when "nil" {
            say $ast;
        }
        when "str" {
            say $ast.Str;
        }
        when "perl" {
            say $ast.perl;
        }
        default {
            say $ast;
            die "unknown $oformat, must be one of: nil, str, perl."
        }
    }
    
    return 0;
}

Nil