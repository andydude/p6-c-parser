use v6;
use CAST::Node;
use CAST::Type;
use CAST::Typed;
use CAST::Children;
class CAST::PtrType
is CAST::Node
does CAST::Type
does CAST::Typed
does CAST::Children;
# has Spec @.children

method deionize($ident) {
    return self.type;
}

method ionize($type) {
    self.type = $type;

    return Nil;
}
