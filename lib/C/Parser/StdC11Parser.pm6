# References ISO/IEC 9899:1990 "Information technology - Programming Language C" (C89 for short)
use v6;
#use Grammar::Tracer;
use C::Parser::StdC11Lexer;
grammar C::Parser::StdC11Parser is C::Parser::StdC11Lexer;

my $*EXTERN_CONTEXT = False;
my $*STATIC_CONTEXT = False;
my %*STRUCTS;

rule TOP {^ <translation-unit> $}

# SS 6.5.1

proto rule primary-expression {*}
rule primary-expression:sym<identifier> {
    <ident>
}
rule primary-expression:sym<constant> {
    <constant>
}
rule primary-expression:sym<string-literal> {
    <string-literal>
}
rule primary-expression:sym<expression> {
    '(' <expression> ')'
}
rule primary-expression:sym<generic-selection> { # C11
    <generic-selection>
}

# SS 6.5.1.1
rule generic-selection {
    <generic-keyword>
    '('
    <assignment-expression> ','
    <generic-assoc-list>
    ')'
}

rule generic-assoc-list {
    <generic-association> [',' <generic-association>]*
}

proto rule generic-association {*}
rule generic-association:sym<typename> {
    <type-name> ':' <assignment-expression>
}
rule generic-association:sym<default> {
    <default-keyword> ':' <assignment-expression>
}

# SS 6.5.2
rule postfix-expression {
    <postfix-expression-first>
    <postfix-expression-rest>*
}

proto rule postfix-expression-first {*}
rule postfix-expression-first:sym<primary> { <primary-expression> }
rule postfix-expression-first:sym<initializer> {
    '('
    <type-name>
    ')'
    '{'
    <initializer-list> ','?
    '}'
}

proto rule postfix-expression-rest {*}
rule postfix-expression-rest:sym<[ ]> {
    '['
    <expression>
    ']'
}
rule postfix-expression-rest:sym<( )> {
    '('
    <argument-expression-list>?
    ')'
}
rule postfix-expression-rest:sym<.>   { <sym> <ident> }
rule postfix-expression-rest:sym«->»  { <sym> <ident> }
rule postfix-expression-rest:sym<++>  { <sym> }
rule postfix-expression-rest:sym<-->  { <sym> }

rule argument-expression-list {
    <assignment-expression> [',' <assignment-expression>]*
}

# SS 6.5.3
proto rule unary-expression {*}
rule unary-expression:sym<postfix> { <postfix-expression> }
rule unary-expression:sym<++> { <sym> <unary-expression> }
rule unary-expression:sym<--> { <sym> <unary-expression> }
rule unary-expression:sym<unary-cast> {
    <unary-operator> <cast-expression>
}
rule unary-expression:sym<size-of-expr> {
    <sizeof-keyword> <unary-expression>
}
rule unary-expression:sym<size-of-type> {
    <sizeof-keyword> '(' <type-name> ')'
}
rule unary-expression:sym<align-of-type> {
    <alignof-keyword> '(' <type-name> ')'
}

proto rule unary-operator {*}
rule unary-operator:sym<&> { <sym> }
rule unary-operator:sym<*> { <sym> }
rule unary-operator:sym<+> { <sym> }
rule unary-operator:sym<-> { <sym> }
rule unary-operator:sym<~> { <sym> }
rule unary-operator:sym<!> { <sym> }

# SS 6.5.4
rule cast-expression { <cast-operator>* <unary-expression> }

# Nonstandard: cast-operator does not exist in C89 grammar
# Rationale: these tokens appear in many rules, and although
# it would simplify the grammar, the semantics would be different
# so we only use it in the place where it's supposed to be.
rule cast-operator { '(' <type-name> ')' }

# SS 6.5.5
rule multiplicative-expression {
    <cast-expression>
    (<multiplicative-operator> <cast-expression>)*
}
proto rule multiplicative-operator {*}
rule multiplicative-operator:sym<*> { <sym> }
rule multiplicative-operator:sym</> { <sym> }
rule multiplicative-operator:sym<%> { <sym> }

# SS 6.5.6
rule additive-expression {
    <multiplicative-expression>
    (<additive-operator> <multiplicative-expression>)*
}
proto rule additive-operator {*}
rule additive-operator:sym<+> { <sym> }
rule additive-operator:sym<-> { <sym> }

