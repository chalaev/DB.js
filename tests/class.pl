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

my $webPage='class';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

sub tagObj{
my $xpath=shift(@_);
return $firefox->await(sub {$firefox->find($xpath)})}

my $redSpanPath='/html/body/div/p[1]';
my $tablePath='/html/body/table';

tagObj($redSpanPath)->has_class('red') && die "test 1 failed!";
$firefox->percentage_visible(tagObj($tablePath))>0 || die "test 2 failed!";

tagObj('/html/body/div/p[2]/button')->click();
tagObj($redSpanPath)->has_class('red') || die "test 3 failed!";

tagObj('/html/body/p/button')->click();
$firefox->percentage_visible(tagObj($tablePath))==0 || die "test 4 failed!";
