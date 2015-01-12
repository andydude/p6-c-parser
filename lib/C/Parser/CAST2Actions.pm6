use v6;
use CAST;
class C::Parser::CAST2Actions;

method TOP($/) {
    make $/.values.[0].ast;
}

method ident($/) {
    make $<name>.Str;
}

method integer-constant($/) {
    my Int $value = 2;
    make CAST::IVal.new(:$value);
}
method floating-constant($/) {
    my Num $value = 1.0;
    make CAST::NVal.new(:$value);
}
method enumeration-constant($/) {
    # TODO, both identifier + value
    my Str $value = 'True';
    make CAST::EVal.new(:$value);
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
    make CAST::CVal.new(:$value);
}

method string-literal:sym<quote>($/) { make $<s-char-sequence>.ast }
#method string-literal:sym<L>($/)  { make $<s-char-sequence>.ast }
#method string-literal:sym<u8>($/) { make $<s-char-sequence>.ast }
#method string-literal:sym<u>($/)  { make $<s-char-sequence>.ast }
#method string-literal:sym<U>($/)  { make $<s-char-sequence>.ast }

method s-char-sequence($/) {
    my $value = $<s-char>.Str;
    make CAST::SVal.new(:$value);
}

method string-constant($/) {
    my $value = (map {$_.ast.value}, @<string-literal>).join;
    make CAST::SVal.new(:$value);
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
    my $kind = CAST::Op::OpKind::initializer;
    my $children = $<initializer-list>.ast;
    $children.unshift($<type-name>.ast);
    make CAST::Op.new(:$kind, :$children);
}

method postfix-expression-rest:sym<[ ]>($/) {
    make CAST::Op.new(
        kind => CAST::Op::OpKind::index,
        children => [$<expression>.ast]
    );
}
method postfix-expression-rest:sym<( )>($/) {
    make CAST::Op.new(
        kind => CAST::Op::OpKind::call,
        children => @<argument-expression-list>
    );
}

method postfix-expression-rest:sym<.>($/)   {
    make CAST::Op.new(
        kind => CAST::Op::OpKind::direct_selector,
        children => $<ident>.ast
    );
}
method postfix-expression-rest:sym«->»($/)  {
    make CAST::Op.new(
        kind => CAST::Op::OpKind::indirect_selector,
        children => $<ident>.ast
    );
}
method postfix-expression-rest:sym<++>($/)  {
    make CAST::Op::OpKind::postinc;
}
method postfix-expression-rest:sym<-->($/)  {
    make CAST::Op::OpKind::postdec;
}

# unary

method unary-expression:sym<postfix>($/) {
    #say $<postfix-expression>.ast.perl;
    make $<postfix-expression>.ast;
}

method unary-expression:sym<++>($/) {
    #say "pre_increment: " ~ $<unary-expression>.ast.perl;
    make CAST::Op.new(CAST::Op::OpKind::preinc,
        children => [$<unary-expression>.ast]
    );
}

