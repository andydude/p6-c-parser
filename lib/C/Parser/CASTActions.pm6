use v6;
use C::Parser::CAST;
class C::Parser::CASTActions;

method TOP($/) {
    make $/.values.[0].ast;
}

method ident($/) {
    my $name = $<name>.Str;
    make Identifier.new(:$name);
}

method integer-constant($/) {
    my $tag = ConstantTag::integer;
    my $value = 2;
    make Constant.new(:$tag, :$value);
}
method floating-constant($/) {
    my $tag = ConstantTag::floating;
    my $value = 1.0;
    make Constant.new(:$tag, :$value);
}
method enumeration-constant($/) {
    my $tag = ConstantTag::enum;
    my $value = 'True';
    make Constant.new(:$tag, :$value);
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
    my $tag = ConstantTag::character;
    my $value = $<c-char>.Str;
    make Constant.new(:$tag, :$value);
}

method string-literal:sym<quote>($/) { make $<s-char-sequence>.ast }
#method string-literal:sym<L>($/)  { make $<s-char-sequence>.ast }
#method string-literal:sym<u8>($/) { make $<s-char-sequence>.ast }
#method string-literal:sym<u>($/)  { make $<s-char-sequence>.ast }
#method string-literal:sym<U>($/)  { make $<s-char-sequence>.ast }

method s-char-sequence($/) {
    my $tag = ConstantTag::string;
    my $value = $<s-char>.Str;
    make Constant.new(:$tag, :$value);
}

method string-constant($/) {
    my $tag = ConstantTag::string;
    my $value = (map {$_.ast.value}, @<string-literal>).join;
    make Constant.new(:$tag, :$value);
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
    my $tag = ExpressionTag::initializer;
    my $args = $<initializer-list>.ast;
    $args.unshift($<type-name>.ast);
    make OpExpression.new(:$tag, :$args);
}

method postfix-expression-rest:sym<[ ]>($/) {
    make OpExpression.new(
        tag => ExpressionTag::index,
        args => [$<expression>.ast]
    );
}
method postfix-expression-rest:sym<( )>($/) {
    make OpExpression.new(
        tag => ExpressionTag::call,
        args => @<argument-expression-list>
    );
}

method postfix-expression-rest:sym<.>($/)   {
    make OpExpression.new(
        tag => ExpressionTag::direct_selector,
        args => $<ident>.ast
    );
}
method postfix-expression-rest:sym«->»($/)  {
    make OpExpression.new(
        tag => ExpressionTag::indirect_selector,
        args => $<ident>.ast
    );
}
method postfix-expression-rest:sym<++>($/)  {
    make ExpressionTag::post_increment;
}
method postfix-expression-rest:sym<-->($/)  {
    make ExpressionTag::post_decrement;
}

# unary

method unary-expression:sym<postfix>($/) {
    #say $<postfix-expression>.ast.perl;
    make $<postfix-expression>.ast;
}

method unary-expression:sym<++>($/) {
    #say "pre_increment: " ~ $<unary-expression>.ast.perl;
    make OpExpression.new(
        tag => ExpressionTag::pre_increment,
        args => [$<unary-expression>.ast]
    );
}

