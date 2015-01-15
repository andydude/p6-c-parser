use v6;
use CAST;
class C::Parser::CAST2Actions;

#sub new_init_declarator($decr, @inits) {
#    CAST::InitVar.new()
#}
sub new_init_declarator($decr, @inits) {
    my @children = @inits;
    @children.unshift($decr);
    CAST::Op.new(op => CAST::OpKind::OpKind::init_declarator, children => @children)
}


    
method TOP($/) {
    make $/.values.[0].ast;
}

method ident($/) {
    make $<name>.Str;
}

method integer-constant($/) {
    my Int $value = Int(~$/);
    make CAST::IntVal.new(:$value);
}
method floating-constant($/) {
    my Num $value = Num(~$/);
    make CAST::NumVal.new(:$value);
}
method enumeration-constant($/) {
    # TODO, both identifier + value
    my Str $ident = ~$/;
    my Str $value = ~$/;
    make CAST::EnumVal.new(:$value, :$ident);
}

method character-constant:sym<quote>($/) {
    make $<c-char-sequence>.ast;
}
method character-constant:sym<L>($/) {
    make $<c-char-sequence>.ast;
}
method character-constant:sym<u>($/) {
    make $<c-char-sequence>.ast;
}
method character-constant:sym<U>($/) {
    make $<c-char-sequence>.ast;
}

method c-char-sequence($/) {
    my $value = $<c-char>.Str;
    make CAST::CharVal.new(:$value);
}

method string-literal:sym<quote>($/) { make $<s-char-sequence>.ast }
#method string-literal:sym<L>($/)  { make $<s-char-sequence>.ast }
#method string-literal:sym<u8>($/) { make $<s-char-sequence>.ast }
#method string-literal:sym<u>($/)  { make $<s-char-sequence>.ast }
#method string-literal:sym<U>($/)  { make $<s-char-sequence>.ast }

method s-char-sequence($/) {
    my $value = $<s-char>.Str;
    make CAST::StrVal.new(:$value);
}

method string-constant($/) {
    my $value = (map {$_.ast.value}, @<string-literal>).join;
    make CAST::StrVal.new(:$value);
}

# SS 6.4.3

method constant:sym<integer>($/) {
    #say "IntegerConstant: " ~ $<integer-constant>.ast.perl;
    make $<integer-constant>.ast;
}
method constant:sym<floating>($/) {
    #say "FloatingConstant: " ~ $<floating-constant>.ast.perl;
    make $<floating-constant>.ast;
}
method constant:sym<enumeration>($/) {
    #say "EnumConstant: " ~ $<enumeration-constant>.ast.perl;
    make $<enumeration-constant>.ast;
}
method constant:sym<character>($/) {
    #say "CharConstant: " ~ $<character-constant>.ast.perl;
    make $<character-constant>.ast;
}

method primary-expression:sym<identifier>($/) {
    #say "Ident: " ~ $<ident>.perl;
    make CAST::Var.new(ident => $<ident>.ast);
}

method primary-expression:sym<constant>($/) {
    #say "Constant: " ~ $<constant>.perl;
    make $<constant>.ast;
}

method primary-expression:sym<string-literal>($/) { 
    #say "StringConstant: " ~ $<string-literal>.perl;
    make $<string-constant>.ast;
}

method primary-expression:sym<expression>($/) {
    #say "Parens: " ~ $<expression>.perl;
    make $<expression>.ast;
}

method primary-expression:sym<generic-selection>($/) { # C11
    make $<generic-selection>.ast;
}

#TODO
method generic-selection($/) {
    #say "generic-selection";
    make [$<assignment-expression>.ast, 
          $<generic-assoc-list>.ast];
}

#TODO
method generic-assoc-list($/) {
    #say "generic-assoc-list";
    make [$<generic-association>.ast, 
          $<generic-association>.ast];
}

#TODO
method generic-association:sym<typename>($/) {
    make [$<type-name>.ast,
         $<assignment-expression>.ast];
}
#TODO
method generic-association:sym<default>($/) {
    make [$<assignment-expression>.ast];
}

