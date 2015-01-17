use v6;
use C::Parser::Actions;
use C::Parser::Grammar;
class C::Parser;

method parse($line) {
    my $actions = C::Parser::Actions.new();
    return C::Parser::Grammar.parse($line, :$actions);
}
