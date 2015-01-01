use v6;
module C::Parser::CAST is export;

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
    ET_post++
    ET_post--
    ET_pre++
    ET_pre--
    ET_pre&
    ET_pre*
    ET_pre+
    ET_pre-
    ET_bitnot
    ET_not
    ET_if_exp
    ET_times
    ET_divide
    ET_remainder
    ET_plus
    ET_minus
    ET_left_shift
    ET_right_shift
    ET_lt
    ET_gt
    ET_leq
    ET_geq
    ET_eq
    ET_neq
    ET_bitand
    ET_bitxor
    ET_bitor
    ET_and
    ET_or
    ET_=
    ET_times=
    ET_divide=
    ET_remainder=
    ET_plus=
    ET_minus=
    ET_left_shift=
    ET_right_shift=
    ET_bitand=
    ET_bitxor=
    ET_bitor=
>;

enum JumpTag <
    JT_break
    JT_continue
    JT_goto
    JT_goto_s
    JT_return
>;

enum ConstantTag <
    CT_integer
    CT_real
    CT_enum
    CT_character
>;

enum StructureTag <
    ST_struct
    ST_union 
>;

enum StorageSpecifierTag <
    SS_auto
    SS_register
    SS_static
    SS_extern
    SS_typedef
    SS_thread_local
>;

enum TypeSpecifierTag < 
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

enum TypeQualifierTag <
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

class PrimaryExpression is Expression is export {}

class Identifier is PrimaryExpression is export {
    has Str $.name;
}

class Constant is PrimaryExpression is export {
    has ConstantTag $.type;
    has Identifier $.ident;
    has Num $.value; # WTF
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