# SS 6.5.7
rule shift-expression {
    <additive-expression>
    (<shift-operator> <additive-expression>)*
}
proto rule shift-operator {*}
rule shift-operator:sym«<<» { <sym> }
rule shift-operator:sym«>>» { <sym> }

# SS 6.5.8
rule relational-expression {
    <shift-expression>
    (<relational-operator> <shift-expression>)*
}
proto rule relational-operator {*}
rule relational-operator:sym«<»  { <sym> }
rule relational-operator:sym«>»  { <sym> }
rule relational-operator:sym«<=» { <sym> }
rule relational-operator:sym«>=» { <sym> }

# SS 6.5.9
rule equality-expression {
    <relational-expression>
    (<equality-operator> <relational-expression>)*
}
proto rule equality-operator {*}
rule equality-operator:sym<==> { <sym> }
rule equality-operator:sym<!=> { <sym> }

# SS 6.5.10
rule and-expression {
    <equality-expression>
    (<and-operator> <equality-expression>)*
}
proto rule and-operator {*}
rule and-operator:sym<&> { <sym> }

# SS 6.5.11
rule exclusive-or-expression {
    <and-expression>
    (<exclusive-or-operator> <and-expression>)*
}

proto rule exclusive-or-operator {*}
rule exclusive-or-operator:sym<^> { <sym> }

# SS 6.5.12
rule inclusive-or-expression {
    <exclusive-or-expression>
    (<inclusive-or-operator> <exclusive-or-expression>)*
}
proto rule inclusive-or-operator {*}
rule inclusive-or-operator:sym<|> { <sym> }

# SS 6.5.13
rule logical-and-expression {
    <inclusive-or-expression>
    (<logical-and-operator> <inclusive-or-expression>)*
}
proto rule logical-and-operator {*}
rule logical-and-operator:sym<&&> { <sym> }

# SS 6.5.14
rule logical-or-expression {
    <logical-and-expression>
    (<logical-or-operator> <logical-and-expression>)*
}
proto rule logical-or-operator {*}
rule logical-or-operator:sym<||> { <sym> }

# SS 6.5.15
rule conditional-expression {
    <logical-or-expression>
    ('?' <expression> ':' <conditional-expression>)?
}

# SS 6.5.16
rule assignment-expression {
    (<unary-expression> <assignment-operator>)*
    <conditional-expression>
}
proto rule assignment-operator {*}
rule assignment-operator:sym<=>   { <sym> }
rule assignment-operator:sym<*=>  { <sym> }
rule assignment-operator:sym</=>  { <sym> }
rule assignment-operator:sym<%=>  { <sym> }
rule assignment-operator:sym<+=>  { <sym> }
rule assignment-operator:sym<-=>  { <sym> }
rule assignment-operator:sym«<<=» { <sym> }
rule assignment-operator:sym«>>=» { <sym> }
rule assignment-operator:sym<&=>  { <sym> }
rule assignment-operator:sym<^=>  { <sym> }
rule assignment-operator:sym<|=>  { <sym> }

# SS 6.5.17
rule expression {
    <assignment-expression> [',' <assignment-expression>]*
}

# SS 6.6
rule constant-expression { <conditional-expression> }

# SS 6.7
proto rule declaration {*}
rule declaration:sym<declaration> {
    <declaration-specifiers> <init-declarator-list>? ';'
}
rule declaration:sym<static_assert> { # C11
    <static-assert-declaration>
}

rule declaration-specifiers {
    { say "declaration-specifiers 1"; }
    <declaration-specifier>+
    { say "declaration-specifiers 2"; }
    {
        if $*TYPEDEF_CONTEXT {
            #my $typedef_name = $<declaration-specifier>[*-1]<type-specifier><typedef-name><ident><name>.Str;
            #my @typedef_type = $<declaration-specifier>[1..*-2];
            #%*TYPEDEFS{$typedef_name} = @typedef_type;
            $*TYPEDEF_CONTEXT = False;
        }
    }
    { say "declaration-specifiers 3"; }
}

