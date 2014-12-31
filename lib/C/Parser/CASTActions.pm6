use C::Parser::CAST;
class C::Parser::CASTActions;

method TOP($/) {
    make $/.values.[0].ast;
}

method primary-expression:sym<identifier>($/) {
    make $<ident>.ast
}

method primary-expression:sym<constant>($/) { 
    make $<constant>.ast
}

method primary-expression:sym<string-literal>($/) { 
    make $<string-literal>.ast
}

method primary-expression:sym<expression>($/) {
    make $<expression>.ast
}

method primary-expression:sym<generic-selection>($/) { # C11
    make $<generic-selection>.ast
}

method generic-selection($/) {
    say "generic-selection";
    make [$<assignment-expression>.ast, 
          $<generic-assoc-list>.ast];
}

method generic-assoc-list($/) {
    say "generic-assoc-list";
    make [$<generic-association>.ast, 
          $<generic-association>.ast];
}

method generic-association:sym<typename>($/) {
    make [$<type-name>.ast,
         $<assignment-expression>.ast];
}
method generic-association:sym<default>($/) {
    make [$<assignment-expression>.ast];
}

method postfix-expression($/) {
    make ""
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
    make ""
}
method postfix-expression-rest:sym<( )>($/) {
    make ""
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
