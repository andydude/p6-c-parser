use v6;
use C::Parser::CASTActions;
use C::Parser::StdC11Parser;

class C::Parser;

method parse($line) {
    my $actions = C::Parser::CASTActions.new();
    return C::Parser::StdC11Parser.parse($line, :$actions);
}
