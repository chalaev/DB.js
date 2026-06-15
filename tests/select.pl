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

#####################

my $textarea=tagObj('/html/body/article[2]/textarea'); $textarea->property('value') eq "customer-domain.com domain.net" || die "1 error: unexpected textarea value";

my $tableBody=tagObj('/html/body/article[3]/table/tbody');

my $tabRow1=$tableBody->find('tr[1]');
my $col11=$tabRow1->find('td[1]/input'); $col11->property('value') eq ""                     || die "2 error: unexpected col11 value";
my $col12=$tabRow1->find('td[2]/select');$col12->property('value') eq "customer-domain.com"  || die "3 error: unexpected col12 value";
my $col13=$tabRow1->find('td[3]/input'); $col13->property('checked') == 1                    || die "4 error: unexpected col13 value";


my $tabRow2=$tableBody->find('tr[2]');
my $col21=$tabRow2->find('td[1]/input'); $col21->property('value') eq "another"     || die "5 error: unexpected col21 value";
my $col22=$tabRow2->find('td[2]/select');$col22->property('value') eq "domain.net"  || die "6 error: unexpected col22 value";
my $col23=$tabRow2->find('td[3]/input'); $col23->property('checked') == 1           || die "7 error: unexpected col23 value";

my $tabRow3=$tableBody->find('tr[3]');
my $col31=$tabRow3->find('td[1]/input'); $col31->property('value') eq ""                    || die  "8 error: unexpected col31 value";
my $col32=$tabRow3->find('td[2]/select');$col32->property('value') eq "customer-domain.com" || die  "9 error: unexpected col32 value";
my $col33=$tabRow3->find('td[3]/input'); $col33->property('checked')==0                     ||  die "10 error: unexpected col33 value";

$col31->type('xyz'); $col33->click();

$tabRow3=$tableBody->find('tr[3]');
$col31=$tabRow3->find('td[1]/input'); $col31->property('value') eq "xyz"                 || die "11 error: unexpected col31 value";
$col32=$tabRow3->find('td[2]/select');$col32->property('value') eq "customer-domain.com" || die "12 error: unexpected col32 value";
$col33=$tabRow3->find('td[3]/input'); $col33->property('checked')==1                     || die "13 error: unexpected col33 value";

my $tabRow4=$tableBody->find('tr[4]');
my $col41=$tabRow4->find('td[1]/input'); $col41->property('value') eq ""                    || die "14 error: unexpected col41 value";
my $col42=$tabRow4->find('td[2]/select');$col42->property('value') eq "customer-domain.com" || die "15 error: unexpected col42 value";
my $col43=$tabRow4->find('td[3]/input'); $col43->property('checked')==0                     || die "16 error: unexpected col43 value";

my @expected = ("chalaev.com","customer-domain.com","domain.net");
my @actual  = allChildren('/html/body/article[3]/table/tbody/tr[1]/td[2]/select','option');
arrays_equal(\@actual, \@expected) || die "test O1 failed!";

$textarea->type(" qwerty.us");
tagObj('/html/body/h1')->click();

@expected = ("chalaev.com","customer-domain.com","domain.net","qwerty.us");
@actual  = allChildren('/html/body/article[3]/table/tbody/tr[1]/td[2]/select','option');
arrays_equal(\@actual, \@expected) || die "test O2 failed!";

$tabRow1=$tableBody->find('tr[1]');
$col11=$tabRow1->find('td[1]/input'); $col11->property('value') eq ""                     || die "17 error: unexpected col11 value";
$col12=$tabRow1->find('td[2]/select');$col12->property('value') eq "customer-domain.com"  || die "18 error: unexpected col12 value";
$col13=$tabRow1->find('td[3]/input'); $col13->property('checked') == 1                    || die "19 error: unexpected col13 value";

$tabRow2=$tableBody->find('tr[2]');
$col21=$tabRow2->find('td[1]/input'); $col21->property('value') eq "another"     || die "20 error: unexpected col21 value";
$col22=$tabRow2->find('td[2]/select');$col22->property('value') eq "domain.net"  || die "21 error: unexpected col22 value";
$col23=$tabRow2->find('td[3]/input'); $col23->property('checked') == 1           || die "22 error: unexpected col23 value";

$tabRow3=$tableBody->find('tr[3]');
$col31=$tabRow3->find('td[1]/input'); $col31->property('value') eq "xyz"                 || die "23 error: unexpected col31 value";
$col32=$tabRow3->find('td[2]/select');$col32->property('value') eq "customer-domain.com" || die "24 error: unexpected col32 value";
$col33=$tabRow3->find('td[3]/input'); $col33->property('checked')==1                     || die "25 error: unexpected col33 value";

$tabRow4=$tableBody->find('tr[4]');
$col41=$tabRow4->find('td[1]/input'); $col41->property('value') eq ""                    || die "26 error: unexpected col41 value";
$col42=$tabRow4->find('td[2]/select');$col42->property('value') eq "customer-domain.com" || die "27 error: unexpected col42 value";
$col43=$tabRow4->find('td[3]/input'); $col43->property('checked')==0                     || die "28 error: unexpected col43 value";
