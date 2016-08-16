use Test::More tests => 2;
use Time::Local qw(timegm timelocal);
use Metno::Astro::AlmanacAlgorithm qw(:all);
use strict;
use warnings;

my $julianDate=calendar2julianDay(2008,6,26,12,0,0);
my ($az, $alt) = azimuthAltitude(49, 0, $julianDate);
# Topocentric:  Altitude 64.336 deg, Azimuth 178.452 deg
ok(abs($az - 178.452) < .5, "azimuth $az");
ok(abs($alt - 64.336) < .5, "altitude $alt");
