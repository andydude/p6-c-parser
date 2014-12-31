use v6;
module C::Parser::CAST;

#our %CDMap = {
#    'post++' => 'prog2:post_increment',
#    'post--' => 'prog2:post_decrement',
#    'pre++' => 'prog2:increment',
#    'pre--' => 'prog2:decrement',
#    'pre&' => 'ref1:referenceof',
#    'pre*' => 'ref1:dereference',
#    'pre+' => 'arith2:unary_plus',
#    'pre-' => 'arith1:unary_minus',
#    '~'   => 'bitwise1:not',
#    '!'   => 'logic1:not',
#    '? :' => 'prog2:if_exp',
#    '*'   => 'arith1:times',
#    '/'   => 'arith1:divide',
#    '%'   => 'integer1:remainder',
#    '+'   => 'arith1:plus',
#    '-'   => 'arith1:minus',
#    '<<'  => 'bitwise3:left_shift',
#    '>>'  => 'bitwise3:right_shift',
#    '<'   => 'relation1:lt',
#    '>'   => 'relation1:gt',
#    '<='  => 'relation1:leq',
#    '>='  => 'relation1:geq',
#    '=='  => 'relation1:eq',
#    '!='  => 'relation1:neq',
#    '&'   => 'bitwise1:and',
#    '^'   => 'bitwise1:xor',
#    '|'   => 'bitwise1:or',
#    '&&'  => 'logic1:and',
#    '||'  => 'logic1:or',
#    '*='  => 'prog2:assignment_operator',
#    '/='  => 'prog2:assignment_operator',
#    '%='  => 'prog2:assignment_operator',
#    '+='  => 'prog2:assignment_operator',
#    '-='  => 'prog2:assignment_operator',
#    '<<=' => 'prog2:assignment_operator',
#    '>>=' => 'prog2:assignment_operator',
#    '&='  => 'prog2:assignment_operator',
#    '^='  => 'prog2:assignment_operator',
#    '|='  => 'prog2:assignment_operator',
#    '='   => 'prog1:assignment'
#};

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

# forward declarations

class Declaration {...}

class Statement {}

class Expression {}

# declaration specifiers

class DeclarationSpecifier {}

class StorageSpecifier is DeclarationSpecifier {
    has StorageSpecifierTag $.tag;
}

class TypeSpecifier is DeclarationSpecifier {
    has TypeSpecifierTag $.tag;
}

class TypeQualifier is DeclarationSpecifier {
    has TypeQualifierTag $.tag;
}

class PrimaryExpression is Expression {}

class Identifier is PrimaryExpression {
    has Str $.name;
}

class Constant is PrimaryExpression {
    has ConstantTag $.type;
    has Identifier $.ident;
    has Num $.value; # WTF
}

class StringLiteral is PrimaryExpression {
    has Str $.literal;
}

class GenericAssociation {
    has Identifier $.ident;
    has Expression $.expr;
}

class GenericSelection is PrimaryExpression {
    has Expression $.expr;
    has GenericAssociation @.assocs;
}

class PostfixExpression is Expression {}

class InitializerMember {}

class Attribute {
    has Identifier $.ident;
    has Expression @.args;
}

class Declarator {
    has Bool $.pointer;
}

class Designation {
    has Declarator @.decrs;
}

class Initializer {
    has Expression $.expr;
    has InitializerMember @.inits;
}

class DesignationInitializer is InitializerMember {
    has Designation $.dsgn;
    has Initializer $.init;
}

class InitDeclarator {
    has Declarator $.decl;
    has Initializer $.init;
    has Expression $.expr;
}

class PointerDeclarator is Declarator {
    has TypeQualifier @.quals;
}

class ArrayDeclarator is Declarator {
    has TypeQualifier @.quals;
    has Expression $.size;
}

class FunctionDeclarator is Declarator {
    has Identifier $.ident;
    has Declaration @.decls;
    has Attribute @.attrs;
    has Bool $.ancient;
}

class LabeledStatement is Statement {
    has Identifier $.ident;
    has Statement $.stmt;
}

class SwitchStatement is Statement {
    has Expression $.expr;
    has Statement @.stmts;
}

class CaseStatement is Statement {
    has Expression $.expr;
    has Statement $.stmt;
}

class CasesStatement is Statement {
    has Expression $.from;
    has Expression $.expr;
    has Statement $.stmt;
}

class DefaultStatement is Statement {
    has Statement $.stmt;
}

class BlockItem {
    has Declaration $.decl;
    has Statement $.stmt;
}

class BlockStatement is Statement {
    has BlockItem @.items;
}

class ExpressionStatement is Statement {
    has Expression $.expr;
}

class WhileStatement is Statement {
    has Expression $.test;
    has Statement $.body;
}

class DoWhileStatement is Statement {
    has Statement $.body;
    has Expression $.test;
}

class ForStatement is Statement {
    has Declaration $.decl; # C99 init
    has Expression $.init;  # C89 init
    has Expression $.test;
    has Expression $.step;
    has Statement $.body;
}

class JumpStatement is Statement {
    has JumpTag $.tag;
    has Expression $.expr;
    has Str $.label;
}

class AssemblyOperand {
    has Identifier $.ident;
    has Str $.literal;
    has Expression $.expr;
}

class AssemblyStatement is Statement {
    has TypeQualifier $.qual;
    has Str $.literal;
    has Str @.clobbers;
    has AssemblyOperand @.inputs;
    has AssemblyOperand @.outputs;
}

# external declarations

class ExternalDeclaration {}

class Declaration is ExternalDeclaration {
    has DeclarationSpecifier @.modifiers;
    has InitDeclarator @.inits;
}

class TypeDefDeclaration is ExternalDeclaration {
    has DeclarationSpecifier @.specs;
    has Identifier $.ident;
}

class FunctionDeclaration is ExternalDeclaration {
    has DeclarationSpecifier @.modifiers;
    has Declarator $.head;
    has Declaration @.ancients;
    has Statement $.body;
}

class AssemblyDeclaration is ExternalDeclaration {
    has Str $.literal;
}

class TranslationUnit {
    has ExternalDeclaration @.decls;
}
