use v6;
use CAST::Constant;
class CAST::StrVal
    does CAST::Constant;
has Str $.value;
has Str $.kind;
