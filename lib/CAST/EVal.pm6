use v6;
use CAST::Constant;
class CAST::EVal does CAST::Constant {
    has Str $.value;
    has Str $.ident;
}