method unary-expression:sym<-->($/) {
    #say "pre_decrement: " ~ $<unary-expression>.ast.perl;
    make OpExpression.new(
        tag => ExpressionTag::pre_increment,
        args => [$<unary-expression>.ast]
    );
}
method unary-expression:sym<unary-cast>($/) {
    #say "cast: " ~ $<cast-expression>.ast.perl;
    make OpExpression.new(
        tag => $<unary-operator>.ast,
        args => [$<cast-expression>.ast]
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
    make ExpressionTag::pre_reference;
}
method unary-operator:sym<*> {
    make ExpressionTag::pre_dereference;
}
method unary-operator:sym<+> {
    make ExpressionTag::pre_positive;
}
method unary-operator:sym<-> {
    make ExpressionTag::pre_negative;
}
method unary-operator:sym<~> {
    make ExpressionTag::bitnot;
}
method unary-operator:sym<!> {
    make ExpressionTag::not;
}


# SS 6.5.4
method cast-expression($/) {
    my Expression $ast = $<unary-expression>.ast;
    for @<cast-operator> -> $operator {
        my $tag = C::Parser::CAST::expr_tag_from_str($operator<sym>.Str);
        $ast = OpExpression.new(
            tag => $tag,
            args => [$ast])
    }
    make $ast;
}

sub binop_from_lassoc(@operators, @operands) {
    my Expression $ast = (shift @operands).ast;
    for @operators Z @operands -> $operator, $operand {        
        if $operator.WHAT.perl ne 'Match' {
            die "expected operator to be of type `Match`";
        }
        my $tag = C::Parser::CAST::expr_tag_from_str($operator<sym>.Str);
        $ast = OpExpression.new(
            tag => $tag,
            args => [$ast, $operand]
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
    make ExpressionTag::times;
}
method multiplicative-operator:sym</>($/) {
    make ExpressionTag::divide;
}
method multiplicative-operator:sym<%>($/) {
    make ExpressionTag::remainder;
}

# SS 6.5.6
method additive-expression($/) {
    make binop_from_lassoc(@<additive-operator>, @<operands>);
}
method additive-operator:sym<+>($/) { 
    make ExpressionTag::plus;
}
method additive-operator:sym<->($/) { make 
    make ExpressionTag::minus;
}

# SS 6.5.7
method shift-expression($/) {
    make binop_from_lassoc(@<shift-operator>, @<operands>);
}
method shift-operator:sym«<<»($/) {
    make ExpressionTag::left_shift;
}
method shift-operator:sym«>>»($/) {
    make ExpressionTag::right_shift;
}

# SS 6.5.8
method relational-expression($/) {
    make binop_from_lassoc(@<relational-operator>, @<operands>);
}
method relational-operator:sym«<»($/) {
    make ExpressionTag::lt;
}
method relational-operator:sym«>»($/) {
    make ExpressionTag::gt;
}
method relational-operator:sym«<=»($/) {
    make ExpressionTag::leq;
}
method relational-operator:sym«>=»($/) {
    make ExpressionTag::geq;
}

# SS 6.5.9
method equality-expression($/) {
    make binop_from_lassoc(@<equality-operator>, @<operands>);
}
method equality-operator:sym<==>($/) {
    make ExpressionTag::geq;
}
method equality-operator:sym<!=>($/) {
    make ExpressionTag::geq;
}

# SS 6.5.10
method and-expression($/)  {
    make binop_from_lassoc(@<and-operator>, @<operands>);
}
method and-operator:sym<&>($/) {
    make ExpressionTag::bitand;
}

# SS 6.5.11
method exclusive-or-expression($/) {
    make binop_from_lassoc(@<exclusive-or-operator>, @<operands>);
}
method exclusive-or-operator:sym<^>($/) {
    make ExpressionTag::bitxor;
}

# SS 6.5.12
method inclusive-or-expression($/) {
    make binop_from_lassoc(@<inclusive-or-operator>, @<operands>);
}
method inclusive-or-operator:sym<|>($/) {
    make ExpressionTag::bitor;
}

# SS 6.5.13
method logical-and-expression($/) {
    make binop_from_lassoc(@<logical-and-operator>, @<operands>);
}
method logical-and-operator:sym<&&>($/) {
    make ExpressionTag::and;
}

# SS 6.5.14
method logical-or-expression($/) {
    make binop_from_lassoc(@<logical-or-operator>, @<operands>);
}
method logical-or-operator:sym<||>($/) {
    make ExpressionTag::or;
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
    make ExpressionTag::assign;
}
method assignment-operator:sym<*=>($/)   {
    make ExpressionTag::assign_times;
}
method assignment-operator:sym</=>($/)   {
    make ExpressionTag::assign_divide;
}
method assignment-operator:sym<%=>($/)   {
    make ExpressionTag::assign_remainder;
}
method assignment-operator:sym<+=>($/)   {
    make ExpressionTag::assign_plus;
}
method assignment-operator:sym<-=>($/)   {
    make ExpressionTag::assign_minus;
}
method assignment-operator:sym«<<=»($/)  {
    make ExpressionTag::assign_left_shift;
}
method assignment-operator:sym«>>=»($/)  {
    make ExpressionTag::assign_right_shift;
}
method assignment-operator:sym<&=>($/)   {
    make ExpressionTag::assign_bitand;
}
method assignment-operator:sym<^=>($/)   {
    make ExpressionTag::assign_bitxor;
}
method assignment-operator:sym<|=>($/)   {
    make ExpressionTag::assign_bitor;
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
        modifiers => $<declaration-specifiers>.ast,
        inits => $<init-declarator-list>.ast
    )
}
method declaration:sym<static_assert>($/) { # C11
    make $<static-assert-declaration>.ast;
}

method declaration-specifiers($/) {
    make map {$_.ast}, @<declaration-specifier>;
}


method declaration-specifier:sym<storage-class>($/) {
    make StorageSpecifier.new(tag => $<storage-class-specifier>.ast);
}
method declaration-specifier:sym<type-specifier>($/) {
    make TypeSpecifier.new(tag => $<type-specifier>.ast);
}
method declaration-specifier:sym<type-qualifier>($/) {
    make TypeQualifier.new(tag => $<type-qualifier>.ast);
}
method declaration-specifier:sym<function>($/) {
    make FunctionSpecifier.new(tag => $<function-specifier>.ast);
}
method declaration-specifier:sym<alignment>($/) {
    make $<alignment-specifier>.ast;
}


method init-declarator-list($/) {
    my $declarator = @<init-declarator>[0];
    make $declarator.ast;
}
method init-declarator($/) {
    #say $<declarator>.ast.perl;
    #say $<initializer>.ast.perl;
    my $decl = $<declarator> ?? $<declarator>.ast !! Declarator.new();
    my $init = $<initializer> ?? $<initializer>.ast !! Initializer.new();
    make InitDeclarator.new(:$decl, :$init);
}

# SS 6.7.1
method storage-class-specifier:sym<typedef>($/) {
    make StorageSpecifierTag::typedef;
}
method storage-class-specifier:sym<extern>($/) {
    make StorageSpecifierTag::extern;
}
method storage-class-specifier:sym<static>($/) {
    make StorageSpecifierTag::static;
}
method storage-class-specifier:sym<_Thread_local>($/) {
    make StorageSpecifierTag::thread_local;
}
method storage-class-specifier:sym<auto>($/) {
    make StorageSpecifierTag::auto;
}
method storage-class-specifier:sym<register>($/) {
    make StorageSpecifierTag::register;
}

# SS 6.7.2
method type-specifier:sym<void>($/)     { make TypeSpecifierTag::void }
method type-specifier:sym<char>($/)     { make TypeSpecifierTag::char }
method type-specifier:sym<short>($/)    { make TypeSpecifierTag::short }
method type-specifier:sym<int>($/)      { make TypeSpecifierTag::int }
method type-specifier:sym<long>($/)     { make TypeSpecifierTag::long }
method type-specifier:sym<float>($/)    { make TypeSpecifierTag::float }
method type-specifier:sym<double>($/)   { make TypeSpecifierTag::double }
method type-specifier:sym<signed>($/)   { make TypeSpecifierTag::signed }
method type-specifier:sym<unsigned>($/) { make TypeSpecifierTag::unsigned }
method type-specifier:sym<_Bool>($/)    { make TypeSpecifierTag::bool }
method type-specifier:sym<_Complex>($/) { make TypeSpecifierTag::complex }

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
method type-qualifier:sym<const>($/)    { make TypeQualifierTag::const }
method type-qualifier:sym<restrict>($/) { make TypeQualifierTag::restrict }
method type-qualifier:sym<volatile>($/) { make TypeQualifierTag::volatile }
method type-qualifier:sym<_Atomic>($/)  { make TypeQualifierTag::atomic }

# SS 6.7.4
method function-specifier:sym<inline>($/)    { make FunctionSpecifierTag::inline }
method function-specifier:sym<_Noreturn>($/) { make FunctionSpecifierTag::noreturn }

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
    make $<direct-declarator>.ast;
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

method type-qualifier-list($/) {
    make map {$_.ast}, @<type-qualifier>
}

method parameter-type-list:sym<std>($/) {
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
#        decr => $<abstract-declarator>.ast
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
    make JumpStatement.new(
        tag => JumpTag::goto,
            label => $<ident>.ast)
}
method jump-statement:sym<continue>($/) {
    make JumpStatement.new(
        tag => JumpTag::continue)
}
method jump-statement:sym<break>($/) {
    make JumpStatement.new(
        tag => JumpTag::break)
}
method jump-statement:sym<return>($/) {
    make JumpStatement.new(
        tag => JumpTag::return,
            expr => $<expression>.ast)
}

# SS 6.9
method translation-unit($/) {
    my @decls = map {$_.ast}, @<external-declaration>;
    make TranslationUnit.new(:@decls);
}

method external-declaration:sym<function-definition>($/) {
    make $<function-definition>.ast;
}
method external-declaration:sym<declaration>($/) {
    make $<declaration>.ast;
}

# SS 6.9.1
method function-definition:sym<std>($/) {
    my @modifiers = map {$_.ast}, @<declaration-specifiers>;
    my @ancients = map {$_.ast}, @<declaration-list>;
    my $head = $<declarator>.ast;
    my $body = $<compound-statement>.ast;
    make FunctionDeclaration.new(
        :@modifiers, :$head,
        :@ancients, :$body);
}
