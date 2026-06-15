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

my $webPage='href';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

sub tagObj{
my $xpath=shift(@_);
return $firefox->await(sub {$firefox->find($xpath)})}

sub ctrlA{
$firefox->perform($firefox->key_down(CONTROL()), $firefox->key_down("a"), $firefox->key_up("l"), $firefox->key_up(CONTROL()));
}

#################
my $linkOne='/html/body/p[2]/a';
my $linkTwo='/html/body/p[3]/a';
my $inputYear='/html/body/label/input';

tagObj($linkOne)->property('href') eq 'http://www.great-artist.com/gallery/2010/' or die "test 1 failed!";
tagObj($linkTwo)->property('href') eq 'http://www.great-artist.com/gallery/2011/' or die "test 2 failed!";

$firefox->find($inputYear)->click();
ctrlA();
tagObj($inputYear)->type('2012');
$firefox->find('/html/body/h1')->click();

tagObj($linkTwo)->property('href') eq 'http://www.great-artist.com/gallery/2012/' or die "test 3 failed!";
