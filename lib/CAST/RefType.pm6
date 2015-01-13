use v6;
use CAST::Node;
use CAST::Children;
class CAST::StructType
    is CAST::Node
    does CAST::Ident
    does CAST::Children;

enum StructKind <
    struct
    union
    enum
>;

has StructKind $.kind;