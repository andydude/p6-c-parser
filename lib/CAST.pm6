use v6;
module CAST;

use CAST::TypeSpec;
use CAST::OpKind;

use CAST::Node;			# compare to QAST::Node
use CAST::Compound;
use CAST::External;

use CAST::Constant;
use CAST::CharVal; 		# character constant
use CAST::EnumVal; 		# enum constant
use CAST::IntVal; 		# compare to QAST::IVal, integer constant
use CAST::NumVal; 		# compare to QAST::NVal, floating-point number constant
use CAST::StrVal; 		# compare to QAST::SVal, string literal constant

use CAST::Ident;		# has $.ident
use CAST::Arg;			# compare to QAST::Var( ..., :decl('param') )
use CAST::Var;			# compare to QAST::Var( ..., :decl('var') )
#use CAST::Field;
#use CAST::BitField;

use CAST::Type;
use CAST::Typed;		# has $.type
use CAST::RefType;		# does Ident, Typed, @children
use CAST::PtrType;		# pointer type ($type, CAST::Type::TypeSpec @children)
use CAST::ArrayType;	# array type ($type, $size, CAST::Type::TypeSpec @children)
use CAST::DirectType;	# direct type (CAST::Type::TypeSpec @children)
use CAST::FuncType;		# type ident # function     (CAST::Arg @children)
#use CAST::EnumType;		# ident # enumeration  (CAST::EnumVal @children)
#use CAST::StructType;	# ident, fields # structure    ($ident, Field @children)
#use CAST::UnionType;	# ident, fields # union        ($ident, Field @children)
# has kind, type, size, ident, specs

use CAST::Children;
use CAST::InitVar;
use CAST::VarDecl;
use CAST::TypeDef;		# has ($type )
use CAST::FuncDef;		# ($type, @children)
use CAST::Block;        # compare to QAST::Block
use CAST::Op;           # compare to QAST::Stmt, QAST::Op, has $.op, @.children
use CAST::TransUnit;	# compare to QAST::CompUnit
