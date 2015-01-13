use v6;
use CAST::Node;
use CAST::Ident;
use CAST::Typed;
class CAST::Var
    is CAST::Node
    does CAST::Ident
    does CAST::Typed;
