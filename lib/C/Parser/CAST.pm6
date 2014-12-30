use v6;
module C::CAST;

our %CDMap = {
    'post++' => 'prog2:post_increment',
    'post--' => 'prog2:post_decrement',
    'pre++' => 'prog2:increment',
    'pre--' => 'prog2:decrement',
    'pre&' => 'ref1:referenceof',
    'pre*' => 'ref1:dereference',
    'pre+' => 'arith2:unary_plus',
    'pre-' => 'arith1:unary_minus',
    '~'   => 'bitwise1:not',
    '!'   => 'logic1:not',
    '? :' => 'prog2:if_exp',
    '*'   => 'arith1:times',
    '/'   => 'arith1:divide',
    '%'   => 'integer1:remainder',
    '+'   => 'arith1:plus',
    '-'   => 'arith1:minus',
    '<<'  => 'bitwise3:left_shift',
    '>>'  => 'bitwise3:right_shift',
    '<'   => 'relation1:lt',
    '>'   => 'relation1:gt',
    '<='  => 'relation1:leq',
    '>='  => 'relation1:geq',
    '=='  => 'relation1:eq',
    '!='  => 'relation1:neq',
    '&'   => 'bitwise1:and',
    '^'   => 'bitwise1:xor',
    '|'   => 'bitwise1:or',
    '&&'  => 'logic1:and',
    '||'  => 'logic1:or',
    '*='  => 'prog2:assignment_operator',
    '/='  => 'prog2:assignment_operator',
    '%='  => 'prog2:assignment_operator',
    '+='  => 'prog2:assignment_operator',
    '-='  => 'prog2:assignment_operator',
    '<<=' => 'prog2:assignment_operator',
    '>>=' => 'prog2:assignment_operator',
    '&='  => 'prog2:assignment_operator',
    '^='  => 'prog2:assignment_operator',
    '|='  => 'prog2:assignment_operator',
    '='   => 'prog1:assignment'
};

enum ExpressionTag <
    post++
    post--
    pre++
    pre--
    pre&
    pre*
    pre+
    pre-
    bitnot
    not
    if_exp
    times
    divide
    remainder
    plus
    minus
    left_shift
    right_shift
    lt
    gt
    leq
    geq
    eq
    neq
    bitand
    bitxor
    bitor
    and
    or
    =
    times=
    divide=
    remainder=
    plus=
    minus=
    left_shift=
    right_shift=
    bitand=
    bitxor=
    bitor=
>;

enum JumpTag <
    break
    continue
    goto
    goto*
    return
>;

enum ConstantTag <
    integer
    real
    enum
    character
>;

enum StructureTag <
    struct
    union 
>;

enum StorageSpecifierTag <
    auto
    register
    static
    extern
    typedef
    thread_local
>;

enum TypeSpecifierTag < 
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
    enum
    typedef
    typeof_expr    
>;

enum TypeQualifierTag <
    const
    volatile 
    restrict 
    inline 
    attribute 
>;

class DeclarationSpecifier {}

class StorageSpecifier is DeclarationSpecifier {
    has StorageSpecifierTag $tag;
}

class TypeSpecifier is DeclarationSpecifier {
    has TypeSpecifierTag $tag;
}

class TypeQualifier is DeclarationSpecifier {
    has TypeQualifierTag $tag;
}

class Expression {}

class PrimaryExpression is Expression {}

class Identifier is PrimaryExpression {
    has Str $name;
}

class Constant is PrimaryExpression {
    has ConstantTag $type;
    has Str $name;
    has Num $value;
}

class StringLiteral is PrimaryExpression {
    has Str $literal;
}

class GenericAssociation {
    has Str $typename;
    has Expression $expr;
}

class GenericSelection is PrimaryExpression {
    has Expression $expr;
    has GenericAssociation @assocs;
}

class PostfixExpression is Expression {}

class InitializerMember {}

class Attribute {
    has Str $ident;
    has Expression @args;
}

class Declarator {
    has Bool $pointer;
}

class Designation {
    has Declarator @decrs;
}

class Initializer {
    has Expression $expr;
    has InitializerMember @inits;
}

class DesignationInitializer is InitializerMember {
    has Designation $desn;
    has Initializer $init;
}

class InitDeclarator {
    has Declarator $decl;
    has Initializer $init;
    has Expression $expr;
}

class ExternalDeclaration {}

class Declaration is ExternalDeclaration {
    has DeclarationSpecifier @modifiers;
    has InitDeclarator @inits;
}

class PointerDeclarator is Declarator {
    has TypeQualifier @quals;
}

class ArrayDeclarator is Declarator {
    has TypeQualifier @quals;
    has Expression $size;
}

class FunctionDeclarator is Declarator {
    has Str $ident;
    has Bool $ancient;
    has Declaration @decls;
    has Attribute @attrs;
}

class Statement {}

class LabeledStatement is Statement {
    has Str $ident;
    has Statement $stmt;
}

class SwitchStatement is Statement {
    has Expression $expr;
    has Statement @stmts;
}

class CaseStatement is Statement {
    has Expression $expr;
    has Statement $stmt;
}

class CasesStatement is Statement {
    has Expression $from;
    has Expression $expr;
    has Statement $stmt;
}

class DefaultStatement is Statement {
    has Statement $stmt;
}

class BlockItem {
    has Declaration $decl;
    has Statement $stmt;
}

class BlockStatement is Statement {
    has BlockItem @items;
}

class ExpressionStatement is Statement {
    has Expression $expr;
}

class WhileStatement is Statement {
    has Expression $expr;
    has Statement $stmt;
}

class DoWhileStatement is Statement {
    has Statement $stmt;
    has Expression $expr;
}

class ForStatement is Statement {
    has Declaration $decl; # C99 init
    has Expression $init;  # C89 init
    has Expression $test;
    has Expression $step;
    has Statement $body;
}

class JumpStatement is Statement {
    has JumpTag $tag;
    has Expression $expr;
    has Str $label;
}

class AssemblyOperand {
    has Str $ident;
    has Str $literal;
    has Expression $expr;
}

class AssemblyStatement is Statement {
    has TypeQualifier $qual;
    has Str $literal;
    has Str @clobbers;
    has AssemblyOperand @inputs;
    has AssemblyOperand @outputs;
}

class TypeDefDecl is ExternalDeclaration {
    has DeclarationSpecifier @specs;
    has Str $name;
}

class FunctionDecl is ExternalDeclaration {
    has DeclarationSpecifier @modifiers;
    has Declarator $head;
    has Declaration @ancients;
    has Statement $body;
}

class AssemblyDecl is ExternalDeclaration {
    has Str $literal;
}

class TranslationUnit {
    has ExternalDeclaration @decls;
}