# Nonstandard: declaration-specifier does not exist in C89 grammar
# Rationale: declaration-specifiers includes itself in every RHS
# so we factor it out as <declaration-specifier>+ which means the same.
proto rule declaration-specifier {*}
rule declaration-specifier:sym<storage-class> {
    { say "declaration-specifier:sym<storage-class> 1"; }
    <storage-class-specifier>
    { say "declaration-specifier:sym<storage-class> 2"; }
}
rule declaration-specifier:sym<type-specifier> {
    { say "declaration-specifier:sym<type-specifier> 1"; }
    <type-specifier>
    { say "declaration-specifier:sym<type-specifier> 2"; }
}
rule declaration-specifier:sym<type-qualifier> {
    { say "declaration-specifier:sym<type-qualifier> 1"; }
    <type-qualifier>
    { say "declaration-specifier:sym<type-qualifier> 2"; }
}
rule declaration-specifier:sym<function> {
    { say "declaration-specifier:sym<function> 1"; }
    <function-specifier>
    { say "declaration-specifier:sym<function> 2"; }
}
rule declaration-specifier:sym<alignment> {
    { say "declaration-specifier:sym<alignment> 1"; }
    <alignment-specifier>
    { say "declaration-specifier:sym<alignment> 2"; }
}

rule init-declarator-list { <init-declarator> [',' <init-declarator>]* }
rule init-declarator { <declarator> ['=' <initializer>]? }

# SS 6.7.1
proto rule storage-class-specifier {*}
rule storage-class-specifier:sym<typedef>  { <sym> { $*TYPEDEF_CONTEXT = True; } }
rule storage-class-specifier:sym<extern>   { <sym> { $*EXTERN_CONTEXT = True; } }
rule storage-class-specifier:sym<static>   { <sym> { $*STATIC_CONTEXT = True; } }
rule storage-class-specifier:sym<_Thread_local> { <sym> { $*THREAD_LOCAL_CONTEXT = True; } }
rule storage-class-specifier:sym<auto>     { <sym> { $*AUTO_CONTEXT = True; } }
rule storage-class-specifier:sym<register> { <sym> { $*REGISTER_CONTEXT = True; } }

# SS 6.7.2
proto rule type-specifier {*}
rule type-specifier:sym<void>     { <sym> }
rule type-specifier:sym<char>     { <sym> }
rule type-specifier:sym<short>    { <sym> }
rule type-specifier:sym<int>      { <sym> }
rule type-specifier:sym<long>     { <sym> }
rule type-specifier:sym<float>    { <sym> }
rule type-specifier:sym<double>   { <sym> }
rule type-specifier:sym<signed>   { <sym> }
rule type-specifier:sym<unsigned> { <sym> }
rule type-specifier:sym<_Bool>    { <sym> }
rule type-specifier:sym<_Complex> { <sym> }
rule type-specifier:sym<atomic-type>     {
    { say "type-specifier:sym<atomic-type> 1"; }
    <atomic-type-specifier>
    { say "type-specifier:sym<atomic-type> 1"; }
}
rule type-specifier:sym<struct-or-union> {
    { say "type-specifier:sym<struct-or-union> 1"; }
    <struct-or-union-specifier>
    { say "type-specifier:sym<struct-or-union> 2"; }
}
# TODO
rule type-specifier:sym<enum-specifier>  {
    { say "type-specifier:sym<enum-specifier> 1"; }
    <enum-specifier>
    { say "type-specifier:sym<enum-specifier> 2"; }
}
rule type-specifier:sym<typedef-name>    {
    { say "type-specifier:sym<typedef-name> 1"; }
    <typedef-name>
    { say "type-specifier:sym<typedef-name> 2" ~ $<typedef-name>; }
    #<?{ ($*TYPEDEF_CONTEXT) || (%*TYPEDEFS{$<typedef-name><ident><name>.Str}:exists) }>
    <?{ ($*TYPEDEF_CONTEXT) || (%*TYPEDEFS{$<typedef-name><ident><name>.Str}:exists) }>
    { say "type-specifier:sym<typedef-name> 3"; }
}
# TODO: add check for if it's been typedef'd

# SS 6.7.2.1
proto rule struct-or-union-specifier {*}
rule struct-or-union-specifier:sym<decl> {
    { say "struct-or-union-specifier:sym<decl> 1"; }
    <struct-or-union> <ident>?
    '{' <struct-declaration-list> '}'
    { say "struct-or-union-specifier:sym<decl> 2"; }
}
rule struct-or-union-specifier:sym<spec> {
    { say "struct-or-union-specifier:sym<spec> 1"; }
    <struct-or-union> <ident> <!before '{'>
    { say "struct-or-union-specifier:sym<spec> 2"; }
}

proto rule struct-or-union {*}
rule struct-or-union:sym<struct> {
    <struct-keyword>
}
rule struct-or-union:sym<union>  {
    <union-keyword>
}

