use v6;
use C::AST::Ops;
module C::AST;

# Compound represents constants, expressions, and statements.
role Compound {}

# External represents declarations, and function definitions.
role External {}

# Operation represents compound structures.
role Operation {}

# Type represents all type structures.
role Type does Compound does External {}

class Node {}

class Value is Node does Compound {}

class CharVal is Value {
    has Str $.value;
}
class IntVal is Value {
    has Int $.value;
}
class NumVal is Value {
    has Num $.value;
}
class StrVal is Value {
    has Str $.value;
}

class Specs is export is Node does Type {
    has Spec @.children;
}

class Size is IntVal does Type {}

class Op is Node does Operation does Compound {
    has OpKind $.op;
	has Compound @.children
}

class TypeOp is Node does Operation does Type {
    has TyKind $.op;
	has Type @.children
}

class Name is Node does Type {
    has Str $.name;
}

class Arg is Name {
    has Type $.type;
}

class Init is Arg {
    has Compound $.value;
}

class Decl is Arg {
    has Type @.children; # usually Init
}

class TransUnit is Node {
    has External @.children;
}