method postfix-expression($/) {
    my $ast = $<postfix-expression-first>.ast;

    #for @<postfix-expression-rest>
    #make ;
    make $<postfix-expression-first>.ast;
}

method postfix-expression-first:sym<primary>($/) {
    make $<primary-expression>.ast;
}

method postfix-expression-first:sym<initializer>($/) {
    my $kind = CAST::OpKind::OpKind::initializer;
    my $children = $<initializer-list>.ast;
    $children.unshift($<type-name>.ast);
    make CAST::Op.new(:$kind, :$children);
}

method postfix-expression-rest:sym<[ ]>($/) {
    make CAST::Op.new(
        kind => CAST::OpKind::OpKind::array_selector,
        children => [$<expression>.ast]
    );
}
method postfix-expression-rest:sym<( )>($/) {
    make CAST::Op.new(
        kind => CAST::OpKind::OpKind::call,
        children => @<argument-expression-list>
    );
}

method postfix-expression-rest:sym<.>($/)   {
    make CAST::Op.new(
        kind => CAST::OpKind::OpKind::direct_selector,
        children => $<ident>.ast
    );
}
method postfix-expression-rest:sym«->»($/)  {
    make CAST::Op.new(
        kind => CAST::OpKind::OpKind::indirect_selector,
        children => $<ident>.ast
    );
}
method postfix-expression-rest:sym<++>($/)  {
    make CAST::OpKind::OpKind::postinc;
}
method postfix-expression-rest:sym<-->($/)  {
    make CAST::OpKind::OpKind::postdec;
}

# unary

method unary-expression:sym<postfix>($/) {
    #say $<postfix-expression>.ast.perl;
    make $<postfix-expression>.ast;
}

method unary-expression:sym<++>($/) {
    #say "pre_increment: " ~ $<unary-expression>.ast.perl;
    make CAST::Op.new(CAST::OpKind::OpKind::preinc,
        children => [$<unary-expression>.ast]
    );
}

method unary-expression:sym<-->($/) {
    #say "pre_decrement: " ~ $<unary-expression>.ast.perl;
    make CAST::Op.new(CAST::OpKind::OpKind::predec,
        children => [$<unary-expression>.ast]
    );
}

method unary-expression:sym<unary-cast>($/) {
    #say "cast: " ~ $<cast-expression>.ast.perl;
    make CAST::Op.new($<unary-operator>.ast,
        children => [$<cast-expression>.ast]
    );
}

#method unary-expression:sym<size-of-expr>($/) {
#    <sizeof-keyword> <unary-expression>
#}
#method unary-expression:sym<size-of-type>($/) {
#    <sizeof-keyword> '(' <type-name> ')'
#}
#method unary-expression:sym<align-of-type>($/) {
#    <alignof-keyword> '(' <type-name> ')'
#}

method unary-operator:sym<&> {
    make CAST::OpKind::OpKind::ref;
}
method unary-operator:sym<*> {
    make CAST::OpKind::OpKind::deref;
}
method unary-operator:sym<+> {
    make CAST::OpKind::OpKind::prepos;
}
method unary-operator:sym<-> {
    make CAST::OpKind::OpKind::preneg;
}
method unary-operator:sym<~> {
    make CAST::OpKind::OpKind::bitnot;
}
method unary-operator:sym<!> {
    make CAST::OpKind::OpKind::not;
}


# SS 6.5.4
method cast-expression($/) {
    my $ast = $<unary-expression>.ast;
    for @<cast-operator> -> $operator {
        my $kind = $operator.ast;
        $ast = CAST::Op.new(
            kind => $kind,
            children => [$ast])
    }
    make $ast;
}

sub binop_from_lassoc(@operators, @operands) {
    my $ast = (shift @operands).ast;
    for @operators Z @operands -> $operator, $operand {
        if $operator.WHAT.perl ne 'Match' {
            die "expected operator to be of type `Match`";
        }
        my $op = $operator.ast;
        my @children = ($ast, $operand.ast);
        $ast = CAST::Op.new(:$op, :@children);
    };
    return $ast;
}

