use v6;
module C::Parser::CAST is export;

enum ExpressionTag is export <
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
>;

our %CDMap = %(
    'post++' => ExpressionTag::postinc,
    'post--' => ExpressionTag::postdec,
    'pre++' => ExpressionTag::preinc,
    'pre--' => ExpressionTag::predec,
    'pre&' => ExpressionTag::preref,
    'pre*' => ExpressionTag::prederef,
    'pre+' => ExpressionTag::prepos,
    'pre-' => ExpressionTag::preneg,
    '~'   => ExpressionTag::bitnot,
    '!'   => ExpressionTag::not, 
    '? :' => ExpressionTag::if_exp,
    '*'   => ExpressionTag::mul,
    '/'   => ExpressionTag::div,
    '%'   => ExpressionTag::mod,
    '+'   => ExpressionTag::add,
    '-'   => ExpressionTag::sub,
    '<<'  => ExpressionTag::bitshiftl,
    '>>'  => ExpressionTag::bitshiftr,
    '<'   => ExpressionTag::islt,
    '>'   => ExpressionTag::isgt,
    '<='  => ExpressionTag::isle,
    '>='  => ExpressionTag::isge,
    '=='  => ExpressionTag::iseq,
    '!='  => ExpressionTag::isne,
    '&'   => ExpressionTag::bitand,
    '^'   => ExpressionTag::bitxor,
    '|'   => ExpressionTag::bitor,
    '&&'  => ExpressionTag::and, 
    '||'  => ExpressionTag::or, 
    '*='  => ExpressionTag::assign_mul,
    '/='  => ExpressionTag::assign_div,
    '%='  => ExpressionTag::assign_mod,
    '+='  => ExpressionTag::assign_add,
    '-='  => ExpressionTag::assign_sub,
    '<<=' => ExpressionTag::assign_bitshiftl,
    '>>=' => ExpressionTag::assign_bitshiftr,
    '&='  => ExpressionTag::assign_bitand,
    '^='  => ExpressionTag::assign_bitxor,
    '|='  => ExpressionTag::assign_bitor,
    '='   => ExpressionTag::assign, 
);

our sub expr_tag_from_str(Str $op --> ExpressionTag) {
    return %CDMap{$op};
}

enum JumpTag is export <
    break
    continue
    goto
    goto_s
    return
>;

enum ConstantTag is export <
    integer
    real
    enum
    character
    string
    match
>;

enum StructureTag is export <
    struct_decl
    union_decl
    enum_decl
    nil_decl
>;

enum StorageSpecifierTag is export <
    auto
    register
    static
    extern
    typedef
    thread_local
>;

enum TypeSpecifierTag is export <
    void
    char
    short
    int
    long
    float
    double
    signed
    unsigned
    bool
    complex
    struct
    union
    enum_spec
    typedef_spec
    typeof_expr    
>;

enum TypeQualifierTag is export <
    const
    volatile 
    restrict 
    atomic
    attribute 
>;

enum FunctionSpecifierTag is export <
    inline
    noreturn
>;

# forward declarations

class Compound is export {}

class Statement is Compound is export {}

class Expression is Statement is export {}

# declaration specifiers

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
    has ConstantTag $.tag;
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

class FunctionSpecifier is DeclarationSpecifier is export {
    has FunctionSpecifierTag $.tag;
}

class AlignmentSpecifier is DeclarationSpecifier is export {}

class AlignAsTypeSpecifier is AlignmentSpecifier is export {
    has Identifier $.ident;
}

class AlignAsExprSpecifier is AlignmentSpecifier is export {
    has Expression $.expr;
}

class PostfixExpression is Expression is export {}

class InitializerMember is export {}

class Attribute is export {
    has Identifier $.ident;
    has Expression @.args;
}

class Declarator is export {
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

class TypeName is export {
    has Any @.specs;
    has Any $.decr;
}

class InitDeclarator is export {
    has Declarator $.decl;
    has Initializer $.init;
}

class DirectDeclarator is Declarator is export {
    has Any $.first;
    has Any @.rest;
}

class PointerDeclarator is Declarator is export {
    has TypeQualifier @.quals;
    has DirectDeclarator $.direct;
}

class AbstractDeclarator is Declarator is export {
    has Any $.first;
    has Any @.rest;
}

class ArrayDeclarator is Declarator is export {
    has TypeQualifier @.quals;
    has Expression $.size;
}

class FunctionDeclarator is Declarator is export {
    has Identifier $.ident;
    #has Declaration @.decls;
    has Attribute @.attrs;
}

class ParameterDeclaration is export {
    has DeclarationSpecifier @.decls;
    has Declarator $.decr;
}

class LabeledStatement is Statement is export {
    has Identifier $.ident;
    has Statement $.stmt;
}

class IfStatement is Statement is export {
    has Expression $.expr;
    has Statement $.con;
    has Statement $.alt;
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

class BlockStatement is Statement is export {
    has Compound @.items;
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
    has Compound $.init;  # C89 init, C99 init
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

class Type is export {}

class Var is export {
      has Type $.type;
      has Identifier $.ident;
}

class BitVar is Var is export {
      has Expression $.bitsize;
}

class EllipsisVar is Var is export {
}

class DirectType is Type is export {
      has DeclarationSpecifier @.specs;
}

class ArrayType is Type is export {
      has Type @.type;
      has Expression @.size;
}

class PointerType is Type is export {
      has Type @.type;
      has TypeQualifier @.quals;
}

class FunctionType is Type is export {
      has DirectType @.first;
      
}

class StructureType is Type is export {
      has StructureType @.tag;
      has Var @.fields;
}

# external declarations

class External is export {}

class Declaration is External is Compound is export {
    has DeclarationSpecifier @.specs;
    has InitDeclarator @.inits;
}

class TypeDefinition is External is export {
    has DeclarationSpecifier @.specs;
    has Identifier $.ident;
}

class FunctionDeclaration is External is export {
    has DeclarationSpecifier @.specs;
    has Declarator $.head;
    has Declaration @.ancients;
    has Statement $.body;
}

class AssemblyLiteral is External is export {
    has Str $.literal;
}

class TranslationUnit is export {
    has External @.decls;
}
