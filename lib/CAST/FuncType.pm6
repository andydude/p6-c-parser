use v6;
use CAST::Node;
use CAST::Type;
use CAST::Typed;
use CAST::Ident;
use CAST::Children;
class CAST::FuncType
is CAST::Node
does CAST::Type
does CAST::Typed
does CAST::Ident
does CAST::Children;
# has Arg @children

method deionize($ident) {
    self.ident = $ident;
    return self.type;
}

method ionize($type) {
    self.type = $type;
    return self.ident;
}
