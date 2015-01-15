use v6;
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

enum OpKind <
>;

enum TypeOpKind <
>;

enum Spec <
>;

class Specs is Node does Type {
    has Spec @.children;
}

class Size is IntVal does Type {}

class Op does Operation does Compound {
    has OpKind $.op;
	has Compound @.children
}

class TypeOp does Operation does Type {
    has TypeOpKind $.op;
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
    has Init @.children;
}

class TransUnit is Node {
    has External @.children;
}

#use C::AST::TypeSpec;
#use C::AST::OpKind;
#
#use C::AST::Node;			# compare to QAST::Node
#use C::AST::Compound;
#use C::AST::External;
#
#use C::AST::Value;
#use C::AST::CharVal; 		# character constant
#use C::AST::IntVal; 		# compare to QAST::IVal, integer constant
#use C::AST::NumVal; 		# compare to QAST::NVal, floating-point number constant
#use C::AST::StrVal; 		# compare to QAST::SVal, string literal constant
#use C::AST::Enumerator; 	# enum constant
#
#use C::AST::Name;			# has $.ident
#use C::AST::Arg;			# compare to QAST::Var( ..., :decl('param') )
#use C::AST::Var;			# compare to QAST::Var( ..., :decl('var') )
##use C::AST::Field;
##use C::AST::BitField;
#
#use C::AST::Type;
#use C::AST::Typed;		# has $.type
#use C::AST::RefType;		# does Ident, Typed, @children
#use C::AST::PtrType;		# pointer type ($type, C::AST::Type::TypeSpec @children)
#use C::AST::ArrayType;	# array type ($type, $size, C::AST::Type::TypeSpec @children)
#use C::AST::DirectType;	# direct type (C::AST::Type::TypeSpec @children)
#use C::AST::FuncType;		# type ident # function     (C::AST::Arg @children)
##use C::AST::EnumType;		# ident # enumeration  (C::AST::EnumVal @children)
##use C::AST::StructType;	# ident, fields # structure    ($ident, Field @children)
##use C::AST::UnionType;	# ident, fields # union        ($ident, Field @children)
## has kind, type, size, ident, specs
#
#use C::AST::InitVar;
#use C::AST::VarDecl;
#use C::AST::TypeDef;		# has ($type )
#use C::AST::FuncDef;		# ($type, @children)
#use C::AST::Block;        # compare to QAST::Block
#use C::AST::Op;           # compare to QAST::Stmt, QAST::Op, has $.op, @.children
#use C::AST::TransUnit;	# compare to QAST::CompUnit
