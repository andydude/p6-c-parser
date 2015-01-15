use v6;
use CAST::Node;
use CAST::Children;
class CAST::DirectType
is CAST::Node
does CAST::Type
does CAST::Children;
# has Spec @children

method deionize($ident) {
    return self.type;
}

method ionize($type) {
    self.type = $type;

    return Nil;
}