method unary-expression:sym<-->($/) {
    #say "pre_decrement: " ~ $<unary-expression>.ast.perl;
    make CAST::Op.new(CAST::Op::OpKind::predec,
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
    make CAST::Op::OpKind::pre_reference;
}
method unary-operator:sym<*> {
    make CAST::Op::OpKind::pre_dereference;
}
method unary-operator:sym<+> {
    make CAST::Op::OpKind::pre_positive;
}
method unary-operator:sym<-> {
    make CAST::Op::OpKind::pre_negative;
}
method unary-operator:sym<~> {
    make CAST::Op::OpKind::bitnot;
}
method unary-operator:sym<!> {
    make CAST::Op::OpKind::not;
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
        my $kind = $operator.ast;
        $ast = CAST::Op.new(
            kind => $kind,
            children => [$ast, $operand]
        );
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
    make CAST::Op::OpKind::times;
}
method multiplicative-operator:sym</>($/) {
    make CAST::Op::OpKind::divide;
}
method multiplicative-operator:sym<%>($/) {
    make CAST::Op::OpKind::remainder;
}

# SS 6.5.6
method additive-expression($/) {
    make binop_from_lassoc(@<additive-operator>, @<operands>);
}
method additive-operator:sym<+>($/) { 
    make CAST::Op::OpKind::plus;
}
method additive-operator:sym<->($/) { make 
    make CAST::Op::OpKind::minus;
}

# SS 6.5.7
method shift-expression($/) {
    make binop_from_lassoc(@<shift-operator>, @<operands>);
}
method shift-operator:sym«<<»($/) {
    make CAST::Op::OpKind::left_shift;
}
method shift-operator:sym«>>»($/) {
    make CAST::Op::OpKind::right_shift;
}

# SS 6.5.8
method relational-expression($/) {
    make binop_from_lassoc(@<relational-operator>, @<operands>);
}
method relational-operator:sym«<»($/) {
    make CAST::Op::OpKind::lt;
}
method relational-operator:sym«>»($/) {
    make CAST::Op::OpKind::gt;
}
method relational-operator:sym«<=»($/) {
    make CAST::Op::OpKind::leq;
}
method relational-operator:sym«>=»($/) {
    make CAST::Op::OpKind::geq;
}

# SS 6.5.9
method equality-expression($/) {
    make binop_from_lassoc(@<equality-operator>, @<operands>);
}
method equality-operator:sym<==>($/) {
    make CAST::Op::OpKind::geq;
}
method equality-operator:sym<!=>($/) {
    make CAST::Op::OpKind::geq;
}

# SS 6.5.10
method and-expression($/)  {
    make binop_from_lassoc(@<and-operator>, @<operands>);
}
method and-operator:sym<&>($/) {
    make CAST::Op::OpKind::bitand;
}

# SS 6.5.11
method exclusive-or-expression($/) {
    make binop_from_lassoc(@<exclusive-or-operator>, @<operands>);
}
method exclusive-or-operator:sym<^>($/) {
    make CAST::Op::OpKind::bitxor;
}

# SS 6.5.12
method inclusive-or-expression($/) {
    make binop_from_lassoc(@<inclusive-or-operator>, @<operands>);
}
method inclusive-or-operator:sym<|>($/) {
    make CAST::Op::OpKind::bitor;
}

# SS 6.5.13
method logical-and-expression($/) {
    make binop_from_lassoc(@<logical-and-operator>, @<operands>);
}
method logical-and-operator:sym<&&>($/) {
    make CAST::Op::OpKind::and;
}

# SS 6.5.14
method logical-or-expression($/) {
    make binop_from_lassoc(@<logical-or-operator>, @<operands>);
}
method logical-or-operator:sym<||>($/) {
    make CAST::Op::OpKind::or;
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
    make CAST::Op::OpKind::assign;
}
method assignment-operator:sym<*=>($/)   {
    make CAST::Op::OpKind::assign_times;
}
method assignment-operator:sym</=>($/)   {
    make CAST::Op::OpKind::assign_divide;
}
method assignment-operator:sym<%=>($/)   {
    make CAST::Op::OpKind::assign_remainder;
}
method assignment-operator:sym<+=>($/)   {
    make CAST::Op::OpKind::assign_plus;
}
method assignment-operator:sym<-=>($/)   {
    make CAST::Op::OpKind::assign_minus;
}
method assignment-operator:sym«<<=»($/)  {
    make CAST::Op::OpKind::assign_left_shift;
}
method assignment-operator:sym«>>=»($/)  {
    make CAST::Op::OpKind::assign_right_shift;
}
method assignment-operator:sym<&=>($/)   {
    make CAST::Op::OpKind::assign_bitand;
}
method assignment-operator:sym<^=>($/)   {
    make CAST::Op::OpKind::assign_bitxor;
}
method assignment-operator:sym<|=>($/)   {
    make CAST::Op::OpKind::assign_bitor;
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
    make Declaration.new(
        specs => map {$_.ast}, @<declaration-specifiers>,
        inits => map {$_.ast}, @<init-declarator-list>
    )
}
method declaration:sym<static_assert>($/) { # C11
    make $<static-assert-declaration>.ast;
}

method declaration-specifiers($/) {
    make DirectType.new(
        specs => map {$_.ast}, @<declaration-specifier>
    );
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
    my $declarator = @<init-declarator>[0];
    make $declarator.ast;
}
method init-declarator($/) {
    my $decl = $<declarator> ?? $<declarator>.ast !! Declarator.new();
    my $init = $<initializer> ?? $<initializer>.ast !! Initializer.new();
    make InitDeclarator.new(:$decl, :$init);
}

# SS 6.7.1
method storage-class-specifier:sym<typedef>($/) {
    make CAST::Type::TypeSpec::typedef;
}
method storage-class-specifier:sym<extern>($/) {
    make CAST::Type::TypeSpec::extern;
}
method storage-class-specifier:sym<static>($/) {
    make CAST::Type::TypeSpec::static;
}
method storage-class-specifier:sym<_Thread_local>($/) {
    make CAST::Type::TypeSpec::thread_local;
}
method storage-class-specifier:sym<auto>($/) {
    make CAST::Type::TypeSpec::auto;
}
method storage-class-specifier:sym<register>($/) {
    make CAST::Type::TypeSpec::register;
}

# SS 6.7.2
method type-specifier:sym<void>($/)     { make CAST::Type::TypeSpec::void }
method type-specifier:sym<char>($/)     { make CAST::Type::TypeSpec::char }
method type-specifier:sym<short>($/)    { make CAST::Type::TypeSpec::short }
method type-specifier:sym<int>($/)      { make CAST::Type::TypeSpec::int }
method type-specifier:sym<long>($/)     { make CAST::Type::TypeSpec::long }
method type-specifier:sym<float>($/)    { make CAST::Type::TypeSpec::float }
method type-specifier:sym<double>($/)   { make CAST::Type::TypeSpec::double }
method type-specifier:sym<signed>($/)   { make CAST::Type::TypeSpec::signed }
method type-specifier:sym<unsigned>($/) { make CAST::Type::TypeSpec::unsigned }
method type-specifier:sym<_Bool>($/)    { make CAST::Type::TypeSpec::bool }
method type-specifier:sym<_Complex>($/) { make CAST::Type::TypeSpec::complex }

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
method type-qualifier:sym<const>($/)    { make CAST::Type::TypeSpec::const }
method type-qualifier:sym<restrict>($/) { make CAST::Type::TypeSpec::restrict }
method type-qualifier:sym<volatile>($/) { make CAST::Type::TypeSpec::volatile }
method type-qualifier:sym<_Atomic>($/)  { make CAST::Type::TypeSpec::atomic }

# SS 6.7.4
method function-specifier:sym<inline>($/)    { make CAST::Type::TypeSpec::inline }
method function-specifier:sym<_Noreturn>($/) { make CAST::Type::TypeSpec::noreturn }

# SS 6.7.5
method alignment-specifier:sym<type-name>($/) {
    make AlignAsTypeSpecifier.new(ident => $<type-name>.ast);
}
method alignment-specifier:sym<constant>($/) {
    make AlignAsTypeSpecifier.new(expr => $<constant-expression>.ast);
}



# SS 6.7.6
method declarator:sym<direct>($/) {
    # TODO
    my $ast = $<direct-declarator>.ast;
    for @<pointer> -> $pointer {
        $ast = PointerDeclarator.new(
            quals => $pointer.ast,
            direct => $ast
        );
    }
    make $ast;
}

method direct-declarator($/) {
    make DirectDeclarator.new(
        first => $<direct-declarator-first>.ast,
        rest => map {$_.ast}, @<direct-declarator-rest>)
}

method direct-declarator-first:sym<identifier>($/) {
    make $<ident>.ast;
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
    my @quals = map {$_.ast}, @<type-qualifier-list>;
    make PointerDeclarator.new(:@quals);
}

method pointer:sym<block>($/) {
    my @quals = map {$_.ast}, @<type-qualifier-list>;
    make PointerDeclarator.new(:@quals);
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
    make ParameterDeclaration.new(
        decls => map {$_.ast}, @<declaration-specifiers>,
        decr => $<declarator>.ast
    )
}
method parameter-declaration:sym<abstract>($/) {
    make ParameterDeclaration.new(
        decls => map {$_.ast}, @<declaration-specifiers>
    )
}

method identifier-list($/) { make map {$_.ast}, @<ident> }

# SS 6.7.7
method type-name($/) {
    make TypeName.new(
        specs => @<specifier-qualifier-list>,
        decr => $<abstract-declarator>);
}
method abstract-declarator:sym<pointer>($/)  {
    make $<pointer>.ast;
}
method abstract-declarator:sym<direct-abstract>($/) {
    # TODO
    make $<direct-abstract-declarator>.ast;
}

method direct-abstract-declarator($/) {
    make AbstractDeclarator.new(
        first => $<direct-abstract-declarator-first>,
            rest => @<direct-abstract-declarator-rest>)
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
method typedef-name($/) { make $<ident>.ast }

# SS 6.7.9
method initializer:sym<assignment>($/) {
    make Initializer.new(expr => $<assignment-expression>.ast);
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
    make LabeledStatement.new(
        ident => $<ident>.ast,
        stmt => $<statement>.ast
    )
}
method labeled-statement:sym<case>($/) {
    make CaseStatement.new(
        expr => $<constant-expression>.ast,
        stmt => $<statement>.ast
    )
}
method labeled-statement:sym<default>($/) {
    make DefaultStatement.new(
        stmt => $<statement>.ast
    )
}

# SS 6.8.2
method compound-statement($/) {
    make $<block-item-list>.ast;
}
method block-item-list($/) {
    my @items = map {$_.ast}, @<block-item>;
    make BlockStatement.new(:@items);
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
    make IfStatement.new(
        expr => $<expression>.ast,
        con => $<then_statement>.ast,
        alt => $<else_statement>.ast
    )
}
    
method selection-statement:sym<switch>($/) {
    make SwitchStatement.new(
        expr => $<expression>.ast,
        stmts => map {$_.ast}, @<statement>
    )
}

# SS 6.8.5

# SS 6.8.6
method jump-statement:sym<goto>($/) {
    make CAST::Op.new(
        kind => CAST::Op::OpKind::goto,
            label => $<ident>.ast)
}
method jump-statement:sym<continue>($/) {
    make CAST::Op.new(
        kind => CAST::Op::OpKind::continue)
}
method jump-statement:sym<break>($/) {
    make CAST::Op.new(
        kind => CAST::Op::OpKind::break)
}
method jump-statement:sym<return>($/) {
    make CAST::Op.new(
        kind => CAST::Op::OpKind::return,
        expr => $<expression>.ast)
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
    my $body = $<compound-statement>.ast;
    make FunctionDeclaration.new(:@specs, :$head, :@ancients, :$body);
}
