use v6;
use CAST::Node;
use CAST::Parent;
class CAST::Type is CAST::Node does CAST::Parent;

enum TypeKind <
    array_type
    atomic_type
    direct_type
    enum_type
    function_type
    pointer_type
    struct_type
    union_type
>;

enum TypeSpec < 
    atomic
    attribute 
    auto
    bool
    char
    complex
    const
    double
    enum_spec
    extern
    float
    inline
    int
    long
    noreturn
    register
    restrict 
    short
    signed
    static
    struct
    thread_local
    typedef
    typedef_spec
    typeof_expr    
    union
    unsigned
    void
    volatile 
>;

method new (TypeKind $kind, TypeSpec @specs) {
    my @children = @specs;
    @children.unshift($kind);
    CAST::Node.new(:@children)
}