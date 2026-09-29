use v5.10;
use strict;
use warnings;
use Exporter;

use English qw( -no_match_vars );
use Tk;
use Firefox::Marionette();
use Firefox::Marionette::Profile();
use Firefox::Marionette::Capabilities();
use Firefox::Marionette::Display();
use Firefox::Marionette::Keys qw(:all);
use Time::HiRes qw(usleep);

my $firefox = Firefox::Marionette->new(sleep_time_in_ms => 100);

my $webPage='select';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

sub tagObj{
my $xpath=shift(@_);
my $parent=shift(@_) || $firefox;
return $firefox->await(sub {$parent->find($xpath)})}

sub arrays_equal {
    my ($a, $b) = @_;
    return 0 unless @$a eq @$b;
    for my $i (0 .. $#$a){
        return 0 unless $a->[$i] eq $b->[$i]}
    return 1}
# ← tested in sort.pl

sub allChildren{
my ($xpath, $tag) = @_;
my @children=();
my $tobj=tagObj($xpath);
foreach my $symbol ($tobj->find_tag($tag)){
push(@children,$symbol->text)}
return @children}
# ← tested in sort.pl

sub ctrlA{
$firefox->perform($firefox->key_down(CONTROL()), $firefox->key_down("a"), $firefox->key_up("l"), $firefox->key_up(CONTROL()));
}

my $selectPath='/html/body/article[1]/select';

my $textarea=tagObj('/html/body/article[1]/textarea'); $textarea->property('value') eq "1-temp 4-temp 6-temp 9-temp" || die "1 error: unexpected textarea value";
my $select=tagObj($selectPath); $select->property('value') eq "3-perm" || die "2 error: unexpected select value";

my @expectedOptions = ("1-temp","3-perm","4-temp","6-temp","7-perm","9-temp");
my @actualOptions  = allChildren($selectPath,'option');
arrays_equal(\@actualOptions, \@expectedOptions) || die "test O1 failed!";

$textarea->type(" 999"); tagObj('/html/body/h1')->click();

@expectedOptions = ("1-temp","3-perm","4-temp","6-temp","7-perm","9-temp","999");
@actualOptions  = allChildren($selectPath,'option');
arrays_equal(\@actualOptions, \@expectedOptions) || die "test O2 failed!";

# make sure that the selected value remained the same:
$select->property('value') eq "3-perm" || die "3 error: unexpected select value";
$textarea->type("x"); ctrlA(); $textarea->type("1-temp 4444 6-temp 88"); tagObj('/html/body/h1')->click();

# note the deviations in ordering →
@expectedOptions = ("1-temp","3-perm","6-temp","4444","7-perm","88");
@actualOptions  = allChildren($selectPath,'option');
arrays_equal(\@actualOptions, \@expectedOptions) || die "test O3 failed!";

# selecting another value:
foreach my $option ($select->find_tag('option')) {
    if ($option->property('text') eq '4444') { $option->click(); } }
$select->property('value') eq "4444" || die "4 error: unexpected select value";

$textarea->type("x"); ctrlA(); $textarea->type("1-temp 4-temp 6-temp 9-temp 4444"); tagObj('/html/body/h1')->click();
@expectedOptions = ("1-temp","3-perm","6-temp","4444","4-temp","7-perm","9-temp");
@actualOptions  = allChildren($selectPath,'option');
arrays_equal(\@actualOptions, \@expectedOptions) || die "test O4 failed!";

$select->property('value') eq "4444" || die "5 error: unexpected select value";
