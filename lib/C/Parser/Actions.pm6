use v6;
use C::AST;
use C::AST::Ops;
use C::Parser::Utils;
class C::Parser::Actions;

sub get_declarator_name(Match $decr --> Str) {
    my Match $ddecr1 = $decr<direct-declarator><direct-declarator-first>;
    my Str $name = $ddecr1<declarator> ?? get_declarator_name($ddecr1<declarator>) !! $ddecr1<ident><name>.Str;
    return $name;
}

sub synthesize_declarator(C::AST::Type $declarator, C::AST::Type $designator --> C::AST::Type) {
    $designator.children.unshift($declarator);
    return C::AST::TypeOp.new(
        op => TyKind::declarator,
        children => $designator);
}

sub synthesize_declaration(C::AST::Type $specifiers, C::AST::Type $declarator --> C::AST::Type) {
    return C::AST::TypeOp.new(
        op => TyKind::declaration,
        children => ($specifiers, $declarator));
}

method TOP($/) {
    make $/.values.[0].ast;
}

method ident($/) {
    my Str $name = $<name>.Str;
    make C::AST::Name.new(:$name);
}

method integer-constant($/) {
    my Int $value = Int(~$/);
    make C::AST::IntVal.new(:$value);
}
method floating-constant($/) {
    my Num $value = Num(~$/);
    make C::AST::NumVal.new(:$value);
}
#method enumeration-constant($/) {
#    # TODO, both identifier + value
#    my Str $ident = ~$/;
#    my Str $value = ~$/;
#    make C::AST::Enumerator.new(:$value, :$ident);
#}

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
    make C::AST::CharVal.new(:$value);
}

method string-literal:sym<quote>($/) { make $<s-char-sequence>.ast }
#method string-literal:sym<L>($/)  { make $<s-char-sequence>.ast }
#method string-literal:sym<u8>($/) { make $<s-char-sequence>.ast }
#method string-literal:sym<u>($/)  { make $<s-char-sequence>.ast }
#method string-literal:sym<U>($/)  { make $<s-char-sequence>.ast }

method s-char-sequence($/) {
    my $value = $<s-char>.Str;
    make C::AST::StrVal.new(:$value);
}

method string-constant($/) {
    my $value = (map {$_.ast.value}, @<string-literal>).join;
    make C::AST::StrVal.new(:$value);
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
    make $<ident>.ast;
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
    my $op = OpKind::initializer;
    my $children = $<initializer-list>.ast;
    $children.unshift($<type-name>.ast);
    make C::AST::Op.new(:$op, :$children);
}

method postfix-expression-rest:sym<[ ]>($/) {
    make C::AST::Op.new(
        op => OpKind::array_selector,
        children => $<expression>.ast
    );
}
method postfix-expression-rest:sym<( )>($/) {
    my @children = $<argument-expression-list>
      ?? $<argument-expression-list>.ast !! ();
    make C::AST::Op.new(op => OpKind::call, :@children);
}

method postfix-expression-rest:sym<.>($/)   {
    make C::AST::Op.new(
        op => OpKind::direct_selector,
        children => $<ident>.ast
    );
}
method postfix-expression-rest:sym«->»($/)  {
    make C::AST::Op.new(
        op => OpKind::indirect_selector,
        children => $<ident>.ast
    );
}
method postfix-expression-rest:sym<++>($/)  {
    make OpKind::postinc;
}
method postfix-expression-rest:sym<-->($/)  {
    make OpKind::postdec;
}

# unary

method unary-expression:sym<postfix>($/) {
    #say $<postfix-expression>.ast.perl;
    make $<postfix-expression>.ast;
}

method unary-expression:sym<++>($/) {
    #say "pre_increment: " ~ $<unary-expression>.ast.perl;
    make C::AST::Op.new(OpKind::preinc,
        children => $<unary-expression>.ast
    );
}

method unary-expression:sym<-->($/) {
    #say "pre_decrement: " ~ $<unary-expression>.ast.perl;
    make C::AST::Op.new(OpKind::predec,
        children => $<unary-expression>.ast
    );
}

