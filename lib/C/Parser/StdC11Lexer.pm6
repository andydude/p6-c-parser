# References ISO/IEC 9899:1990 "Information technology - Programming Language C" (C89 for short)
use v6;
#use Grammar::Tracer;
grammar C::Parser::StdC11Lexer;

token TOP {^ <c-tokens> $}

token ws {
    <.ws-char>*
}

token ws-char {
    <[\ \t\r\n]>
}

rule c-tokens {
     <c-token>+
}

rule pp-tokens {
     <pp-token>+
}

# SS 6.4
proto rule c-token {*}
rule c-token:sym<keyword> { <keyword> }
rule c-token:sym<identifier> { <ident> }
rule c-token:sym<constant> { <constant> }
rule c-token:sym<string-literal> { <string-literal> }
rule c-token:sym<punct> { <punct> }

proto rule pp-token {*}
rule pp-token:sym<header-name> { <header-name> }
rule pp-token:sym<identifier> { <ident> }
rule pp-token:sym<pp-number> { <pp-number> }
rule pp-token:sym<character-constant> { <character-constant> }
rule pp-token:sym<string-literal> { <string-literal> }
rule pp-token:sym<punct> { <punct> }
#rule pp-token:sym<none-of-above> { <!> }

# SS 6.4.1
proto token keyword {*}
token keyword:sym<auto>     { <sym> }
token keyword:sym<break>    { <sym> }
token keyword:sym<case>     { <sym> }
token keyword:sym<char>     { <sym> }
token keyword:sym<const>    { <sym> }
token keyword:sym<continue> { <sym> }
token keyword:sym<default>  { <sym> }
token keyword:sym<do>       { <sym> }
token keyword:sym<double>   { <sym> }
token keyword:sym<else>     { <sym> }
token keyword:sym<enum>     { <sym> }
token keyword:sym<extern>   { <sym> }
token keyword:sym<float>    { <sym> }
token keyword:sym<for>      { <sym> }
token keyword:sym<goto>     { <sym> }
token keyword:sym<if>       { <sym> }
token keyword:sym<inline>   { <sym> }
token keyword:sym<int>      { <sym> }
token keyword:sym<long>     { <sym> }
token keyword:sym<register> { <sym> }
token keyword:sym<restrict> { <sym> }
token keyword:sym<return>   { <sym> }
token keyword:sym<short>    { <sym> }
token keyword:sym<signed>   { <sym> }
token keyword:sym<sizeof>   { <sym> }
token keyword:sym<static>   { <sym> }
token keyword:sym<struct>   { <sym> }
token keyword:sym<switch>   { <sym> }
token keyword:sym<typedef>  { <sym> }
token keyword:sym<union>    { <sym> }
token keyword:sym<unsigned> { <sym> }
token keyword:sym<void>     { <sym> }
token keyword:sym<volatile> { <sym> }
token keyword:sym<while>    { <sym> }
token keyword:sym<_Alignas> { <sym> || 'alignas' } # C11
token keyword:sym<_Alignof> { <sym> || 'alignof' } # C11
token keyword:sym<_Atomic>  { <sym> || 'atomic' }  # C11
token keyword:sym<_Bool>    { <sym> || 'bool' }    # C99
token keyword:sym<_Complex>	{ <sym> || 'complex' } # C99
token keyword:sym<_Generic> { <sym> || 'generic' } # C11
token keyword:sym<_Imaginary>     { <sym> || 'imaginary' }     # C99
token keyword:sym<_Noreturn>      { <sym> || 'noreturn' }      # C11
token keyword:sym<_Static_assert> { <sym> || 'static_assert' } # C11
token keyword:sym<_Thread_local>  { <sym> || 'thread_local' }  # C11