sub binop_from_rassoc(@operators, @operands) {
    # TODO
    return binop_from_lassoc(@operators, @operands);
}

# SS 6.5.5
method multiplicative-expression($/) {
    make binop_from_lassoc(@<multiplicative-operator>, @<operands>);
}
method multiplicative-operator:sym<*>($/) {
    make CAST::OpKind::OpKind::mul;
}
method multiplicative-operator:sym</>($/) {
    make CAST::OpKind::OpKind::div;
}
method multiplicative-operator:sym<%>($/) {
    make CAST::OpKind::OpKind::mod;
}

# SS 6.5.6
method additive-expression($/) {
    make binop_from_lassoc(@<additive-operator>, @<operands>);
}
method additive-operator:sym<+>($/) { 
    make CAST::OpKind::OpKind::add;
}
method additive-operator:sym<->($/) { make 
    make CAST::OpKind::OpKind::sub;
}

# SS 6.5.7
method shift-expression($/) {
    make binop_from_lassoc(@<shift-operator>, @<operands>);
}
method shift-operator:sym«<<»($/) {
    make CAST::OpKind::OpKind::bitshiftl;
}
method shift-operator:sym«>>»($/) {
    make CAST::OpKind::OpKind::bitshiftr;
}

# SS 6.5.8
method relational-expression($/) {
    make binop_from_lassoc(@<relational-operator>, @<operands>);
}
method relational-operator:sym«<»($/) {
    make CAST::OpKind::OpKind::islt;
}
method relational-operator:sym«>»($/) {
    make CAST::OpKind::OpKind::isgt;
}
method relational-operator:sym«<=»($/) {
    make CAST::OpKind::OpKind::isle;
}
method relational-operator:sym«>=»($/) {
    make CAST::OpKind::OpKind::isge;
}

# SS 6.5.9
method equality-expression($/) {
    make binop_from_lassoc(@<equality-operator>, @<operands>);
}
method equality-operator:sym<==>($/) {
    make CAST::OpKind::OpKind::iseq;
}
method equality-operator:sym<!=>($/) {
    make CAST::OpKind::OpKind::isne;
}

# SS 6.5.10
method and-expression($/)  {
    make binop_from_lassoc(@<and-operator>, @<operands>);
}
method and-operator:sym<&>($/) {
    make CAST::OpKind::OpKind::bitand;
}

# SS 6.5.11
method exclusive-or-expression($/) {
    make binop_from_lassoc(@<exclusive-or-operator>, @<operands>);
}
method exclusive-or-operator:sym<^>($/) {
    make CAST::OpKind::OpKind::bitxor;
}

# SS 6.5.12
method inclusive-or-expression($/) {
    make binop_from_lassoc(@<inclusive-or-operator>, @<operands>);
}
method inclusive-or-operator:sym<|>($/) {
    make CAST::OpKind::OpKind::bitor;
}

# SS 6.5.13
method logical-and-expression($/) {
    make binop_from_lassoc(@<logical-and-operator>, @<operands>);
}
method logical-and-operator:sym<&&>($/) {
    make CAST::OpKind::OpKind::and;
}

# SS 6.5.14
method logical-or-expression($/) {
    make binop_from_lassoc(@<logical-or-operator>, @<operands>);
}
method logical-or-operator:sym<||>($/) {
    make CAST::OpKind::OpKind::or;
}

# SS 6.5.15
method conditional-expression($/) {
    #make binop_from_lassoc(@<operators>, @<operands>);
    make @<operands>[0].ast;
}

