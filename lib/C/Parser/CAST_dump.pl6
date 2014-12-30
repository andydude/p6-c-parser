use v6;
use C::Parser::StdC11Parser;
use C::Parser::StdC11Actions;

my $source = @*ARGS[0];
my $actions = C::StdC11Actions.new();
say C::Parser::StdC11Parser.parse($source, :$actions);