token auto-keyword     { 'auto' }
token break-keyword    { 'break' }
token case-keyword     { 'case' }
token char-keyword     { 'char' }
token const-keyword    { 'const' }
token continue-keyword { 'continue' }
token default-keyword  { 'default' }
token do-keyword       { 'do' }
token double-keyword   { 'double' }
token else-keyword     { 'else' }
token enum-keyword     { 'enum' }
token extern-keyword   { 'extern' }
token float-keyword    { 'float' }
token for-keyword      { 'for' }
token goto-keyword     { 'goto' }
token if-keyword       { 'if' }
token inline-keyword   { 'inline' }
token int-keyword      { 'int' }
token long-keyword     { 'long' }
token register-keyword { 'register' }
token restrict-keyword { 'restrict' }
token return-keyword   { 'return' }
token short-keyword    { 'short' }
token signed-keyword   { 'signed' }
token sizeof-keyword   { 'sizeof' }
token static-keyword   { 'static' }
token struct-keyword   { 'struct' }
token switch-keyword   { 'switch' }
token typedef-keyword  { 'typedef' }
token union-keyword    { 'union' }
token unsigned-keyword { 'unsigned' }
token void-keyword     { 'void' }
token volatile-keyword { 'volatile' }
token while-keyword    { 'while' }

token alignas-keyword 		{ '_Alignas' }
token alignof-keyword 		{ '_Alignof' }
token atomic-keyword 		{ '_Atomic' }
token bool-keyword 			{ '_Bool' }
token complex-keyword 		{ '_Complex' }
token generic-keyword 		{ '_Generic' }
token imaginary-keyword 	{ '_Imaginary' }
token noreturn-keyword 		{ '_Noreturn' }
token static-assert-keyword { '_Static_assert' }
token thread-local-keyword  { '_Thread_local' }

# SS 6.4.2.1

# Standard name: identifier
# Nonstandard name: ident
# Rationale: 'ident' is more Perl-ish
token ident { 
	$<name>=(<.ident-first> <.ident-rest>*)
}

# identifier-nondigit
proto token ident-first {*}
token ident-first:sym<under> { '_' }
token ident-first:sym<alpha> { <.alpha> }
#token ident-first:sym<unichar> { <.universal-character-name> }

# identifier-nondigit | digit
proto token ident-rest {*}
token ident-rest:sym<alpha> { <.ident-first> }
token ident-rest:sym<digit> { <.digit> }

## digit is built-in in Perl6
##token digit { <[0..9]> }
##token alpha { <[a..zA..Z]> }

# SS 6.4.3
proto token universal-character-name {*}
token universal-character-name:sym<u> { '\\u' <xdigit> ** 4 }
token universal-character-name:sym<U> { '\\U' <xdigit> ** 8 }

proto token constant {*}
token constant:sym<integer> {
    <integer-constant>
    <!before [.eE]>
}
token constant:sym<floating> {
    <floating-constant>
}
token constant:sym<enumeration> {
    <enumeration-constant>
}
token constant:sym<character> {
    <character-constant>
}

# SS 6.4.4.1
token integer-constant { <integer-value> <integer-suffix>* }

# Nonstandard: integer-value does not exist in C89 grammar
# Rationale: <integer-suffix> appears on the RHS of every
# rule in the C89 grammar, so we factor it out here.
proto token integer-value {*}
token integer-value:sym<8>  { <octal-constant> }
token integer-value:sym<10> { <decimal-constant> }
token integer-value:sym<16> { <hexadecimal-constant> }

token octal-constant { '0' <odigit>* }
token decimal-constant { <nzdigit> <digit>* }
token hexadecimal-constant { <.hexadecimal-prefix> <xdigit>* }
token hexadecimal-prefix { '0' <[xX]> }

token nzdigit { <[1..9]> }
token odigit { <[0..7]> }

proto token integer-suffix {*}
token integer-suffix:sym<L> { <[lL]> }
token integer-suffix:sym<LL> { < ll LL > }
token integer-suffix:sym<U> { <[uU]> }

# SS 6.4.4.2
proto token floating-constant {*}
token floating-constant:radix<10> { <decimal-floating-constant> }
token floating-constant:radix<16> { <hexadecimal-floating-constant> }