# SS 6.5.16
method assignment-expression($/) {
    make binop_from_rassoc(@<assignment-operator>, @<operands>);
}
method assignment-operator:sym<=>($/)    {
    make CAST::OpKind::OpKind::assign;
}
method assignment-operator:sym<*=>($/)   {
    make CAST::OpKind::OpKind::assign_mul;
}
method assignment-operator:sym</=>($/)   {
    make CAST::OpKind::OpKind::assign_div;
}
method assignment-operator:sym<%=>($/)   {
    make CAST::OpKind::OpKind::assign_mod;
}
method assignment-operator:sym<+=>($/)   {
    make CAST::OpKind::OpKind::assign_add;
}
method assignment-operator:sym<-=>($/)   {
    make CAST::OpKind::OpKind::assign_sub;
}
method assignment-operator:sym«<<=»($/)  {
    make CAST::OpKind::OpKind::assign_bitshiftl;
}
method assignment-operator:sym«>>=»($/)  {
    make CAST::OpKind::OpKind::assign_bitshiftr;
}
method assignment-operator:sym<&=>($/)   {
    make CAST::OpKind::OpKind::assign_bitand;
}
method assignment-operator:sym<^=>($/)   {
    make CAST::OpKind::OpKind::assign_bitxor;
}
method assignment-operator:sym<|=>($/)   {
    make CAST::OpKind::OpKind::assign_bitor;
}

# SS 6.5.17
# TODO
method expression($/) {
    my $operand = @<operands>[0];
    make $operand.ast;
}

# SS 6.6
method constant-expression($/) {
    make $<conditional-expression>.ast;
}

# SS 6.7
method declaration:sym<declaration>($/) {
    # determine if it's a typedef
    # determine the name
    #make Var.new(
    #    ident
    #    type
    #)
    my $op = CAST::OpKind::OpKind::declaration;
    if $<init-declarator-list> {
        my @children = $<init-declarator-list>.ast;
        @children.unshift($<declaration-specifiers>.ast);
        make CAST::Op.new(:$op, :@children);
    }
    else {
        make $<declaration-specifiers>.ast;
    }
}
method declaration:sym<static_assert>($/) { # C11
    make $<static-assert-declaration>.ast;
}

method declaration-specifiers($/) {
    my $op = CAST::OpKind::OpKind::direct_type;
    my @children = map {$_.ast}, @<declaration-specifier>;
    #make CAST::DirectType.new(:@children);
    make CAST::Op.new(:$op, :@children);
}


method declaration-specifier:sym<storage-class>($/) {
    make $<storage-class-specifier>.ast;
}
method declaration-specifier:sym<type-specifier>($/) {
    make $<type-specifier>.ast;
}
method declaration-specifier:sym<type-qualifier>($/) {
    make $<type-qualifier>.ast;
}
method declaration-specifier:sym<function>($/) {
    make $<function-specifier>.ast;
}
method declaration-specifier:sym<alignment>($/) {
    make $<alignment-specifier>.ast;
}


method init-declarator-list($/) {
    make map {$_.ast}, @<init-declarator>;
}

method init-declarator($/) {
    my $decl = $<declarator> ?? $<declarator>.ast !! Nil;
    my $init = $<initializer> ?? $<initializer>.ast !! Nil;

    if $decl && $init {
        my $op = CAST::OpKind::OpKind::init_declarator;
        my @children = ($decl, $init);
        make CAST::Op.new(:$op, :@children);
    }
    elsif $decl {
        make $decl;
    }
    else {
        make Nil;
    }
}

# SS 6.7.1
method storage-class-specifier:sym<typedef>($/) {
    make CAST::TypeSpec::TypeSpec::c_typedef;
}
method storage-class-specifier:sym<extern>($/) {
    make CAST::TypeSpec::TypeSpec::c_extern;
}
method storage-class-specifier:sym<static>($/) {
    make CAST::TypeSpec::TypeSpec::c_static;
}
method storage-class-specifier:sym<_Thread_local>($/) {
    make CAST::TypeSpec::TypeSpec::c_thread_local;
}
method storage-class-specifier:sym<auto>($/) {
    make CAST::TypeSpec::TypeSpec::c_auto;
}
method storage-class-specifier:sym<register>($/) {
    make CAST::TypeSpec::TypeSpec::c_register;
}

