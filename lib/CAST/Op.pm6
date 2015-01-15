use v6;
use CAST::Node;
use CAST::Children;
use CAST::OpKind;
class CAST::Op
    is CAST::Node
    does CAST::Children;

has CAST::OpKind::OpKind $.op;
