use v6;
module C::Parser::CAST is export;

enum ExpressionTag is export <
    post_increment
    post_decrement
    pre_increment
    pre_decrement
    pre_reference
    pre_dereference
    pre_positive
    pre_negative
    bitand
    bitnot
    bitor
    bitxor
    divide
    and
    eq
    geq
    gt
    if_exp
    left_shift
    leq
    lt
    minus
    neq
    not
    or
    plus
    remainder
    right_shift
    times
    assign
    assign_times
    assign_divide
    assign_remainder
    assign_plus
    assign_minus
    assign_left_shift
    assign_right_shift
    assign_bitand
    assign_bitxor
    assign_bitor
>;

our %CDMap = %(
    'post++' => ExpressionTag::post_increment,
    'post--' => ExpressionTag::post_decrement,
    'pre++' => ExpressionTag::pre_increment,
    'pre--' => ExpressionTag::pre_decrement,
    'pre&' => ExpressionTag::pre_reference,
    'pre*' => ExpressionTag::pre_dereference,
    'pre+' => ExpressionTag::pre_positive,
    'pre-' => ExpressionTag::pre_negative,
    '~'   => ExpressionTag::bitnot,
    '!'   => ExpressionTag::not, 
    '? :' => ExpressionTag::if_exp,
    '*'   => ExpressionTag::times,
    '/'   => ExpressionTag::divide,
    '%'   => ExpressionTag::remainder,
    '+'   => ExpressionTag::plus,
    '-'   => ExpressionTag::minus,
    '<<'  => ExpressionTag::left_shift,
    '>>'  => ExpressionTag::right_shift,
    '<'   => ExpressionTag::lt,
    '>'   => ExpressionTag::gt,
    '<='  => ExpressionTag::leq,
    '>='  => ExpressionTag::geq,
    '=='  => ExpressionTag::eq,
    '!='  => ExpressionTag::neq,
    '&'   => ExpressionTag::bitand,
    '^'   => ExpressionTag::bitxor,
    '|'   => ExpressionTag::bitor,
    '&&'  => ExpressionTag::and, 
    '||'  => ExpressionTag::or, 
    '*='  => ExpressionTag::assign_times,
    '/='  => ExpressionTag::assign_divide,
    '%='  => ExpressionTag::assign_remainder,
    '+='  => ExpressionTag::assign_plus,
    '-='  => ExpressionTag::assign_minus,
    '<<=' => ExpressionTag::assign_left_shift,
    '>>=' => ExpressionTag::assign_right_shift,
    '&='  => ExpressionTag::assign_bitand,
    '^='  => ExpressionTag::assign_bitxor,
    '|='  => ExpressionTag::assign_bitor,
    '='   => ExpressionTag::assign, 
);

our sub expr_tag_from_str(Str $op --> ExpressionTag) {
    return %CDMap{$op};
}

enum JumpTag is export <
    JT_break
    JT_continue
    JT_goto
    JT_goto_s
    JT_return
>;

enum ConstantTag is export <
    integer
    real
    enum
    character
    match
>;

enum StructureTag is export <
    ST_struct
    ST_union
    ST_enum
    ST_nil
>;

enum StorageSpecifierTag is export <
    SS_auto
    SS_register
    SS_static
    SS_extern
    SS_typedef
    SS_thread_local
>;

enum TypeSpecifierTag is export < 
    TS_void
    TS_char
    TS_short
    TS_int
    TS_long
    TS_float
    TS_double
    TS_signed
    TS_unsigned
    TS_bool
    TS_complex
    TS_struct
    TS_union
    TS_enum
    TS_typedef
    TS_typeof_expr    
>;

enum TypeQualifierTag is export <
    TQ_const
    TQ_volatile 
    TQ_restrict 
    TQ_inline 
    TQ_attribute 
>;



# forward declarations

class Declaration is export {...}

class Statement is export {}

class Expression is export {}

# declaration specifiers

class DeclarationSpecifier is export {}

class StorageSpecifier is DeclarationSpecifier is export {
    has StorageSpecifierTag $.tag;
}

class TypeSpecifier is DeclarationSpecifier is export {
    has TypeSpecifierTag $.tag;
}