rule struct-declaration-list {
    <struct-declaration>+
}

proto rule struct-declaration {*}
rule struct-declaration:sym<struct> {
    <specifier-qualifier-list> <struct-declarator-list>? ';'
}
rule struct-declaration:sym<static_assert> { # C11
    <static-assert-declaration>
}

rule specifier-qualifier-list {
    <specifier-qualifier>+
}

proto rule specifier-qualifier {*}
rule specifier-qualifier:sym<type-specifier> {
    <type-specifier>
}
rule specifier-qualifier:sym<type-qualifier> {
    <type-qualifier>
}

rule struct-declarator-list {
    <struct-declarator> [',' <struct-declarator>]*
}

proto rule struct-declarator {*}
rule struct-declarator:sym<declarator> {
    <declarator>
}
rule struct-declarator:sym<bit-declarator> {
    <declarator>? ':' <constant-expression>
}

# SS 6.7.2.2
proto rule enum-specifier {*}
rule enum-specifier:sym<decl> {
    { say "enum-specifier:sym<decl> 1"; }
    <enum-keyword> <ident>?
    { say "enum-specifier:sym<decl> 2"; }
    '{'
    { say "enum-specifier:sym<decl> 3"; }
    <enumerator-list> ','?
    { say "enum-specifier:sym<decl> 4"; }
    '}'
    { say "enum-specifier:sym<decl> 5"; }
}
rule enum-specifier:sym<spec> {
    <enum-keyword> <ident> <!before '{'>
}

rule enumerator-list { <enumerator> [',' <enumerator>]* }

rule enumerator {
    <enumeration-constant> ['=' <constant-expression>]?
}

# SS 6.7.2.4
proto rule atomic-type-specifier {*} # C11
rule atomic-type-specifier:sym<_Atomic> {
    { say "atomic-type-specifier:sym<_Atomic> 1"; }
    <atomic-keyword>
    { say "atomic-type-specifier:sym<_Atomic> 2"; }
    '('
    { say "atomic-type-specifier:sym<_Atomic> 3"; }
    <type-name>
    { say "atomic-type-specifier:sym<_Atomic> 4"; }
    ')'
    { say "atomic-type-specifier:sym<_Atomic> 5"; }
}

# SS 6.7.3
proto rule type-qualifier {*}
rule type-qualifier:sym<const>    { <sym> }
rule type-qualifier:sym<restrict> { <sym> }
rule type-qualifier:sym<volatile> { <sym> }
rule type-qualifier:sym<_Atomic>  { <sym> }

# SS 6.7.4
proto rule function-specifier {*}
rule function-specifier:sym<inline>    { <sym> }
rule function-specifier:sym<_Noreturn> { <sym> }

# SS 6.7.5
proto rule alignment-specifier {*}
rule alignment-specifier:sym<type-name> {
    { say "alignment-specifier:sym<type-name> 1"; }
    <alignas-keyword>
    { say "alignment-specifier:sym<type-name> 2"; }
    '(' <type-name> ')'
    { say "alignment-specifier:sym<type-name> 3"; }
}
rule alignment-specifier:sym<constant> {
    { say "alignment-specifier:sym<constant> 1"; }
    <alignas-keyword>
    { say "alignment-specifier:sym<constant> 2"; }
    '(' <constant-expression> ')'
    { say "alignment-specifier:sym<constant> 3"; }
}

# SS 6.7.6
proto rule declarator {*}

rule declarator:sym<direct> {
    <pointer>* <direct-declarator>
}

rule direct-declarator {
    #{ say "direct-declarator 1"; }
    <direct-declarator-first>
    #{ say "direct-declarator 2"; }
    <direct-declarator-rest>*
    #{ say "direct-declarator 3"; }
}

proto rule direct-declarator-first {*}

rule direct-declarator-first:sym<identifier> {
    <name=ident>
}

rule direct-declarator-first:sym<declarator> {
    '(' <declarator> ')'
}

