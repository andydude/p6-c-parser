use v6;
use CAST::Constant;
class CAST::CVal does CAST::Constant {
    has Str $.value;
    has Str $.kind;
}