# SS 6.7.2
method type-specifier:sym<void>($/)     { make CAST::TypeSpec::TypeSpec::c_void }
method type-specifier:sym<char>($/)     { make CAST::TypeSpec::TypeSpec::c_char }
method type-specifier:sym<short>($/)    { make CAST::TypeSpec::TypeSpec::c_short }
method type-specifier:sym<int>($/)      { make CAST::TypeSpec::TypeSpec::c_int }
method type-specifier:sym<long>($/)     { make CAST::TypeSpec::TypeSpec::c_long }
method type-specifier:sym<float>($/)    { make CAST::TypeSpec::TypeSpec::c_float }
method type-specifier:sym<double>($/)   { make CAST::TypeSpec::TypeSpec::c_double }
method type-specifier:sym<signed>($/)   { make CAST::TypeSpec::TypeSpec::c_signed }
method type-specifier:sym<unsigned>($/) { make CAST::TypeSpec::TypeSpec::c_unsigned }
method type-specifier:sym<_Bool>($/)    { make CAST::TypeSpec::TypeSpec::c_bool }
method type-specifier:sym<_Complex>($/) { make CAST::TypeSpec::TypeSpec::c_complex }

method type-specifier:sym<atomic-type>($/) {
    make $<atomic-type-specifier>.ast;
}
method type-specifier:sym<struct-or-union>($/) {
    make $<struct-or-union-specifier>.ast;
}
method type-specifier:sym<enum-specifier>($/)  {
    make $<enum-specifier>.ast;
}
method type-specifier:sym<typedef-name>($/)    {
    make $<typedef-name>.ast;
}

# SS 6.7.2.1
# SS 6.7.2.2
# SS 6.7.2.4


# SS 6.7.3
proto rule type-qualifier {*}
method type-qualifier:sym<const>($/)    { make CAST::TypeSpec::TypeSpec::c_const }
method type-qualifier:sym<restrict>($/) { make CAST::TypeSpec::TypeSpec::c_restrict }
method type-qualifier:sym<volatile>($/) { make CAST::TypeSpec::TypeSpec::c_volatile }
method type-qualifier:sym<_Atomic>($/)  { make CAST::TypeSpec::TypeSpec::c_atomic }

# SS 6.7.4
method function-specifier:sym<inline>($/)    { make CAST::TypeSpec::TypeSpec::c_inline }
method function-specifier:sym<_Noreturn>($/) { make CAST::TypeSpec::TypeSpec::c_noreturn }

# SS 6.7.5
method alignment-specifier:sym<type-name>($/) {
    my $op = CAST::OpKind::OpKind::alignas_type;
    my @children = ($<type-name>.ast);
    make CAST::Op.new(:$op, :@children);
}
method alignment-specifier:sym<constant>($/) {
    my $op = CAST::OpKind::OpKind::alignas_expr;
    my @children = ($<type-name>.ast);
    make CAST::Op.new(:$op, :@children);
}



# SS 6.7.6
method declarator:sym<direct>($/) {

    # TODO
    my $ast = $<direct-declarator>.ast;
    for @<pointer> -> $pointer {
        my $op = CAST::OpKind::OpKind::pointer_declarator;
        my @children = ($ast, $pointer.ast);
        $ast = CAST::Op.new(:$op, :@children);
    }
    make $ast;
}

method direct-declarator($/) {
    my $op = CAST::OpKind::OpKind::direct_declarator;
    my @children = map {$_.ast}, @<direct-declarator-rest>;
    @children.unshift($<direct-declarator-first>.ast);
    make CAST::Op.new(:$op, :@children);
}

method direct-declarator-first:sym<identifier>($/) {
    make CAST::Var.new(ident => $<ident>.ast);
}

method direct-declarator-first:sym<declarator>($/) {
    make $<declarator>.ast;
}

#method direct-declarator-rest:sym<b-assignment-expression>($/) {
#    '['
#    <type-qualifier-list>?
#    <assignment-expression>?
#    ']'
#}
#method direct-declarator-rest:sym<b-static-type-qualifier>($/) {
#    '['
#    <static-keyword>
#    <type-qualifier-list>?
#    <assignment-expression>
#    ']'
#}
#method direct-declarator-rest:sym<b-type-qualifier-static>($/) {
#    '['
#    <type-qualifier-list>
#    <static-keyword>
#    <assignment-expression>
#    ']'
#}