proto token decimal-floating-constant {*}
token decimal-floating-constant:sym<9.9> { 
      <fractional-constant> <exponent-part>? <floating-suffix>?
}
token decimal-floating-constant:sym<9e9> {
      <digit-sequence> <exponent-part> <floating-suffix>?
}

proto token hexadecimal-floating-constant {*}
token hexadecimal-floating-constant:sym<F.F> { 
      <hexadecimal-prefix> 
      <hexadecimal-fractional-constant> 
      <binary-exponent-part> 
      <floating-suffix>?
}
token hexadecimal-floating-constant:sym<FpF> {  
      <hexadecimal-prefix> 
      <hexadecimal-digit-sequence>
      <binary-exponent-part> 
      <floating-suffix>?
}

proto token fractional-constant {*}
token fractional-constant:sym<9.9> {
      <digit-sequence>? '.' <digit-sequence>
}
token fractional-constant:sym<9.> {
      <digit-sequence> '.' 
}

token exponent-part { <[eE]> <sign>? <digit-sequence> }

token sign { <[+-]> }

token digit-sequence { <.digit>+ }

proto token hexadecimal-fractional-constant {*}
token hexadecimal-fractional-constant:sym<F.F> {
      <hexadecimal-digit-sequence>? '.' <hexadecimal-digit-sequence>
}
token hexadecimal-fractional-constant:sym<F.> {
      <hexadecimal-digit-sequence> '.'
}

token binary-exponent-part { <[pP]> <sign>? <digit-sequence> }

token hexadecimal-digit-sequence { <.xdigit>+ }

proto token floating-suffix {*}
token floating-suffix:sym<F> { <[fF]> }
token floating-suffix:sym<L> { <[lL]> }

# SS 6.4.4.3
token enumeration-constant { <ident> }

# SS 6.4.4.4
proto token character-constant {*}
token character-constant:sym<quote> { "'" <c-char-sequence>? "'" }
token character-constant:sym<L> { <sym> "'" <c-char-sequence>? "'" } # C99 wchar_t
token character-constant:sym<u> { <sym> "'" <c-char-sequence>? "'" } # C11 char16_t
token character-constant:sym<U> { <sym> "'" <c-char-sequence>? "'" } # C11 char32_t

token c-char-sequence { <c-char>+ }