proto rule direct-declarator-rest {*}
rule direct-declarator-rest:sym<b-assignment-expression> {
    '['
    <type-qualifier-list>?
    <assignment-expression>?
    ']'
}
rule direct-declarator-rest:sym<b-static-type-qualifier> {
    '['
    <static-keyword>
    <type-qualifier-list>?
    <assignment-expression>
    ']'
}
rule direct-declarator-rest:sym<b-type-qualifier-static> {
    '['
    <type-qualifier-list>
    <static-keyword>
    <assignment-expression>
    ']'
}
rule direct-declarator-rest:sym<b-type-qualifier-list> {
    '['
    <type-qualifier-list>? '*'
    ']'
}
rule direct-declarator-rest:sym<p-parameter-type-list> {
    #{ say "direct-declarator-rest:sym<p-parameter-type-list> 1"; }
    '('
    <parameter-type-list>
    ')'
    #{ say "direct-declarator-rest:sym<p-parameter-type-list> 2"; }
}
rule direct-declarator-rest:sym<p-identifier-list> {
    #{ say "direct-declarator-rest:sym<p-identifier-list> 1"; }
    '('
    <identifier-list>?
    ')'
    #{ say "direct-declarator-rest:sym<p-identifier-list> 2"; }
}

proto rule pointer {*}
rule pointer:sym<pointer> { '*' <type-qualifier-list>? }

rule type-qualifier-list { <type-qualifier>+ }

proto rule parameter-type-list {*}
rule parameter-type-list:sym<end> { <parameter-list> }
rule parameter-type-list:sym<...> { <parameter-list> ',' '...' }

rule parameter-list {
    <parameter-declaration> [',' <parameter-declaration>]*
}

proto rule parameter-declaration {*}
rule parameter-declaration:sym<declarator> { <declaration-specifiers> <declarator> }
rule parameter-declaration:sym<abstract> { <declaration-specifiers> <abstract-declarator>? }

rule identifier-list { <ident> [',' <ident>]* }

# SS 6.7.7
rule type-name { <specifier-qualifier-list> <abstract-declarator>? }
proto rule abstract-declarator {*}
rule abstract-declarator:sym<pointer> { <pointer> }
rule abstract-declarator:sym<direct-abstract> {
    <pointer>? <direct-abstract-declarator>
}

rule direct-abstract-declarator {
    <direct-abstract-declarator-first>?
    <direct-abstract-declarator-rest>*
}
proto rule direct-abstract-declarator-first {*}
rule direct-abstract-declarator-first:sym<abstract> {
    '('
    <abstract-declarator>
    ')'
}

proto rule direct-abstract-declarator-rest {*}
rule direct-abstract-declarator-rest:sym<b-type-qualifier> {
    '['
    <type-qualifier-list>?
    <assignment-expression>?
    ']'
}
rule direct-abstract-declarator-rest:sym<b-static-type-qualifier> {
    '['
    <static-keyword>
    <type-qualifier-list>?
    <assignment-expression>
    ']'
}
rule direct-abstract-declarator-rest:sym<b-type-qualifier-static> {
    '['
    <type-qualifier-list>
    <static-keyword>
    <assignment-expression>
    ']'
}
rule direct-abstract-declarator-rest:sym<b-*> {
    '[' '*' ']'
}
rule direct-abstract-declarator-rest:sym<p-parameter-type-list> {
    '(' <parameter-type-list>? ')'
}

# SS 6.7.8
rule typedef-name { <ident> }

# SS 6.7.9
proto rule initializer {*}
rule initializer:sym<assignment> {
    <assignment-expression>
}
rule initializer:sym<initializer-list> {
    '{'
    <initializer-list> ','?
    '}'
}

rule initializer-list {
    <designation-initializer>
    (',' <designation-initializer>)*
}

rule designation-initializer {
    <designation>? <initializer>
}

rule designation { <designator-list> '=' }
rule designator-list { <designator>+ }

proto rule designator {*}
rule designator:sym<.> { <sym> <ident> }
rule designator:sym<[ ]> {
    '[' <constant-expression> ']'
}

# SS 6.7.10
rule static-assert-declaration { # C11
    <static-assert-keyword>
    '('
    <constant-expression>
    ','
    <string-literal>
    ')'
    ';'
}

# SS 6.8
proto rule statement {*}
rule statement:sym<labeled> { <labeled-statement> }
rule statement:sym<compound> { <compound-statement> }
rule statement:sym<expression> { <expression-statement> }
rule statement:sym<selection> { <selection-statement> }
rule statement:sym<iteration> { <iteration-statement> }
rule statement:sym<jump> { <jump-statement> }

# SS 6.8.1
proto rule labeled-statement {*}
rule labeled-statement:sym<identifier> { <ident> ':' <statement> }
rule labeled-statement:sym<case> {
    <case-keyword> <constant-expression> ':' <statement>
}
rule labeled-statement:sym<default> {
    <default-keyword> ':' <statement>
}

