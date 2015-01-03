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
method character-constant($/) {
    my $tag = ConstantTag::character;
    my $value = 'c';
    make Constant.new(:$tag, :$value);
}

# SS 6.4.3

method constant:sym<integer>($/) {
    make $<integer-constant>.ast;
}
method constant:sym<floating>($/) {
    make $<floating-constant>.ast;
}
method constant:sym<enumeration>($/) {
    make $<enumeration-constant>.ast;
}
method constant:sym<character>($/) {
    make $<character-constant>.ast;
}

method primary-expression:sym<identifier>($/) {
    say "Ident: " ~ $<ident>.perl;
    make $<ident>.ast;
}

method primary-expression:sym<constant>($/) { 
    say "Constant: " ~ $<constant>.perl;
    make $<constant>.ast;
}

method primary-expression:sym<string-literal>($/) { 
    say "StringConstant: " ~ $<string-literal>.perl;
    make $<string-literal>.ast;
}

method primary-expression:sym<expression>($/) {
    say "Parens: " ~ $<expression>.perl;
    make $<expression>.ast;
}

method primary-expression:sym<generic-selection>($/) { # C11
    make $<generic-selection>.ast;
}

#TODO
method generic-selection($/) {
    say "generic-selection";
    make [$<assignment-expression>.ast, 
          $<generic-assoc-list>.ast];
}

#TODO
method generic-assoc-list($/) {
    say "generic-assoc-list";
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
    make $<postfix-expression-first>.ast;
}

method postfix-expression-first:sym<primary>($/) {
    make $<primary-expression>.ast;
}

method postfix-expression-first:sym<initializer>($/) {
    my $tag = ExpressionTag::initializer;
    my $args = map {$_.ast}, @<operands>;
    $args.unshift($<operator>);
    make OpExpression.new(:$tag, :$args);
}

method postfix-expression-rest:sym<[ ]>($/) {
    make OpExpression.new(
        tag => ExpressionTag::index,
        args => [$<operand>.ast]
    );
}
method postfix-expression-rest:sym<( )>($/) {
    make OpExpression.new(
        tag => ExpressionTag::call,
        args => @<operands>
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
    make $<postfix-expression>.ast;
}

method unary-expression:sym<++>($/) {
    make OpExpression.new(
        tag => ExpressionTag::pre_increment,
        args => [$<operand>.ast]
    );
}

method unary-expression:sym<-->($/) {
    make OpExpression.new(
        tag => ExpressionTag::pre_increment,
        args => [$<operand>.ast]
    );
}
method unary-expression:sym<unary-cast>($/) {
    make OpExpression.new(
        tag => $<operator>.ast,
        args => [$<operand>.ast]
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
    my Expression $ast = $<operand>.ast;
    for @<operators> -> $operator {
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
    make binop_from_lassoc(@<operators>, @<operands>);
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
    make binop_from_lassoc(@<operators>, @<operands>);
}
method additive-operator:sym<+>($/) { 
    make ExpressionTag::plus;
}
method additive-operator:sym<->($/) { make 
    make ExpressionTag::minus;
}

# SS 6.5.7
method shift-expression($/) {
    make binop_from_lassoc(@<operators>, @<operands>);
}
method shift-operator:sym«<<»($/) {
    make ExpressionTag::left_shift;
}
method shift-operator:sym«>>»($/) {
    make ExpressionTag::right_shift;
}

# SS 6.5.8
method relational-expression($/) {
    make binop_from_lassoc(@<operators>, @<operands>);
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
    make binop_from_lassoc(@<operators>, @<operands>);
}
method equality-operator:sym<==>($/) {
    make ExpressionTag::geq;
}
method equality-operator:sym<!=>($/) {
    make ExpressionTag::geq;
}

# SS 6.5.10
method and-expression($/)  {
    make binop_from_lassoc(@<operators>, @<operands>);
}
method and-operator:sym<&>($/) {
    make ExpressionTag::bitand;
}

# SS 6.5.11
method exclusive-or-expression($/) {
    make binop_from_lassoc(@<operators>, @<operands>);
}
method exclusive-or-operator:sym<^>($/) {
    make ExpressionTag::bitxor;
}

# SS 6.5.12
method inclusive-or-expression($/) {
    make binop_from_lassoc(@<operators>, @<operands>);
}
method inclusive-or-operator:sym<|>($/) {
    make ExpressionTag::bitor;
}

# SS 6.5.13
method logical-and-expression($/) {
    make binop_from_lassoc(@<operators>, @<operands>);
}
method logical-and-operator:sym<&&>($/) {
    make ExpressionTag::and;
}

# SS 6.5.14
method logical-or-expression($/) {
    make binop_from_lassoc(@<operators>, @<operands>);
}
method logical-or-operator:sym<||>($/) {
    make ExpressionTag::or;
}

# SS 6.5.15
#method conditional-expression {
#    make binop_from_lassoc(@<operators>, @<operands>);
#    <logical-or-expression>
#    ['?' <expression> ':' <conditional-expression>]?
#}



method function-definition:sym<modern>($/) {
    make FunctionDeclaration.new(
        modifiers => @<declaration-specifiers>.ast,
        head => $<declarator>.ast,
        body => $<compound-statement>.ast,
        ancients => []
    )
}

method function-definition:sym<ancient>($/) {
    make FunctionDeclaration.new(
        modifiers => @<declaration-specifiers>.ast,
        head => $<declarator>.ast,
        ancients => $<declaration-list>.ast,
        body => $<compound-statement>.ast
    )
}