method direct-declarator-rest:sym<b-type-qualifier-list>($/) {
    make $<type-qualifier-list>.ast;
}

method direct-declarator-rest:sym<p-parameter-type-list>($/) {
    make $<parameter-type-list>.ast;
}

method direct-declarator-rest:sym<p-identifier-list>($/) {
    make $<identifier-list>;
}

method pointer:sym<pointer>($/) {
    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    make CAST::PtrType.new(:@children);
}

method pointer:sym<block>($/) {
    my @children = $<type-qualifier-list>.ast;
    make CAST::PtrType.new(:@children);
}

method type-qualifier-list($/) {
    make map {$_.ast}, @<type-qualifier>
}

method parameter-type-list:sym<std>($/) {
    # TODO: check for ellipsis
    make $<parameter-list>.ast
}

method parameter-list($/) {
    make map {$_.ast}, @<parameter-declaration>;
}

method parameter-declaration:sym<declarator>($/) {
    my $type = $<declaration-specifiers>.ast;
    my $decr = $<declarator>.ast;
    #make CAST::Arg.new(:$type);
    make CAST::Op.new(op => CAST::OpKind::OpKind::parameter_declaration, children => ($type, $decr));
}
method parameter-declaration:sym<abstract>($/) {
    my $type = $<declaration-specifiers>.ast;
    make CAST::Arg.new(:$type);
    make CAST::Op.new(op => CAST::OpKind::OpKind::parameter_declaration, children => ($type));
}

method identifier-list($/) { make map {$_.ast}, @<ident> }

# SS 6.7.7
method type-name($/) {
    my @children = $<specifier-qualifier-list>.ast;
    my $decr = $<abstract-declarator>.ast;
    make CAST::RefType.new(@children);
}
method abstract-declarator:sym<pointer>($/)  {
    make $<pointer>.ast;
}
method abstract-declarator:sym<direct-abstract>($/) {
    # TODO
    make $<direct-abstract-declarator>.ast;
}

method direct-abstract-declarator($/) {
    #make Arg.new(
    #    first => $<direct-abstract-declarator-first>,
    #        rest => @<direct-abstract-declarator-rest>)
    make CAST::Var.new()
}
method direct-abstract-declarator-first:sym<abstract>($/)  {
    make $<abstract-declarator>.ast;
}

#rule direct-abstract-declarator-rest:sym<b-type-qualifier>($/) {
#    '['
#    <type-qualifier-list>?
#    <assignment-expression>?
#    ']'
#}
#rule direct-abstract-declarator-rest:sym<b-static-type-qualifier>($/) {
#    '['
#    <static-keyword>
#    <type-qualifier-list>?
#    <assignment-expression>
#    ']'
#}
#rule direct-abstract-declarator-rest:sym<b-type-qualifier-static>($/) {
#    '['
#    <type-qualifier-list>
#    <static-keyword>
#    <assignment-expression>
#    ']'
#}
#rule direct-abstract-declarator-rest:sym<b-*>($/) {
#    '[' '*' ']'
#}

method direct-abstract-declarator-rest:sym<p-parameter-type-list>($/) {
    make $<parameter-type-list>.ast;
}

# SS 6.7.8
method typedef-name($/) {
    make $<ident>.ast
}

# SS 6.7.9
method initializer:sym<assignment>($/) {
    make $<assignment-expression>.ast;
}

method initializer:sym<initializer-list>($/) {
    make $<initializer-list>.ast;
}

method initializer-list($/) {
    make map {$_.ast}, @<designation-initializer>;
}

method designation-initializer($/) {
    make $<initializer>.ast;
    #make DesignationInitializer.new(
    #    dsgn => $<designation>.ast,
    #        init => $<initializer>.ast)
}

#method designation($/) { <designator-list> '=' }
#method designator-list($/) { <designator>+ }
#
#method designator:sym<.>($/) { <sym> <ident> }
#method designator:sym<[ ]>($/) {
#    make $<constant-expression>.ast;
#}