# SS 6.8.2
rule compound-statement {
    '{'
    <block-item-list>?
    '}'
}

rule block-item-list { <block-item>+ }

proto rule block-item {*}
rule block-item:sym<declaration> { <declaration> }
rule block-item:sym<statement> { <statement> }

# SS 6.8.3
rule expression-statement { <expression>? ';' }

# SS 6.8.4
proto rule selection-statement {*}
rule selection-statement:sym<if> {
    <if-keyword>
    '('
    <expression>
    ')'
    <then_statement=statement>
    ('else' <else_statement=statement>)?
}
rule selection-statement:sym<switch> {
    <switch-keyword>
    '('
    <expression>
    ')'
    <statement>
}

# SS 6.8.5
proto rule iteration-statement {*}
rule iteration-statement:sym<while> {
    <while-keyword>
    '('
    <expression>
    ')'
    <statement>
}
rule iteration-statement:sym<do_while> {
    <do-keyword>
    <statement>
    <while-keyword>
    '('
    <expression>
    ')'
    ';'
}
rule iteration-statement:sym<for> {
    <for-keyword>
    '('
    <init=expression>? ';'
    <test=expression>? ';'
    <step=expression>?
    ')'
    <statement>
}
rule iteration-statement:sym<for_decl> { # C99
    <for-keyword>
    '('
    <init=declaration>
    <test=expression>? ';'
    <step=expression>?
    ')'
    <statement>
}

# SS 6.8.6
proto rule jump-statement {*}
rule jump-statement:sym<goto> {
    <goto-keyword> <ident> ';'
}
rule jump-statement:sym<continue> {
    <continue-keyword> ';'
}
rule jump-statement:sym<break> {
    <break-keyword> ';'
}
rule jump-statement:sym<return> {
    <return-keyword> <expression>? ';'
}

# SS 6.9
rule translation-unit {
    :my $*STATIC_CONTEXT = False;
    :my $*TYPEDEF_CONTEXT = False;
    :my %*TYPEDEFS;
    <external-declaration>+
}

proto rule external-declaration {*}
rule external-declaration:sym<function-definition> {
    { say "external-declaration:sym<function-definition> 1"; }
    <function-definition>
    { say "external-declaration:sym<function-definition> 2"; }
}
rule external-declaration:sym<declaration> {
    { say "external-declaration:sym<declaration> 1"; }
    <declaration>
    { say "external-declaration:sym<declaration> 2"; }
}
#rule external-declaration:sym<control-line> { <control-line> }

# SS 6.9.1
proto rule function-definition {*}
rule function-definition:sym<modern> {
    { say "function-definition:sym<modern> 1"; }
    <declaration-specifiers>
    { say "function-definition:sym<modern> 2"; }
    <declarator>
    { say "function-definition:sym<modern> 3"; }
    <compound-statement>
    { say "function-definition:sym<modern> 4"; }
}
rule function-definition:sym<ancient> {
    { say "function-definition:sym<ancient> 1"; }
    <declaration-specifiers>
    { say "function-definition:sym<ancient> 2"; }
    <declarator>
    { say "function-definition:sym<ancient> 3"; }
    <declaration-list>
    { say "function-definition:sym<ancient> 4"; }
    <compound-statement>
    { say "function-definition:sym<ancient> 5"; }
}

rule declaration-list { <declaration>+ }

## SS 6.10
#rule preprocessing-file { <group>? }
#rule group { <group-part>+ }
#proto rule group-part {*}
#rule group-part:sym<if-section> { <if-section> }
#rule group-part:sym<control-line> { <control-line> }
#rule group-part:sym<text-line> { <text-line> }
#rule group-part:sym<non-directive> { '#' <non-directive> }

#proto rule if-section($text) {
#    <if-group($text)>
#    <elif-groups($text)>?
#    <else-group($text)>?
#    <endif-line($text)>
#}
#proto rule if-group($text) {*}
#proto rule elif-groups($text) {*}
#proto rule elif-group($text) {*}
#proto rule else-group($text) {*}
#proto rule endif-line($text) {*}

#proto rule control-line() {*}
#
#rule text-line { <pp-tokens>? <new-line> }
#rule non-directive { <pp-tokens>? <new-line> }
#
## TODO
#token new-line { <?> }
#
#proto rule replacement-list {*}
