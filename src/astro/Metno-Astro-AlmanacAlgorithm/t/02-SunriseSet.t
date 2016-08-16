use Test::More;
use Time::Local qw(timegm);
use Metno::Astro::AlmanacAlgorithm qw(:all);
use strict;
use warnings;

my @data = parseSunriseData();
plan tests => (3 * scalar @data);

foreach my $data (@data) {
    my ($town, $lat, $lon, $day, $rise, $set, $transit) = @$data;
    my ($jRise, $jSet, $jTransit, $visible) = riseSetTransit($lat, $lon, epoch2julianDay($day));
    if ($rise) {
        ok(compJ2E($jRise, $rise), "$town ($lat,$lon) rise $rise");
    } else {
        if ($visible == 0) {
            ok(1, "darkness in $town at ". scalar gmtime($day));
        } elsif ($visible == 24*60*60) {
            ok(1, "midnightsun in $town at ". scalar gmtime($day));
        } else {
            ok(0, "neither midnightsun nor darkness in $town at ".scalar gmtime($day));
        }
    }
    if($set) {
        ok(compJ2E($jSet, $set), "$town set $set");
    } else {
        ok(!$visible || ($visible == 24*60*60), "no sunset in $town at $day");
    }
SKIP: {
          skip "no transit data", 1 unless $transit;
          ok(compJ2E($jTransit, $transit), "$town transit $transit");
      };
}

sub compJ2E {
    my ($jDay, $epoch) = @_;
    my $ejDay = julianDay2epoch($jDay);
    my $timeDiff = 3*60;
    my $ok = (abs($ejDay - $epoch) < $timeDiff);
    if (!$ok) {
        print STDERR "*** Estimated: " , scalar gmtime($ejDay), "\n";
        print STDERR "*** Reference: " , scalar gmtime($epoch), "\n";
    }
    return $ok;
}

# return data in the form
# ([name, lat, long, day(noon), sunrise, sunset, [transit]],
#  [name, lat, long, day(noon), sunrise, sunset, [transit]],
#  ...
sub parseSunriseData {
    open F, "t/sunrise.txt" or die "cannot read t/sunrise.txt";
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
            my $townMidday = 12 - ($town[2]*12/180);
            my $townHour = int ($townMidday);
            my $townMin = int(($townMidday - $townHour)*60);
            push @data, [@town, date2epoch($localData[0], "$townHour:$townMin"),
                         date2epoch($localData[0], $localData[1]),
                         date2epoch($localData[0], $localData[2]),
                         date2epoch($localData[0], $localData[3])];
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
