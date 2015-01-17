use v6;
module C::Parser::Utils;

our sub fake_indent (Str $input --> Str) {
    my regex three_liner {
        $<line>=['('   <-[()\n]>*]
        <.ws> $<line>=[<-[()\n]>*]
        <.ws> $<line>=[<-[()\n]>* ')']
    };

    my sub one_liner($/) {
        return @<line>.join;
    }

    my $out = $input;
    $out.=subst("(", "(\n", :g);
    $out.=subst(")", "\n)", :g);
    $out.=subst(rx{',' <.ws>}, ",\n", :g);
    $out.=subst("\n\n", "\n", :g);
    $out.=subst("(\n)", "()", :g);
    $out.=subst(&three_liner, &one_liner, :g);
    our $count = 0;
    our @inlines = $out.lines;
    our @outlines = @();
    for @inlines -> $line {
        if $line ~~ rx{^ ')'} {
            $count -= $line.split(")").elems - 1;
            @outlines.push($line.indent(4*$count));
        }
        else {
            @outlines.push($line.indent(4*$count));
            $count -= $line.split(")").elems - 1;
        }
        $count += $line.split("(").elems - 1;
    }
    $out = @outlines.join("\n");
    return $out;
}
