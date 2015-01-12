use v6;
use CAST::Node;
use CAST::Parent;
class CAST::Op is CAST::Node does CAST::Parent;

enum OpKind <
    postinc
    postdec
    preinc
    predec
    preref
    prederef
    prepos
    preneg
    bitand
    bitnot
    bitor
    bitshiftl
    bitshiftr
    bitxor
    add
    and
    div
    if_exp
    iseq
    isge
    isgt
    isle
    islt
    isne
    mod
    mul
    not
    or
    sub
    assign
    assign_mul
    assign_div
    assign_mod
    assign_add
    assign_sub
    assign_bitshiftl
    assign_bitshiftr
    assign_bitand
    assign_bitxor
    assign_bitor
    sizeof_expr
    sizeof_type
    alignof_type
    alignas_type
    alignas_expr
    call
    break
    continue
    goto
    goto_s
    return
>;

has OpKind $.op;

method new (OpKind $operator, *@operands) {
    $.op = $operator
    @.children = @operands;
#    my @children = ;
#    @children.unshift($operator);
#    CAST::Node.new(:@children)
}