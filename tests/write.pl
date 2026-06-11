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

my $webPage='write';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

sub tagObj{
my $xpath=shift(@_);
return $firefox->await(sub {$firefox->find($xpath)})}

sub ctrlA{
$firefox->perform($firefox->key_down(CONTROL()), $firefox->key_down("a"), $firefox->key_up("l"), $firefox->key_up(CONTROL()));
}

tagObj('/html/body/div/input')->click();
ctrlA();
tagObj('/html/body/div/input')->type('1a!s3d$F');
tagObj('/html/body/div/h1')->click();
# sleep(10);
tagObj('/html/body/div/input')->property('value') eq '1as3df' || die "test failed!";
