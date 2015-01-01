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

#method integer-constant($/) {
#    $value = 2;
#    make IntegerConstant.new(:$value);
#}
#method floating-constant($/) {
#    $value = 1.0;
#    make FloatingConstant.new(:$value);
#}
#method enumeration-constant($/) {
#    $value = 'True';
#    make EnumConstant.new(:$value);
#}
#method character-constant($/) {
#    $value = 'c';
#    make CharConstant.new(:$value);
#}

method primary-expression:sym<identifier>($/) {
    make $<ident>.ast;
}

method primary-expression:sym<constant>($/) { 
    make $<constant>.ast;
}

method primary-expression:sym<string-literal>($/) { 
    make $<string-literal>.ast;
}

method primary-expression:sym<expression>($/) {
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
    make ""
#Initializer.new(
#        expr => 
#        );
#    '(' <type-name> ')'
#    '{' (<initializer-list> ','?) '}' 
}

method postfix-expression-rest:sym<[ ]>($/) {
    make $<expression>.ast;
}
method postfix-expression-rest:sym<( )>($/) {
    make $<argument-expression-list>.ast;
}

method postfix-expression-rest:sym<.>($/)   {
    make ""
}
method postfix-expression-rest:sym«->»($/)  {
    make ""
}
method postfix-expression-rest:sym<++>($/)  {
    make ""
}
method postfix-expression-rest:sym<-->($/)  {
    make ""
}

# unary
# cast-expr


# SS 6.5.5
method multiplicative-expression($/) {
    make CAST::Op.new(
        :op($<multiplicative-operator>.ast),
        @<cast-expression>.ast
    );
}

## SS 6.5.6
#rule additive-expression {
#    <multiplicative-expression>
#    (<additive-operator> <multiplicative-expression>)*
#}
#proto rule additive-operator {*}
#rule additive-operator:sym<+> { <sym> }
#rule additive-operator:sym<-> { <sym> }
#
## SS 6.5.7
#rule shift-expression {
#    <additive-expression>
#    (<shift-operator> <additive-expression>)*
#}
#proto rule shift-operator {*}
#rule shift-operator:sym«<<» { <sym> }
#rule shift-operator:sym«>>» { <sym> }
#
## SS 6.5.8
#rule relational-expression {
#    <shift-expression>
#    (<relational-operator> <shift-expression>)*
#}
#proto rule relational-operator {*}
#rule relational-operator:sym«<»  { <sym> }
#rule relational-operator:sym«>»  { <sym> }
#rule relational-operator:sym«<=» { <sym> }
#rule relational-operator:sym«>=» { <sym> }



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