# SS 6.7.10
#method static-assert-declaration($/) { # C11
#    <static-assert-keyword>
#    '('
#    <constant-expression>
#    ','
#    <string-literal>
#    ')'
#    ';'
#}

# SS 6.8
method statement:sym<labeled>($/) {
    make $<labeled-statement>.ast;
}
method statement:sym<compound>($/) {
    make $<compound-statement>.ast;
}
method statement:sym<expression>($/) {
    make $<expression-statement>.ast;
}
method statement:sym<selection>($/) {
    make $<selection-statement>.ast;
}
method statement:sym<iteration>($/) {
    make $<iteration-statement>.ast;
}
method statement:sym<jump>($/) {
    make $<jump-statement>.ast;
}


# SS 6.8.1
method labeled-statement:sym<identifier>($/) {
    my $op = CAST::OpKind::OpKind::labeled_stmt;
    my @children = ($<ident>.ast, $<statement>.ast);
    make CAST::Op.new(:$op, :@children);
}
method labeled-statement:sym<case>($/) {
    my $op = CAST::OpKind::OpKind::switch_case;
    my @children = ($<constant-expression>.ast, $<statement>.ast);
    make CAST::Op.new(:$op, :@children);
}
method labeled-statement:sym<default>($/) {
    my $op = CAST::OpKind::OpKind::switch_default;
    my @children = ($<ident>.ast, $<statement>.ast);
    make CAST::Op.new(:$op, :@children);
}

# SS 6.8.2
method compound-statement($/) {
    make $<block-item-list>.ast;
}
method block-item-list($/) {
    my @children = map {$_.ast}, @<block-item>;
    make CAST::Block.new(:@children);
}
method block-item:sym<declaration>($/) {
    make $<declaration>.ast;
}
method block-item:sym<statement>($/) {
    make $<statement>.ast;
}

# SS 6.8.3
method expression-statement($/) {
    make $<expression>.ast;
}

# SS 6.8.4
method selection-statement:sym<if>($/) {
    my $op = CAST::OpKind::OpKind::if_stmt;
    my @children = ($<expression>.ast, $<then_statement>.ast, $<else_statement>.ast);
    make CAST::Op.new(:$op, :@children);
}
    
method selection-statement:sym<switch>($/) {
    my $op = CAST::OpKind::OpKind::switch_stmt;
    my @children = map {$_.ast}, @<statement>;
    @children.unshift($<expression>.ast);
    make CAST::Op.new(:$op, :@children);
}

# SS 6.8.5

# SS 6.8.6
method jump-statement:sym<goto>($/) {
    my $op = CAST::OpKind::OpKind::goto_stmt;
    my @children = ($<ident>.ast);
    make CAST::Op.new(:$op, :@children);
}
method jump-statement:sym<continue>($/) {
    my $op = CAST::OpKind::OpKind::continue_stmt;
    my @children = ();
    make CAST::Op.new(:$op, :@children);
}
method jump-statement:sym<break>($/) {
    my $op = CAST::OpKind::OpKind::break_stmt;
    my @children = ();
    make CAST::Op.new(:$op, :@children);
}
method jump-statement:sym<return>($/) {
    my $op = CAST::OpKind::OpKind::return_stmt;
    my @children = ($<expression>.ast);
    make CAST::Op.new(:$op, :@children);
}

# SS 6.9
method translation-unit($/) {
    my @children = map {$_.ast}, @<external-declaration>;
    make CAST::TransUnit.new(:@children);
}

method external-declaration:sym<function-definition>($/) {
    make $<function-definition>.ast;
}
method external-declaration:sym<declaration>($/) {
    make $<declaration>.ast;
}

# SS 6.9.1

method declaration-list($/) {
    make map {$_.ast}, @<declaration>;
}

method function-definition:sym<std>($/) {
    my @specs = map {$_.ast}, @<declaration-specifiers>;
    my @ancients = map {$_.ast}, @<declaration-list>;
    my $head = $<declarator>.ast;
    my @children = [$<compound-statement>.ast];
    make CAST::FuncDef.new(:@specs, :$head, :@ancients, :@children);
}
