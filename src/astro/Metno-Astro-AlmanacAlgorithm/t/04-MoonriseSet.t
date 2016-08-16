use Test::More;
use Time::Local qw(timegm);
use Metno::Astro::AlmanacAlgorithm qw(:all);
use strict;
use warnings;

my @data = parseMoonriseData();
plan tests => 3 * scalar @data;
foreach my $data (@data) {
    my ($town, $lat, $lon, $day, $rise, $set, $transit) = @$data;
    my ($jRise, $jSet, $jTransit, $visible) = riseSetTransit($lat, $lon, epoch2julianDay($day), MOON);
    # moonrise isn't easy to guess, so check if $jTransit on same day
    if ($rise && ($jRise >= 0)) {
        ok(compJ2E($jRise, $rise), "$town ($lat,$lon) rise $rise");
    } else {
        ok(!$visible || ($visible == 24*60*60), "no moonrise in $town $visible at ".gmtime($day));
    }
    if($set && ($jSet >= 0)) {
        if ($set < $day) {
            # Almanakk gives dates not respective to transit, but to real date
            (undef, $jSet) = riseSetTransit($lat, $lon, epoch2julianDay($set), MOON);
        }
        ok(compJ2E($jSet, $set), "$town moonset $set");
    } else {
        ok(!$visible || ($visible == 24*60*60), "no moonset in $town $visible at ".gmtime($day));
    }
SKIP: {
          skip "no transit data", 1 unless ($transit || ($jSet < 0));
          ok(compJ2E($jTransit, $transit), "$town transit $transit");
      };
}

sub compJ2E {
    my ($jDay, $epoch) = @_;
    my $ejDay = julianDay2epoch($jDay);
    my $timeDiff = 60*3;
    my $ok = (abs($ejDay - $epoch) < $timeDiff);
    if (!$ok) {
        print STDERR scalar gmtime($ejDay), "\n";
        print STDERR scalar gmtime($epoch), "\n";
    }
    return (abs($ejDay - $epoch) < $timeDiff);
}

# return data in the form
# ([name, lat, long, day(noon), sunrise, sunset, [transit]],
#  [name, lat, long, day(noon), sunrise, sunset, [transit]],
#  ...
sub parseMoonriseData {
    open F, "t/moonrise.txt" or die "cannot read t/moonrise.txt";
    my $inBlock = 0;
    my @data;
    my @town;
    while (defined (my $line = <F>)) {
        chomp $line;
        $line =~ s/^\s*//g;
        $line =~ s/\s*$//g;
        next if ($line =~ /^#/); # comment
        if ($line eq "") {
            # new block
            @town = ();
            $inBlock = 0;
            next;
        }
        $line =~ s/#.*//g;
        if (!$inBlock) {
            @town = split ' ', $line;
            if (@town != 3) {
                die "error in sunrise.txt, town isn't 'name lat long': $line\n";
            }
            $inBlock++;
        } else {
            my @localData = split ' ', $line;
            if (@localData < 3) {
                die "error in sunrise.txt, expect 'date sunrise sunset [transit]': $line\n";
            }
            my $eUp = date2epoch($localData[0], $localData[1]);
            my $eDown = date2epoch($localData[0], $localData[2]);
            my $eTransit = date2epoch($localData[0], $localData[3]);
            push @data, [@town, $eTransit,
                         $eUp, $eDown, $eTransit];
        }
    }
    return @data;
}

# convert the date and time to epochSeconds
# return undef if time not defined or "-"
sub date2epoch($$) {
    my ($date, $time) = @_;
    return undef unless $time;
    return undef if $time eq '-';
    my ($year, $mon, $mday) = split '-', $date;
    $mon--;
    my ($hour, $min) = split ':', $time;
    my $epoch = timegm(0, $min, $hour, $mday, $mon, $year);
    return $epoch;
}
