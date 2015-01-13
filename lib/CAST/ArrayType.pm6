use v6;
use CAST::Node;
use CAST::Type;
use CAST::Typed;
use CAST::Children;
class CAST::ArrayType
is CAST::Node
does CAST::Type
does CAST::Typed
does CAST::Children;
# has Spec @children
has Int $.size;
