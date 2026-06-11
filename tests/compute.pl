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

my $webPage='compute';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

sub tagObj{
my $xpath=shift(@_);
return $firefox->await(sub {$firefox->find($xpath)})}

sub ctrlA{
$firefox->perform($firefox->key_down(CONTROL()), $firefox->key_down("a"), $firefox->key_up("l"), $firefox->key_up(CONTROL()));
}

#################
my $unoPath='/html/body/div/label/input';
my $duePath='/html/body/div/p/span';

tagObj($unoPath)->property('value') eq 'ku-ku' or die "test 1 failed!";

tagObj($duePath)->text eq 'zzz' or die "test 2 failed!";

$firefox->find($unoPath)->click();
ctrlA();
tagObj($unoPath)->type('boom');
$firefox->find($duePath)->click();

tagObj($duePath)->text eq 'boom boom' or die "test 3 failed!";
