use v6;
use CAST::Args;
use CAST::Block;
use CAST::Ident;
use CAST::Node;
use CAST::Children;
use CAST::Var;
class CAST::FuncDef
    is CAST::Var
    is CAST::Block
    does CAST::Ident
    does CAST::Children;

has @.specs;
has $.head;
has @.ancients;
has $.body;