method unary-expression:sym<unary-cast>($/) {
    #say "cast: " ~ $<cast-expression>.ast.perl;
    make C::AST::Op.new($<unary-operator>.ast,
        children => $<cast-expression>.ast
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
    make OpKind::ref;
}
method unary-operator:sym<*> {
    make OpKind::deref;
}
method unary-operator:sym<+> {
    make OpKind::prepos;
}
method unary-operator:sym<-> {
    make OpKind::preneg;
}
method unary-operator:sym<~> {
    make OpKind::bitnot;
}
method unary-operator:sym<!> {
    make OpKind::not;
}


# SS 6.5.4
method cast-expression($/) {
    my $ast = $<unary-expression>.ast;
    for @<cast-operator> -> $operator {
        my $op = $operator.ast;
        $ast = C::AST::Op.new(
            op => $op,
            children => ($ast,))
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
        $ast = C::AST::Op.new(:$op, :@children);
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
    make OpKind::mul;
}
method multiplicative-operator:sym</>($/) {
    make OpKind::div;
}
method multiplicative-operator:sym<%>($/) {
    make OpKind::mod;
}

# SS 6.5.6
method additive-expression($/) {
    make binop_from_lassoc(@<additive-operator>, @<operands>);
}
method additive-operator:sym<+>($/) { 
    make OpKind::add;
}
method additive-operator:sym<->($/) { make 
    make OpKind::sub;
}

# SS 6.5.7
method shift-expression($/) {
    make binop_from_lassoc(@<shift-operator>, @<operands>);
}
method shift-operator:sym«<<»($/) {
    make OpKind::bitshiftl;
}
method shift-operator:sym«>>»($/) {
    make OpKind::bitshiftr;
}

# SS 6.5.8
method relational-expression($/) {
    make binop_from_lassoc(@<relational-operator>, @<operands>);
}
method relational-operator:sym«<»($/) {
    make OpKind::islt;
}
method relational-operator:sym«>»($/) {
    make OpKind::isgt;
}
method relational-operator:sym«<=»($/) {
    make OpKind::isle;
}
method relational-operator:sym«>=»($/) {
    make OpKind::isge;
}

# SS 6.5.9
method equality-expression($/) {
    make binop_from_lassoc(@<equality-operator>, @<operands>);
}
method equality-operator:sym<==>($/) {
    make OpKind::iseq;
}
method equality-operator:sym<!=>($/) {
    make OpKind::isne;
}

# SS 6.5.10
method and-expression($/)  {
    make binop_from_lassoc(@<and-operator>, @<operands>);
}
method and-operator:sym<&>($/) {
    make OpKind::bitand;
}

# SS 6.5.11
method exclusive-or-expression($/) {
    make binop_from_lassoc(@<exclusive-or-operator>, @<operands>);
}
method exclusive-or-operator:sym<^>($/) {
    make OpKind::bitxor;
}

# SS 6.5.12
method inclusive-or-expression($/) {
    make binop_from_lassoc(@<inclusive-or-operator>, @<operands>);
}
method inclusive-or-operator:sym<|>($/) {
    make OpKind::bitor;
}

# SS 6.5.13
method logical-and-expression($/) {
    make binop_from_lassoc(@<logical-and-operator>, @<operands>);
}
method logical-and-operator:sym<&&>($/) {
    make OpKind::and;
}

# SS 6.5.14
method logical-or-expression($/) {
    make binop_from_lassoc(@<logical-or-operator>, @<operands>);
}
method logical-or-operator:sym<||>($/) {
    make OpKind::or;
}

# SS 6.5.15
method conditional-expression($/) {
      #TODO ternary operator
    #make binop_from_lassoc(@<operators>, @<operands>);
    make @<operands>[0].ast;
}

# SS 6.5.16
method assignment-expression($/) {
    make binop_from_rassoc(@<assignment-operator>, @<operands>);
}
method assignment-operator:sym<=>($/)    {
    make OpKind::assign;
}
method assignment-operator:sym<*=>($/)   {
    make OpKind::assign_mul;
}
method assignment-operator:sym</=>($/)   {
    make OpKind::assign_div;
}
method assignment-operator:sym<%=>($/)   {
    make OpKind::assign_mod;
}
method assignment-operator:sym<+=>($/)   {
    make OpKind::assign_add;
}
method assignment-operator:sym<-=>($/)   {
    make OpKind::assign_sub;
}
method assignment-operator:sym«<<=»($/)  {
    make OpKind::assign_bitshiftl;
}
method assignment-operator:sym«>>=»($/)  {
    make OpKind::assign_bitshiftr;
}
method assignment-operator:sym<&=>($/)   {
    make OpKind::assign_bitand;
}
method assignment-operator:sym<^=>($/)   {
    make OpKind::assign_bitxor;
}
method assignment-operator:sym<|=>($/)   {
    make OpKind::assign_bitor;
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

    if $<init-declarator-list> {
        my $type = $<declaration-specifiers>.ast;
        my @children = $<init-declarator-list> ?? $<init-declarator-list>.ast !! ();
        make C::AST::Decl.new(:$type, :@children);
    }
    else {
        make $<declaration-specifiers>.ast;
    }
}

method declaration:sym<static_assert>($/) { # C11
    make $<static-assert-declaration>.ast;
}

method declaration-specifiers($/) {
    my @children = map {$_.ast}, @<declaration-specifier>;
    make C::AST::Specs.new(:@children);
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
    my $type = $<declarator> ?? $<declarator>.ast !! Nil;
    my $value = $<initializer> ?? $<initializer>.ast !! Nil;

    if $type && $value {
        make C::AST::Init.new(:$type, :$value);
    }
    elsif $type {
        make $type;
    }
    else {
        say "unreachable";
        make Nil;
    }
}

# SS 6.7.1

method storage-class-specifier:sym<typedef>($/) {
    make Spec::typedef;
}

method storage-class-specifier:sym<extern>($/) {
    make Spec::extern;
}

method storage-class-specifier:sym<static>($/) {
    make Spec::static;
}

method storage-class-specifier:sym<_Thread_local>($/) {
    make Spec::thread_local;
}

method storage-class-specifier:sym<auto>($/) {
    make Spec::auto;
}

method storage-class-specifier:sym<register>($/) {
    make Spec::register;
}

# SS 6.7.2

method type-specifier:sym<void>($/)     { make Spec::void }
method type-specifier:sym<char>($/)     { make Spec::char }
method type-specifier:sym<short>($/)    { make Spec::short }
method type-specifier:sym<int>($/)      { make Spec::int }
method type-specifier:sym<long>($/)     { make Spec::long }
method type-specifier:sym<float>($/)    { make Spec::float }
method type-specifier:sym<double>($/)   { make Spec::double }
method type-specifier:sym<signed>($/)   { make Spec::signed }
method type-specifier:sym<unsigned>($/) { make Spec::unsigned }
method type-specifier:sym<_Bool>($/)    { make Spec::bool }
method type-specifier:sym<_Complex>($/) { make Spec::complex }

method type-specifier:sym<atomic-type>($/) {
    make $<atomic-type-specifier>.ast;
}

method type-specifier:sym<struct-or-union>($/) {
    make $<struct-or-union-specifier>.ast;
}

method type-specifier:sym<enum-specifier>($/) {
    make $<enum-specifier>.ast;
}

method type-specifier:sym<typedef-name>($/) {
    make $<typedef-name>.ast;
}

# SS 6.7.2.1
method struct-or-union-specifier:sym<decl>($/) {
    our $op = Nil;
    our @children = $<struct-declaration-list> ?? $<struct-declaration-list>.ast !! ();
    if $<ident> {
        $op = C::AST::TyKind::struct;
    }
    else {
        $op = C::AST::TyKind::anonymous_struct;
    }
    make C::AST::TypeOp.new(:$op, :@children);
}
method struct-or-union-specifier:sym<spec>($/) {
    my @children = $<struct-declaration-list> ?? $<struct-declaration-list>.ast !! ();
    my $op = C::AST::TyKind::struct_specifier;
    make C::AST::TypeOp.new(:$op, :@children);
}

method struct-keyword($/) { make TyKind::struct }
method union-keyword($/)  { make TyKind::union }

# SS 6.7.2.2

method enum-keyword($/)  { make TyKind::enum }

# SS 6.7.2.4


# SS 6.7.3

method type-qualifier:sym<const>($/)    { make Spec::const }
method type-qualifier:sym<restrict>($/) { make Spec::restrict }
method type-qualifier:sym<volatile>($/) { make Spec::volatile }
method type-qualifier:sym<_Atomic>($/)  { make Spec::atomic }

# SS 6.7.4

method function-specifier:sym<inline>($/)    { make Spec::inline }
method function-specifier:sym<_Noreturn>($/) { make Spec::noreturn }

# SS 6.7.5

method alignment-specifier:sym<type-name>($/) {
    my $op = TyKind::alignas_type;
    my @children = ($<type-name>.ast);
    make C::AST::TypeOp.new(:$op, :@children);
}

method alignment-specifier:sym<constant>($/) {
    my $op = TyKind::alignas_expr;
    my @children = ($<type-name>.ast);
    make C::AST::TypeOp.new(:$op, :@children);
}

# SS 6.7.6

method static-keyword {
    make Spec::static;
}

method declarator:sym<direct>($/) {

    # TODO
    our $ast = $<direct-declarator>.ast;
    for @<pointer> -> $pointer {
        #say C::Parser::Utils::fake_indent($pointer.perl);
        my $op = TyKind::pointer_declarator;
        my @children = $pointer.ast.children;
        @children.unshift($ast);
        $ast = C::AST::TypeOp.new(:$op, :@children);
    }
    #say C::Parser::Utils::fake_indent($ast.perl);
    make $ast;
}

method direct-declarator($/) {
    my $op = TyKind::direct_declarator;
    my @children = map {$_.ast}, @<direct-declarator-rest>;
    say C::Parser::Utils::fake_indent(@children.perl);
    if @children.elems > 0 {
        say C::Parser::Utils::fake_indent(@children[0].perl);
        @children.unshift($<direct-declarator-first>.ast);
        make C::AST::TypeOp.new(:$op, :@children);
    }
    else {
        make $<direct-declarator-first>.ast;
    }
}

method direct-declarator-first:sym<identifier>($/) {
    make $<ident>.ast;
}

method direct-declarator-first:sym<declarator>($/) {
    make $<declarator>.ast;
}

method direct-declarator-rest:sym<b-assignment-expression>($/) {
    my $op = $<assignment-expression> 
        ?? TyKind::fixed_length_array_designator
        !! TyKind::array_designator;
    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    if $<assignment-expression> {
        my $size = C::AST::Size.new(value => $<assignment-expression>.ast.value);
        @children.unshift($size) ;
    }
    make C::AST::TypeOp.new(:$op, :@children);
}

method direct-declarator-rest:sym<b-static-type-qualifier>($/) {
    my $op = $<assignment-expression> 
        ?? TyKind::fixed_length_array_designator
        !! TyKind::array_designator;
    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    @children.unshift($<static-keyword>.ast) if $<static-keyword>;
    if $<assignment-expression> {
        my $size = C::AST::Size.new(value => $<assignment-expression>.ast.value);
        @children.unshift($size) ;
    }
    make C::AST::TypeOp.new(:$op, :@children);
}
method direct-declarator-rest:sym<b-type-qualifier-static>($/) {
    my $op = $<assignment-expression> 
        ?? TyKind::fixed_length_array_designator
        !! TyKind::array_designator;
    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    @children.unshift($<static-keyword>.ast) if $<static-keyword>;
    if $<assignment-expression> {
        my $size = C::AST::Size.new(value => $<assignment-expression>.ast.value);
        @children.unshift($size) ;
    }
    make C::AST::TypeOp.new(:$op, :@children);
}

method direct-declarator-rest:sym<b-type-qualifier-list>($/) {
    my $op = TyKind::variable_length_array_designator;
    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    make C::AST::TypeOp.new(:$op, :@children);
}

method direct-declarator-rest:sym<p-parameter-type-list>($/) {
    make $<parameter-type-list>.ast;
}

method direct-declarator-rest:sym<p-identifier-list>($/) {
    my $op = TyKind::function_type;
    my @children = $<identifier-list> ?? $<identifier-list>.ast !! ();
    make C::AST::TypeOp.new(:$op, :@children);
}

method pointer:sym<pointer>($/) {
    #my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    #make $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    my $op = TyKind::pointer_type;
    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    make C::AST::TypeOp.new(:$op, :@children);
}

method pointer:sym<block>($/) {
    #my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    #make $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
    my $op = TyKind::apple_block_type;
    my @children = $<type-qualifier-list>.ast;
    make C::AST::TypeOp.new(:$op, :@children);
}

method type-qualifier-list($/) {
    make map {$_.ast}, @<type-qualifier>
}

method parameter-type-list:sym<std>($/) {
    # TODO: check for ellipsis
    make $<parameter-list>.ast
}

method parameter-list($/) {
    my $op = TyKind::function_type;
    my @children = map {$_.ast}, @<parameter-declaration>;
    # TODO: 
    make C::AST::TypeOp.new(:$op, :@children);
}

method parameter-declaration:sym<declarator>($/) {
    my $type = synthesize_declaration($<declaration-specifiers>.ast, $<declarator>.ast);
    my $name = get_declarator_name($<declarator>);
    make C::AST::Arg.new(:$name, :$type);
}
method parameter-declaration:sym<abstract>($/) {
    my $type = synthesize_declaration($<declaration-specifiers>.ast, $<declarator>.ast);
    my $name = get_declarator_name($<declarator>);
    make C::AST::Arg.new(:$name, :$type);
}

method identifier-list($/) {
    make map {$_.ast}, @<ident>;
}

# SS 6.7.7

method type-name($/) {
    my @children = $<specifier-qualifier-list>.ast;
    my $decr = $<abstract-declarator>.ast;
    make C::AST::RefType.new(@children);
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
    make C::AST::Var.new()
}
method direct-abstract-declarator-first:sym<abstract>($/)  {
    make $<abstract-declarator>.ast;
}

#rule direct-abstract-declarator-rest:sym<b-type-qualifier>($/) {
#    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
#    '['
#    <type-qualifier-list>?
#    <assignment-expression>?
#    ']'
#}
#rule direct-abstract-declarator-rest:sym<b-static-type-qualifier>($/) {
#    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
#    '['
#    <static-keyword>
#    <type-qualifier-list>?
#    <assignment-expression>
#    ']'
#}
#rule direct-abstract-declarator-rest:sym<b-type-qualifier-static>($/) {
#    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
#    '['
#    <type-qualifier-list>
#    <static-keyword>
#    <assignment-expression>
#    ']'
#}
#rule direct-abstract-declarator-rest:sym<b-*>($/) {
#    my @children = $<type-qualifier-list> ?? $<type-qualifier-list>.ast !! ();
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

method static-assert-declaration($/) { # C11
    make C::AST::Op.new(
        op => OpKind::static_assert_declaration,
        children => ($<constant-expression>.ast, 
                     $<string-literal>.ast));
}

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
    my $op = OpKind::labeled_stmt;
    my @children = ($<ident>.ast, $<statement>.ast);
    make C::AST::Op.new(:$op, :@children);
}
method labeled-statement:sym<case>($/) {
    my $op = OpKind::switch_case;
    my @children = ($<constant-expression>.ast, $<statement>.ast);
    make C::AST::Op.new(:$op, :@children);
}
method labeled-statement:sym<default>($/) {
    my $op = OpKind::switch_default;
    my @children = ($<ident>.ast, $<statement>.ast);
    make C::AST::Op.new(:$op, :@children);
}

# SS 6.8.2
method compound-statement($/) {
    make $<block-item-list>.ast;
}
method block-item-list($/) {
    my $op = OpKind::compound_stmt;
    my @children = map {$_.ast}, @<block-item>;
    make C::AST::Op.new(:$op, :@children);
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
    my $op = OpKind::if_stmt;
    my @children = ($<expression>.ast, $<then_statement>.ast, $<else_statement>.ast);
    make C::AST::Op.new(:$op, :@children);
}
    
method selection-statement:sym<switch>($/) {
    my $op = OpKind::switch_stmt;
    my @children = map {$_.ast}, @<statement>;
    @children.unshift($<expression>.ast);
    make C::AST::Op.new(:$op, :@children);
}

# SS 6.8.5

# SS 6.8.6
method jump-statement:sym<goto>($/) {
    my $op = OpKind::goto_stmt;
    my @children = ($<ident>.ast);
    make C::AST::Op.new(:$op, :@children);
}
method jump-statement:sym<continue>($/) {
    my $op = OpKind::continue_stmt;
    make C::AST::Op.new(:$op);
}
method jump-statement:sym<break>($/) {
    my $op = OpKind::break_stmt;
    make C::AST::Op.new(:$op);
}
method jump-statement:sym<return>($/) {
    my $op = OpKind::return_stmt;
    my @children = ($<expression>.ast);
    make C::AST::Op.new(:$op, :@children);
}

# SS 6.9

method translation-unit($/) {
    my @children = map {$_.ast}, @<external-declaration>;
    make C::AST::TransUnit.new(:@children);
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
    my @ancients = $<declaration-list> ?? $<declaration-list>.ast !! ();

    # TODO synthesize ancients
    # TODO synthesize type

    my $op = TyKind::function_type;
    my @children = @ancients;
    @children.push(C::AST::Specs.new(children => @specs));
    @children.push($<declarator>.ast);
    
    # TODO analyze name
    
    make C::AST::Init.new(
        type => C::AST::TypeOp.new(:$op, :@children),
        value => $<compound-statement>.ast);
}
