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

my $webPage='index';

$firefox->go('file:///tmp/DB/' . $webPage . '.html');
$firefox->await(sub{$firefox->uri =~ m/$webPage/});

print("==== Test 1\n");
sub tagObj{
my $xpath=shift(@_);
return $firefox->await(sub {$firefox->find($xpath)})}

my $husbandPath='/html/body/p[1]/label[1]/input';
my $husbandW=tagObj($husbandPath)->property('value');

my $wifePath='/html/body/p[1]/label[2]/input';
my $wifeW=tagObj($wifePath)->property('value');

my $familyPath='/html/body/p[3]/span';
my $familyW=tagObj($familyPath)->text;

print("husband weight= " . $husbandW . "\n");
print("wife weight= " . $wifeW . "\n");
print("family weight= " . $familyW . "\n");

($familyW == $husbandW + $wifeW) or die "test 1 failed!";

print("==== Test 2\n");
sub ctrlA{
$firefox->perform($firefox->key_down(CONTROL()), $firefox->key_down("a"), $firefox->key_up("l"), $firefox->key_up(CONTROL()));
}

$firefox->find($husbandPath)->click();
ctrlA();
tagObj($husbandPath)->type('' . (180+int(rand(50))));

$firefox->find($wifePath)->click();
ctrlA();
tagObj($wifePath)->type('' . (140+int(rand(50))));

$firefox->find($familyPath)->click();
    
$husbandW=tagObj($husbandPath)->property('value');
$wifeW=tagObj($wifePath)->property('value');
$familyW=tagObj($familyPath)->text;

print("husband weight= " . $husbandW . "\n");
print("wife weight= " . $wifeW . "\n");
print("family weight= " . $familyW . "\n");

($familyW == $husbandW + $wifeW) or die "test 2 failed!";
