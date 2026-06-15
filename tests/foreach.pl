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

my $webPage='foreach';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

sub tagObj{
my $xpath=shift(@_);
return $firefox->await(sub {$firefox->find($xpath)})}

sub manySymbols{
my $xpath=shift(@_);
my $tag=shift(@_);
my @symbols=();
foreach my $symbol (tagObj($xpath)->find_tag($tag)){
push(@symbols,$symbol->text)}
return join('',@symbols)}

my $symbolsPath='/html/body/div/p[2]';
my $lettersPath='/html/body/div/p[5]';

manySymbols($symbolsPath,'span') eq "01234" || die "test 1 failed!";
manySymbols($lettersPath,'span') eq "abcde" || die "test 2 failed!";

# make sure that push method works for observable arrays:
manySymbols('/html/body/div/p[8]','span') eq "012349" || die "test 3 failed!";

# forEach must work also for non observables -- checking rows of the first table:
manySymbols('/html/body/div/table[1]/tbody/tr[1]','td') eq "012345" || die "test N1 failed!";
manySymbols('/html/body/div/table[1]/tbody/tr[2]','td') eq "67891011" || die "test N2 failed!";
manySymbols('/html/body/div/table[1]/tbody/tr[3]','td') eq "121314151617" || die "test N3 failed!";

# forEach must work observables -- checking rows of the second table:
manySymbols('/html/body/div/table[2]/tbody/tr[1]','td') eq "012345" || die "test O1 failed!";
manySymbols('/html/body/div/table[2]/tbody/tr[2]','td') eq "67891011" || die "test O2 failed!";
manySymbols('/html/body/div/table[2]/tbody/tr[3]','td') eq "121314151617" || die "test O3 failed!";

# clicking an element in the second (observable) table fills the second column of the (third) table identifying the place where we clicked:
# clicking "1":
$firefox->find('/html/body/div/table[2]/tbody/tr[1]/td[2]')->click();
print("mouseX= " . $firefox->find_id('mouseX')->text . "\n");
print("mouseY= " . $firefox->find_id('mouseY')->text . "\n");
$firefox->find_id('tabRow')->text    eq "row0" || die "test R1 failed!";
$firefox->find_id('colNumber')->text eq    "1" || die "test C1 failed!";

# clicking "8":
$firefox->find('/html/body/div/table[2]/tbody/tr[2]/td[3]')->click();
$firefox->find_id('tabRow')->text    eq "row1" || die "test R2 failed!";
$firefox->find_id('colNumber')->text eq    "2" || die "test C2 failed!";

# clicking "15":
$firefox->find('/html/body/div/table[2]/tbody/tr[3]/td[4]')->click();
$firefox->find_id('tabRow')->text    eq "row2" || die "test R3 failed!";
$firefox->find_id('colNumber')->text eq    "3" || die "test C3 failed!";

# Observable arrays dynamically changing their size:

    
# /html/body/div/table[1]/tbody/tr[1]/td[1]

# tagObj($redSpanPath)->has_class('red') && die "test 1 failed!";
# $firefox->percentage_visible(tagObj($tablePath))>0 || die "test 2 failed!";

# tagObj('/html/body/div/p[2]/button')->click();
# tagObj($redSpanPath)->has_class('red') || die "test 3 failed!";

# tagObj('/html/body/p/button')->click();
# $firefox->percentage_visible(tagObj($tablePath))==0 || die "test 4 failed!";
