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

my $firefox = Firefox::Marionette->new(sleep_time_in_ms => 100); # ,visible => 1

my $webPage='sort';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

sub tagObj{
my $xpath=shift(@_);
return $firefox->await(sub {$firefox->find($xpath)})}

sub allChildren{
my ($xpath, $tag) = @_;
my @children=();
my $tobj=tagObj($xpath);
foreach my $symbol ($tobj->find_tag($tag)){
push(@children,$symbol->text)}
return @children}

sub arrays_equal {
    my ($a, $b) = @_;
    return 0 unless @$a == @$b;
    for my $i (0 .. $#$a){
        return 0 unless $a->[$i] eq $b->[$i]}
    return 1}

my @a1=(1,2,3);
my @a2=(1,2,3);
my @a3=(0,1,2,3);
my @a4=(1,0,3);
my @a5=('1','2','3');
my @a6=('1','4','3');
arrays_equal(\@a1,\@a2) || die "test AE1 failed!";
arrays_equal(\@a3,\@a2) && die "test AE2 failed!";
arrays_equal(\@a2,\@a3) && die "test AE3 failed!";
arrays_equal(\@a2,\@a4) && die "test AE4 failed!";
arrays_equal(\@a1,\@a5) || die "test AE5 failed!";
arrays_equal(\@a1,\@a6) && die "test AE6 failed!";

my @symbols = allChildren('/html/body/p[3]','span');
my @expected = (-300,-100,0,200,400);
arrays_equal(\@symbols, \@expected) || die "test A1 failed!";

my $newMember=tagObj('/html/body/p[4]/span')->text;
$firefox->find('/html/body/p[4]')->click();
push(@expected, $newMember);

@expected = sort {$a <=> $b} @expected;
@symbols = allChildren('/html/body/p[3]','span');
arrays_equal(\@symbols, \@expected) || die "test A2 failed!";

# replacing array with random entries:
$firefox->find('/html/body/button[1]')->click();
@expected = allChildren('/html/body/p[3]','span');
$newMember=tagObj('/html/body/p[4]/span')->text;
$firefox->find('/html/body/p[4]')->click();
push(@expected, $newMember);
@expected = sort {$a <=> $b} @expected;
@symbols  = allChildren('/html/body/p[3]','span');
arrays_equal(\@symbols, \@expected) || die "test A3 failed!";

# switching the sorting method
$firefox->find('/html/body/button[2]')->click();
@expected = sort {abs($a) <=> abs($b)} @expected;
@symbols  = allChildren('/html/body/p[3]','span');
arrays_equal(\@symbols, \@expected) || die "test A4 failed!";

############ sorting domain zones
my @zoneNames=();
my @zonePrices=();
my $dzBlock=tagObj('/html/body/div[2]');

foreach my $zoneBlock ($dzBlock->find_tag('div')){
    my $zoneName=$zoneBlock->find_tag('span')->text;
    push(@zoneNames, $zoneName);
    my $zonePrice=$zoneBlock->find('span[2]')->text;
    print("($zoneName,$zonePrice) ");
    push(@zonePrices, substr($zonePrice, 1))}

print("\n");
my @sortedZoneNames = sort {$a cmp $b} @zoneNames;
arrays_equal(\@sortedZoneNames, \@zoneNames) || die "test Z1 failed!";

# switching the sorting method
print("1 sort method= " . $firefox->find_id('sortBy')->property('value') . "\n");

my $sortSwitcher = $firefox->find_id('sortBy');
foreach my $option ($sortSwitcher->find_tag('option')){
    if ($option->property('value') eq 'sortByPrice') {
        $option->click()}}

print("2 sort method= " . $firefox->find_id('sortBy')->property('value') . "\n");

@zoneNames=();
@zonePrices=();
foreach my $zoneBlock ($dzBlock->find_tag('div')){
    my $zoneName=$zoneBlock->find_tag('span')->text;
    push(@zoneNames, $zoneName);
    my $zonePrice=$zoneBlock->find('span[2]')->text;
    print("($zoneName,$zonePrice) ");
    push(@zonePrices, 0+substr($zonePrice, 1))}

print("\n");
my @sortedZonePrices = sort {  $a <=> $b} @zonePrices;
arrays_equal(\@sortedZonePrices, \@zonePrices) || die "test Z2 failed!";