proto token c-char {*}
token c-char:sym<any> { <-[\'\\\n]> }
token c-char:sym<escape> { <escape-sequence> }

proto token escape-sequence {*}
token escape-sequence:sym<simple> { <simple-escape-sequence> }
token escape-sequence:sym<octal> { <octal-escape-sequence> }
token escape-sequence:sym<hexadecimal> { <hexadecimal-escape-sequence> }
token escape-sequence:sym<universal> { <.universal-character-name> }

proto token simple-escape-sequence {*}
token simple-escape-sequence:sym<\\> { '\\' '\\' }
token simple-escape-sequence:sym<'> { '\\' <sym> }
token simple-escape-sequence:sym<"> { '\\' <sym> }
token simple-escape-sequence:sym<?> { '\\' <sym> }
token simple-escape-sequence:sym<a> { '\\' <sym> }
token simple-escape-sequence:sym<b> { '\\' <sym> }
token simple-escape-sequence:sym<f> { '\\' <sym> }
token simple-escape-sequence:sym<n> { '\\' <sym> }
token simple-escape-sequence:sym<r> { '\\' <sym> }
token simple-escape-sequence:sym<t> { '\\' <sym> }
token simple-escape-sequence:sym<v> { '\\' <sym> }

token octal-escape-sequence { '\\' <odigit> ** 1..3 }
token hexadecimal-escape-sequence { '\\x' <xdigit>+ }

# SS 6.4.5
proto token string-literal {*}
token string-literal:sym<quote> { '"' <s-char-sequence>? '"' }
token string-literal:sym<L>  { <sym> '"' <s-char-sequence>? '"' } # C99 wchar_t *
token string-literal:sym<u8> { <sym> '"' <s-char-sequence>? '"' } # C11 UTF-8
token string-literal:sym<u>  { <sym> '"' <s-char-sequence>? '"' } # C11 UTF-16 char16_t *
token string-literal:sym<U>  { <sym> '"' <s-char-sequence>? '"' } # C11 UTF-32 char32_t *

token s-char-sequence { <s-char>+ }

proto token s-char {*}
token s-char:sym<any> { <-[\"\\\n]> }
token s-char:sym<escape> { <escape-sequence> }

# punctuator
proto token punct {*}
token punct:sym<pp(> { '(' } # TODO: check for <ws>
token punct:sym<(>   { <sym> }
token punct:sym<)>   { <sym> }
token punct:sym<[>   { <sym> | '<:' }
token punct:sym<]>   { <sym> | ':>' }
token punct:sym<{>   { <sym> | '<%' }
token punct:sym<}>   { <sym> | '%>' }
token punct:sym<.>   { <sym> }
token punct:sym«->»  { <sym> }
token punct:sym<++>  { <sym> }
token punct:sym<-->  { <sym> }
token punct:sym<&>   { <sym> }
token punct:sym<*>   { <sym> }
token punct:sym<+>   { <sym> }
token punct:sym<->   { <sym> }
token punct:sym<~>   { <sym> }
token punct:sym<!>   { <sym> }
token punct:sym</>   { <sym> }
token punct:sym<%>   { <sym> }
token punct:sym«<<»  { <sym> }
token punct:sym«>>»  { <sym> }
token punct:sym«<»   { <sym> }
token punct:sym«>»   { <sym> }
token punct:sym«<=»  { <sym> }
token punct:sym«>=»  { <sym> }
token punct:sym<==>  { <sym> }
token punct:sym<!=>  { <sym> }
token punct:sym<^>   { <sym> }
token punct:sym<|>   { <sym> }
token punct:sym<&&>  { <sym> }
token punct:sym<||>  { <sym> }
token punct:sym<?>   { <sym> }
token punct:sym<:>   { <sym> }
token punct:sym<;>   { <sym> }
token punct:sym<...> { <sym> }
token punct:sym<=>   { <sym> }
token punct:sym<*=>  { <sym> }
token punct:sym</=>  { <sym> }
token punct:sym<%=>  { <sym> }
token punct:sym<+=>  { <sym> }
token punct:sym<-=>  { <sym> }
token punct:sym«<<=» { <sym> }
token punct:sym«>>=» { <sym> }
token punct:sym<&=>  { <sym> }
token punct:sym<^=>  { <sym> }
token punct:sym<|=>  { <sym> }
token punct:sym<,>   { <sym> }
token punct:sym<#>   { <sym> | '%:' }
token punct:sym<##>  { <sym> | '%:%:' }

## SS 6.4.7
##proto token header-name {*}
##token header-name:sym<angle> { <.punct:sym«<»> <h-char-sequence> <.punct:sym«>»> }
##token header-name:sym<quote> { <.punct:sym<">> <q-char-sequence> <.punct:sym<">> }
##
##proto token h-char-sequence {*}
##token h-char { <-[\n\>]> }
##proto token q-char-sequence {*}
##token q-char { <-[\n\"]> }
##
##token pp-number {
##      <.pp-number-first>
##      <.pp-number-rest>*
##}
##
##proto token pp-number-first {*}
##token pp-number-first:sym<9> { <digit> }
##token pp-number-first:sym<.9> { '.' <digit> }
##
##proto token pp-number-rest {*}
##token pp-number-rest:sym<9> { <digit> }
##token pp-number-rest:sym<A> { <ident-first> }
##token pp-number-rest:sym<E> { <[eE]> <sign> }
##token pp-number-rest:sym<P> { <[pP]> <sign> }
##token pp-number-rest:sym<,> { '.' }