class TypeQualifier is DeclarationSpecifier is export {
    has TypeQualifierTag $.tag;
}

class OpExpression is export {
    has ExpressionTag $.tag;
    has Expression @.args;
}

#class CallExpression is export {
#    has Expression $first;
#    has Expression @.args;
#}

class PrimaryExpression is Expression is export {}

class Identifier is PrimaryExpression is export {
    has Str $.name;
}

class Constant is PrimaryExpression is export {
    has ConstantTag $.type;
    has Identifier $.ident;
    has Any $.value; # WTF
}

class StringLiteral is PrimaryExpression is export {
    has Str $.literal;
}

class GenericAssociation is export {
    has Identifier $.ident;
    has Expression $.expr;
}

class GenericSelection is PrimaryExpression is export {
    has Expression $.expr;
    has GenericAssociation @.assocs;
}

class PostfixExpression is Expression is export {}

class InitializerMember is export {}

class Attribute is export {
    has Identifier $.ident;
    has Expression @.args;
}

class Declarator is export {
    has Bool $.pointer;
}

class Designation is export {
    has Declarator @.decrs;
}

class Initializer is export {
    has Expression $.expr;
    has InitializerMember @.inits;
}

class DesignationInitializer is InitializerMember is export {
    has Designation $.dsgn;
    has Initializer $.init;
}

class InitDeclarator is export {
    has Declarator $.decl;
    has Initializer $.init;
    has Expression $.expr;
}

class PointerDeclarator is Declarator is export {
    has TypeQualifier @.quals;
}

class ArrayDeclarator is Declarator is export {
    has TypeQualifier @.quals;
    has Expression $.size;
}

class FunctionDeclarator is Declarator is export {
    has Identifier $.ident;
    has Declaration @.decls;
    has Attribute @.attrs;
    has Bool $.ancient;
}

class LabeledStatement is Statement is export {
    has Identifier $.ident;
    has Statement $.stmt;
}

class SwitchStatement is Statement is export {
    has Expression $.expr;
    has Statement @.stmts;
}

class CaseStatement is Statement is export {
    has Expression $.expr;
    has Statement $.stmt;
}

class CasesStatement is Statement is export {
    has Expression $.from;
    has Expression $.expr;
    has Statement $.stmt;
}

class DefaultStatement is Statement is export {
    has Statement $.stmt;
}

class BlockItem is export {
    has Declaration $.decl;
    has Statement $.stmt;
}

class BlockStatement is Statement is export {
    has BlockItem @.items;
}

class ExpressionStatement is Statement is export {
    has Expression $.expr;
}

class WhileStatement is Statement is export {
    has Expression $.test;
    has Statement $.body;
}

class DoWhileStatement is Statement is export {
    has Statement $.body;
    has Expression $.test;
}

class ForStatement is Statement is export {
    has Declaration $.decl; # C99 init
    has Expression $.init;  # C89 init
    has Expression $.test;
    has Expression $.step;
    has Statement $.body;
}

class JumpStatement is Statement is export {
    has JumpTag $.tag;
    has Expression $.expr;
    has Str $.label;
}

class AssemblyOperand is export {
    has Identifier $.ident;
    has Str $.literal;
    has Expression $.expr;
}

class AssemblyStatement is Statement is export {
    has TypeQualifier $.qual;
    has Str $.literal;
    has Str @.clobbers;
    has AssemblyOperand @.inputs;
    has AssemblyOperand @.outputs;
}

# external declarations

class ExternalDeclaration is export {}

class Declaration is ExternalDeclaration is export {
    has DeclarationSpecifier @.modifiers;
    has InitDeclarator @.inits;
}

class TypeDefDeclaration is ExternalDeclaration is export {
    has DeclarationSpecifier @.specs;
    has Identifier $.ident;
}

class FunctionDeclaration is ExternalDeclaration is export {
    has DeclarationSpecifier @.modifiers;
    has Declarator $.head;
    has Declaration @.ancients;
    has Statement $.body;
}

class AssemblyDeclaration is ExternalDeclaration is export {
    has Str $.literal;
}

class TranslationUnit is export {
    has ExternalDeclaration @.decls;
}
