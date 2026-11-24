#!/bin/sh
# Check the format of the DOS source files: CRLF line endings, code page
# 437, no tabs or trailing whitespace, and the three-column layout.
#
# usage: tools/lint.sh [file...]
#
# Without arguments every DOS text file is checked (src/*.ASM, inc/*,
# MAKE.BAT, THETRIS.LNK), and so is the module registration in MAKE.BAT and
# THETRIS.LNK. With arguments only the named files are checked. Findings are
# printed as file:line: message. Exits 1 when there are findings.

cd "$(dirname "$0")/.." || exit 2

LC_ALL=C exec perl -e '
use strict; use warnings;

my $full = !@ARGV;
my @files = $full ? (glob("src/*"), glob("inc/*"), "MAKE.BAT", "THETRIS.LNK") : @ARGV;
my $n = 0;
sub finding { print "$_[0]\n"; $n++ }

for my $f (@files) {
    next unless -f $f;
    my ($base) = $f =~ m{([^/]+)$};
    my $in_tree = $f =~ m{(^|/)(src|inc)/[^/]+$};
    my $is_asm  = $f =~ m{(^|/)src/[^/]+\.ASM$} || $base eq "COMMON.INC";
    my $is_generated = $base =~ /\.PAL$/;    # written by a palette tool, tabs and all

    finding("$f: file name is not an upper case 8.3 name")
        if $in_tree && $base !~ /^[A-Z0-9_]{1,8}\.[A-Z0-9]{1,3}$/;

    open(my $fh, "<:raw", $f) or do { finding("$f: cannot read"); next };
    my $data = do { local $/; <$fh> };
    close $fh;

    # CP437 text holding a letter above 7Fh is never valid UTF-8, so a file
    # that has high bytes and still decodes as UTF-8 was converted.
    if ($data =~ /[\x80-\xff]/) {
        my $copy = $data;
        finding("$f: encoded as UTF-8, must be CP437")
            if utf8::decode($copy);
    }
    finding("$f: last line has no CRLF") if length($data) && $data !~ /\r\n\z/;

    my @lines = split /\n/, $data, -1;
    pop @lines if @lines && $lines[-1] eq "";
    for my $i (0 .. $#lines) {
        my $l = $lines[$i];
        my $at = "$f:" . ($i + 1);
        finding("$at: line does not end in CRLF") unless $l =~ s/\r\z//;
        finding("$at: stray CR inside the line") if $l =~ /\r/;
        finding("$at: tab character") if $l =~ /\t/ && !$is_generated;
        finding("$at: trailing whitespace") if $l =~ /[ \t]\z/;

        next unless $is_asm;
        next if $l =~ /^\s*$/ || $l =~ /^;/;
        if ($l =~ /^ /) {
            if ($l !~ /^ {16}\S/) {
                finding("$at: statement does not start in column 17");
                next;
            }
            finding("$at: upper case mnemonic or directive") if $l =~ /^ {16}[A-Z]/;
            finding("$at: operand does not start in column 25")
                if $l =~ /^ {16}[^\s;]{1,7} +[^\s;]/ && $l !~ /^ {16}[^\s;]{1,7} {1,7}(?<=^.{24})\S/;
        } elsif ($l =~ /^(\S+) +[^\s;]/) {
            finding("$at: statement after the label does not start in column 17")
                if length($1) < 16 && $l !~ /^\S+ +(?<=^.{16})\S/;
        }
    }

    if ($f =~ m{(^|/)src/[^/]+\.ASM$}) {
        finding("$f:1: module does not open with a banner line")
            unless @lines && $lines[0] =~ /^;-{20,}\r?$/;
        finding("$f:2: banner does not name the module as \"; $base - ...\"")
            unless @lines > 1 && $lines[1] =~ /^; \Q$base\E - \S/;
    }
}

if ($full) {
    my %slurp;
    for my $f ("MAKE.BAT", "THETRIS.LNK") {
        open(my $fh, "<:raw", $f) or do { finding("$f: cannot read"); next };
        $slurp{$f} = lc do { local $/; <$fh> };
    }
    my $make = $slurp{"MAKE.BAT"} // "";
    my $link = $slurp{"THETRIS.LNK"} // "";
    my %built; $built{$_} = 1 for map { split " " } $make =~ /in \(([^)]*)\)/g;
    my %linked; $linked{$_} = 1 for $link =~ /obj\\([a-z0-9_]+)/g;
    my %have;
    for my $f (glob("src/*.ASM")) {
        my ($m) = $f =~ m{([^/]+)\.ASM$};
        $have{lc $m} = 1;
    }
    for my $m (sort keys %have) {
        finding("MAKE.BAT: module $m is not assembled") unless $built{$m};
        finding("THETRIS.LNK: module $m is not linked") unless $linked{$m};
    }
    for my $m (sort keys %built) {
        finding("MAKE.BAT: assembles $m, which is not in src/") unless $have{$m};
    }
    for my $m (sort keys %linked) {
        finding("THETRIS.LNK: links $m, which is not in src/") unless $have{$m};
    }
    for my $g ($link =~ /gfx\\([a-z0-9_]+)/g) {
        finding("THETRIS.LNK: links gfx\\$g, which is not in gfx/") unless -f "gfx/" . uc($g) . ".OBJ";
    }
}

print "lint: $n finding(s)\n" if $n;
exit($n ? 1 : 0);
' -- "$@"
