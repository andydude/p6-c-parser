use v6;
use C::Parser::CASTActions;
use C::Parser::StdC11Parser;

module C::Parser {
    our sub parse($line) {
        my $actions = C::Parser::CASTActions.new();
        return C::Parser::StdC11Parser.parse($line, :$actions);
    }
}