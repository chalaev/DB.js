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

my $webPage='simple-select';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

sub tagObj{
my $xpath=shift(@_);
return $firefox->await(sub {$firefox->find($xpath)})}

my $selectTag=tagObj('/html/body/article/p[1]/select');

$selectTag->property('value') eq 'coffee' || die "test 1 failed";
tagObj('/html/body/article/p[2]/input')->property('value') eq 'lemonade' || die "test 2 failed";
tagObj('/html/body/article/p[2]/button')->click();
$selectTag->property('value') eq 'coffee' || die "test 3 failed";

foreach my $option ($selectTag->find_tag('option')){
    if ($option->property('value') eq 'water') {
        $option->click()}}

$selectTag->property('value') eq 'water' || die "test 4 failed";
