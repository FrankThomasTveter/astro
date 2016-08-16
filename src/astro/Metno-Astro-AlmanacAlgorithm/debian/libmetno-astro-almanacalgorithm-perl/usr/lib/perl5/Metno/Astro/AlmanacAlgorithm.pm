package Metno::Astro::AlmanacAlgorithm;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use XSLoader;
use Time::Local qw(timegm_nocheck);
use File::Spec qw();

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Metno::Astro::AlmanacAlgorithm ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
    azimuthAltitude
    julianDay2calendar
    calendar2julianDay
    epoch2julianDay
    julianDay2epoch
    riseSetTransit	
    SUN
    MOON
    MERCURY
    VENUS
    MARS
    JUPITER
    SATURN
    URANUS
    NEPTUNE
    PLUTO
    astroEvent
    epochj2000
    j2000epoch
    DTGToJ2000
    J2000ToDTG
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);


BEGIN {
    our $VERSION = '0.06';
    XSLoader::load('Metno::Astro::AlmanacAlgorithm', $VERSION);
    my $classPath = __PACKAGE__;
    $classPath = File::Spec->catfile(split '::', $classPath);
    $classPath .= '.pm';
    my $fullClassPath = $INC{$classPath};
    my ($v,$dir,$file) = File::Spec->splitpath( $fullClassPath );
    my $jplFile = File::Spec->catfile( $dir, "JPLEPH.405" );
    jplephOpen($jplFile);
}

END {
    jplephClose();
}

use constant SUN => 0;
use constant MERCURY => 1;
use constant VENUS => 2;
use constant MOON => 3;
use constant MARS => 4;
use constant JUPITER => 5;
use constant SATURN => 6;
use constant URANUS => 7;
use constant NEPTUNE => 8;
use constant PLUTO => 9;

sub astroEvent {
    ############################################
    ###### retrieve iput
    ############################################
    #
    my $tStart2000 = shift;                      # start time (in jd2000 = julianDate - 2451544.5)
    my $searchCode = shift;                      # search code; -1:previous, +1:next, 0: both, +2:until tend2000
    # Do not provide $tend2000 if $searchCode = -1, 0 or 1 !!!!!!
    my $tend2000 = ($searchCode==2 ? shift : 0); # report all events end time (in jd2000)
    my $eventId = shift;                         # requested event id (SEE TABLE BELOW)
    my $eventValr=shift;                         # array reference
    my @eventVal=@$eventValr;                    # event input data (SEE TABLE BELOW)
    my $neventVal = @eventVal;                   # number of event input data (SEE TABLE BELOW)
    my $secdec =  shift;                         # number of second decimals used in output report string 
    my $irc = shift;                             # error return code (0=ok)
    if ($irc != 0) {
	croak("Invalid call to astroEvent (non-zero irc).\n tStart2000: $tStart2000\n searchCode: $searchCode\n tend2000:   $tend2000\n eventId:    $eventId\n neventVal:  $neventVal\n eventVal:   @eventVal\n secdec:     $secdec\n irc:        $irc (must be zero)\n");
    }
    #
    ############################################
    ##### call WRAPPER subroutine
    ############################################
    #
###    @eventVal=(@eventVal,0); ### @eventVal can not be empty

#####    print "EventVal: $neventVal @eventVal\n";
#####    print "EventVal: $tStart2000,$searchCode,$tend2000,$eventId,$neventVal,@eventVal,$secdec,$irc\n";
    my @output = aa_astroEvent($tStart2000,$searchCode,$tend2000,$eventId,$neventVal,\@eventVal,$secdec,$irc);
    #
    ############################################
    #####  EXTRACT OUTPUT
    ############################################
    #
    $irc = get_irc(@output);                  # error return code
    if ($irc != 0) {
	croak("astroEvent Error return from aa_astroEvent. $irc");
    }
    my $nrep=    get_nrep(@output);            # number of output reports
    my @rep2000= get_rep2000(@output);         # time of output report (in jd2000)
    my @repId=   get_repId(@output);           # output report identification (SEE TABLE BELOW)
    my @repVal=  get_repVal(@output);          # output report value (SEE TABLE BELOW)
    my @rep250=  get_rep250(@output);          # output report string (redundant description)
    ############################################
    ##### return output
    ############################################
    return ($irc,$nrep,\@rep2000,\@repId,\@repVal,\@rep250); # this is the same layout as output from aa_astroEvent
}

sub get_irc {
    my @copy=@_;
    return shift @copy;
}
sub get_nrep {
    my @copy=@_;
    if (shift @copy == 0 ) {
	return shift @copy;
    } else {
	return ();
    }
}
sub get_rep2000 {
    my @copy=@_;
    if (shift @copy == 0 ) {
	my $nrep= shift @copy;
	my @ret=();;
	for (my $ii=0; $ii < $nrep; $ii++) {
	    push(@ret,shift @copy);        # time of output report (in jd2000)
	}
	return @ret;
    } else {
	return ();
    }
}

sub get_repId {
    my @copy=@_;
    if (shift @copy == 0 ) {
	my $nrep= shift @copy;
	my @ret=();;
	for (my $ii=0; $ii < $nrep; $ii++) {
	    shift @copy;                   # time of output report (in jd2000)
	}
	for (my $ii=0; $ii < $nrep; $ii++) {
	    push(@ret,shift @copy);        # output report identification (SEE TABLE BELOW)
	}
	return @ret;
    } else {
	return ();
    }
}

sub get_repVal {
    my @copy=@_;
    if (shift @copy == 0 ) {
	my $nrep= shift @copy;
	my @ret=();;
	for (my $ii=0; $ii < $nrep; $ii++) {
	    shift @copy;                   # time of output report (in jd2000)
	}
	for (my $ii=0; $ii < $nrep; $ii++) {
	    shift @copy;                   # output report identification (SEE TABLE BELOW)
	}
	for (my $ii=0; $ii < $nrep; $ii++) {
	    push(@ret,shift @copy);        # output report value (SEE TABLE BELOW)
	}
	return @ret;
    } else {
	return ();
    }
}

sub get_rep250 {
    my @copy=@_;
    if (shift @copy == 0 ) {
	my $nrep= shift @copy;
	my @ret=();;
	for (my $ii=0; $ii < $nrep; $ii++) {
	    shift @copy;                   # time of output report (in jd2000)
	}
	for (my $ii=0; $ii < $nrep; $ii++) {
	    shift @copy;                   # output report identification (SEE TABLE BELOW)
	}
	for (my $ii=0; $ii < $nrep; $ii++) {
	    shift @copy;                   # output report value (SEE TABLE BELOW)
	}
	for (my $ii=0; $ii < $nrep; $ii++) {
	    push(@ret,trim(shift @copy));        # output report string (redundant description)
	}
	return @ret;
    } else {
	return ();
    }
}

sub trim($)  { # removes initial and trailing whitespace
	my $string = shift;
	$string =~ s/^\s+//; # remove initial whitespace
	$string =~ s/\s+$//; # remote trailing whitespace
	return $string;
}

sub epochj2000 {
    my ($epoch) = @_;
    my ($sec, $min, $hour, $mday, $month, $year) = gmtime($epoch);
    $year += 1900;
    $month++;
    return DTGToJ2000($year, $month, $mday, $hour, $min, $sec);
}

sub j2000epoch {
    my ($J2000) = @_;
    my ($year, $month, $mday, $hour, $min, $sec) = 
        J2000ToDTG($J2000);
    $sec = int (.5 + $sec);
    return timegm_nocheck($sec, $min, $hour, $mday, $month -1, $year);
}
    
# Preloaded methods go here.
sub riseSetTransit {
    my ($latitude, $longitude, $julianDay, $planetNo, $height, $temperature,
            $pressure, $jdflag, $deltaT) = @_;
    unless (defined $longitude) {
        croak("latitude and longitude required for riseSetTransit");
    }
    $julianDay = epoch2julianDay(gmtime(time)) unless defined $julianDay;
    $planetNo = SUN unless defined $planetNo;

    $height = 0 unless defined $height;
    $temperature = 10 unless defined $temperature;
    $pressure = 1010 unless defined $pressure;
    $jdflag = 2 unless defined $jdflag;
    $deltaT = 0 unless defined $deltaT;
    $planetNo = SUN unless defined $planetNo;

    my ($transit, $set, $rise, $setN, $riseN, $visible) = 
        aa_calcSetRise($longitude, $latitude, $height, $temperature,
                $pressure, $jdflag, $deltaT, $julianDay, $planetNo);
    # print STDERR scalar(gmtime(julianDay2epoch($rise))), "   ", scalar(gmtime(julianDay2epoch($transit))), "   ", scalar(gmtime(julianDay2epoch($set))), "  ", $visible, "\n";
    my $visSeconds = int (3600*$visible);
    return ($rise, $set, $transit, $visSeconds, $riseN, $setN);
}

sub azimuthAltitude {
    my ($latitude, $longitude, $julianDay, $planetNo, $height, $temperature,
            $pressure, $jdflag, $deltaT) = @_;
    unless (defined $julianDay) {
        croak("latitude, longitude and julianDay required for azimuthAltitude");
    }
    $planetNo = SUN unless defined $planetNo;

    $height = 0 unless defined $height;
    $temperature = 10 unless defined $temperature;
    $pressure = 1010 unless defined $pressure;
    $jdflag = 2 unless defined $jdflag;
    $deltaT = 0 unless defined $deltaT;
    $planetNo = SUN;
    my ($az, $alt) = 
        aa_calcAzimuthAltitude($longitude, $latitude, $height, $temperature,
                $pressure, $jdflag, $deltaT, $julianDay, $planetNo);
    return ($az, $alt);
}

sub epoch2julianDay {
    my ($epoch) = @_;
    my ($sec, $min, $hour, $mday, $month, $year) = gmtime($epoch);
    $year += 1900;
    $month++;
    return calendar2julianDay($year, $month, $mday, $hour, $min, $sec);
}

sub julianDay2epoch {
    my ($julianDay) = @_;
    my ($year, $month, $mday, $hour, $min, $sec) = 
        julianDay2calendar($julianDay);
    $sec = int (.5 + $sec);
    return timegm_nocheck($sec, $min, $hour, $mday, $month -1, $year);
}
    
    

1;
__END__
# Below is stub documentation for your module. 

=head1 NAME

Metno::Astro::AlmanacAlgorithm - Algorithms to calculate Astronomical events

=head1 SYNOPSIS

  use Metno::Astro::AlmanacAlgorithm qw(:all);
  my $jDay = calendar2julianDay(1973, 6, 26, 9, 51, 0.34);
  my @birthTownLatLon = (51.15, 7.216667);
  my ($rise, $set, $transit, $visibleSecs) =
        riseSetTransit(@birthTownLatLon, $jDay);
  if ($visibleSecs == 0) {
      print "no sun\n";
  } elsif ($visibleSecs = 24*60*60) {
      print "midnightsun\n";
  } else {
      my @riseCal = julianDay2calendar($rise);
      print "Rise: @riseCal\n";
  }
  # use direct interface to event-library to search for next ("+1") sunrise (eventId="600")
  my ($irc,$nrep,$rep2000,$repId,$repVal,$rep250) = 
         astroEvent(DTGToJ2000(2008,6,26,12,0,0),+1,600,[60.,0.,0.],0,0);
  if ($nrep == 1) {
     my ($yy,$mm,$dd,$hh,$mi,$sec)=J2000ToDTG($$rep2000[0])
     print "Sun rises at: $yy/$mm/$dd $hh:$mi:$sec\n";
   }
    
=head1 DESCRIPTION

This package calcuates astronimical events, e.g. sunrise and sunset.
A direct interface to the underlying astronomical library is available here.
The libaray is based on JPL ephemerides DE405 and uses the most accurate
methods available to estimate astronomical events.

=head2 PUBLIC FUNCTIONS

=over 4

=item B<julianDay2calendar> $julianDay

Calculate the calendar days (Gregorian Calendar) from a julian day. It returns
($year, $month, $mday, $hour, $min, $sec) with the current year as 2008, month
between (1-12), mday between (1-31), hour between (0-23), min between
(0-59) and seconds between (0.0 - 59.99999).

The calendar functions will croak if the julianDay is out of range (< 0).

=item B<julianDay2epoch> $julianDay

Same as above, but the calendar is converted to seconds since 1970-01-01.

=item B<calendar2julianDay> $year, $month, $mday, $hour, $min, $sec

This function is the inverse of julianDay2calendar. It returns the $julianDay
as floating-point number

=item B<epoch2julianDay> $epoch

Same as above, but the calendar is converted to seconds since 1970-01-01.

=item  B<riseSetTransit> $latitude, $longitude, [$julianDay = now, $planetNo = SUN, $height = 0, $temperature = 10, $pressure = 1010, $jdflag = 2, $deltaT = 0]

Calculate ($rise, $set, $transit, $visibleSeconds) of the planet/sun/moon at
the given place (latitude, longitude) on earth. All parameters in brackets
are optional, with given default values. 

It returns the rise, set and transit of the astronomical object in julianDays.
rise and set are set to -1 if it doesn't happen the given day. For the SUN,
visibleSeconds = 24*60*60 if midnightsun and 0 if no sun at all.

The transit time returned will be within half a day of the given $julianDay.
Make sure to give a $julianDay close to wanted date i.e. by using a local noon
for the sunrise/set:

    $hour = 12 + $longitude/360;

B<Input parameters:>

=over 12

=item latitude in decimals

=item longitude in decimals

=item julianDay

=item planetNo should be given by one of the constants SUN, MOON, MERCURY to PLUTO

=item height altitude in m

=item temperature in degree C

=item pressure in hPa

=item jdFlag (0 - 2), 0: TDT = UT, 1 input = TDT, 2 input = UT

=item deltaT difference between TDT and UT in s, calculate if 0

=back

This function wil croak if the input is wrong or the event didn't converge.

=item  B<azimuthAltitude> $latitude, $longitude, $julianDay, [$planetNo = SUN, $height = 0, $temperature = 10, $pressure = 1010, $jdflag = 2, $deltaT = 0]

Calculate the topocentric azimuth and altitude at the given earth positions latitude and longitude and the given julianDay. The function
return ($az, $alt) in decimal degrees of the center of the object. The input default are the same as in I<riseSetTransit>, except that the
julianDay is required.

This function will croak on wrong input or calculation problems.

=item  B<astroEvent> $tStart2000, $searchCode, $tend2000, $eventId, \@eventVal, $secdec, $irc 

Interface to the astronomical events library which allows the
user to calculate around 120 astronomical event parameters.
When is the next winter solstice? When is the next lunar eclipse?
Given a position in longitude and latitude and date-time-group, find
out when the moon will rise and set, when the polar night starts etc. 

All times are in UTC in J2000. Coordinates are given with east 
and north as positive values. The requested event is specified
using the "eventId" input parameter, along with the necessary
eventVariables in the "eventVal" array. The result is a set of
reports which contain the time of the event, the report id, the
report value and a redundant description of the report. The user
may search for next/previous event or all events in a specified 
period.


B<Input parameters:>

=over 12

=item  $tstart2000, start time (in j2000)

=item  $searchCode, search code; -1:previous, +1:next, 0: both, +2:until tend2000

=item  $tend2000,   report all events end time (in j2000), only present if $searchCode=+2.

=item  $eventId,    requested event id (SEE TABLE BELOW)

=item  \@eventVal,  input data (SEE TABLE BELOW) array reference

=item  secdec,      number of second decimals used in output report string 

=item  irc,         error return code which must always be zero.

=back

$tend2000 must only be present if $searchCode is +2.

B<Output parameters:>

=over 12

=item  $irc         error return code (0=ok)

=item  $nrep,       number of output reports

=item  \@rep2000,   time of output report (in j2000) array reference 

=item  \@repId,     output report identification (SEE TABLE BELOW) array reference 

=item  \@repVal,    output report value (SEE TABLE BELOW) array reference 

=item  \@rep250,    output report string (redundant description) array reference

=back

B<Example:>

($irc,$nrep,$rep2000,$repId,$repVal,$rep250) = astroEvent(DTGToJ2000(2008,6,26,12,0,0),+1,600,[60.,0.,0.],0,0);

which returns time of next sunrise (eventId=+600) for the position (lat=60, lon=0, height=0) after 2008/6/26 12:00:00.0.
with 0 decimals precision to the seconds. In this case $nrep is 1 and $$rep2000[0] is the julian day 2000 of the
sunrise, $$repId[0] is 600, $$repVal[0] is undefined (-99999) and $$$rep250[0] is a redundant string.
Use ($yy,$mm,$dd,$hh,$mi,$sec)=J2000ToDTG($$rep2000[0]) to retrieve the date-time-group of the sunrise.

=back

=item B<epochj2000> $epoch

Calculate Julian day since 2000-1-1 from epoch (seconds since 1970-01-01).
Routine returns ($j2000).

=item B<j2000epoch> $j2000

Calculates epoch (seconds since 1970-01-01) from Julian day since 2000-1-1.
Routine returns ($epoch).

=item B<DTGToJ2000> $year, $month, $mday, $hour, $min, $sec

Calculate Julian day since 2000-1-1 from date-time-group.
Routine returns ($j2000).

=item B<J2000ToDTG> $j2000

Calculates date-time-group from Julian day since 2000-1-1.
Routine returns ($year, $month, $mday, $hour, $min, $sec).


=head1 EXPORT

None by default. All contains:

=over 4

=item julianDay2calendar

=item epoch2julianDay

=item julianDay2epoch

=item riseSetTransit

=item azimuthAltitude	

=item    SUN

=item    MOON

=item    MERCURY

=item    VENUS

=item    MARS

=item    JUPITER

=item    SATURN

=item    URANUS

=item    NEPTUNE

=item    PLUTO

=item    astroEvent

=item    epochj2000

=item    j2000epoch

=item    DTGToJ2000

=item    J2000ToDTG

=back

=over 8

=head1  ASTRONOMICAL EVENT IDENTIFICATION TABLE FOR "astroEvent"


=item B<EVENTID  = 100  'REPORT LOCAL INITIAL MOON STATE'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 100 -> if (repval >= 1) "moon is above horison" (repval <=-1) "moon is below"

=item o  repId = 101 -> if (repval >= 1) "lunar polar day" (repval =0) "no lunar polar effect" (repval<=-1) "lunar polar night"

=item o  repId = 102 -> moon phase

=item B<EVENTID  = 110 : 'REPORT LOCAL TC EF MOON POSITION AT TIME INCREMENT'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item i  eventVal(4) = time increment (days)

=item o  repId = 110 -> repval = moon elevation (deg)

=item o  repId = 111 -> repval = moon azimuth (deg)

=item o  repId = 112 -> repval = moon range (km)

=item B<EVENTID  = 120 : 'REPORT LOCAL INITIAL SUN STATE'>
 
=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 120 -> if (repval >= 1) "sun is above horison" (repval <=-1) "sun is below"

=item o  repId = 121 -> if (repval >= 1) "polar day" (repval =0) "no polar effect" (repval<=-1) "polar night"

=item B<EVENTID  = 130 : 'REPORT LOCAL TC EF SUN POSITION AT TIME INCREMENT'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item i  eventVal(4) = time increment (days)

=item o  repId = 130 -> repval = sun elevation (deg)

=item o  repId = 131 -> repval = sun azimuth (deg)

=item o  repId = 132 -> repval = sun range (km)
      
=item B<EVENTID  = 150 : 'DETECT WINTER SOLSTICE'>

=item o  repId = 150 -> event found

=item B<EVENTID  = 160 : 'DETECT VERNAL EQUINOX'>

=item o  repId = 160 -> event found

=item B<EVENTID  = 170 : 'DETECT SUMMER SOLSTICE'>

=item o  repId = 170 -> event found

=item B<EVENTID  = 180 : 'DETECT AUTUMNAL EQUINOX'>

=item o  repId = 180 -> event found

=item B<EVENTID  = 190 : 'DETECT EARTH IN PERIHELION'>

=item o  repId = 190 -> repval = sun range (km)

=item B<EVENTID  = 200 : 'DETECT EARTH IN APHELION'>

=item o  repId = 200 -> repval = sun range (km)
      
=item B<EVENTID  = 210 : 'DETECT NEW MOON (PHASE=0/100)'>

=item o  repId = 210 -> event found

=item B<EVENTID  = 220 : 'DETECT FIRST QUARTER MOON (PHASE=25)'>

=item o  repId = 220 -> event found

=item B<EVENTID  = 230 : 'DETECT FULL MOON (PHASE=50)'>

=item o  repId = 230 -> event found

=item B<EVENTID  = 240 : 'DETECT LAST QUARTER MOON (PHASE=75)'>

=item o  repId = 240 -> event found

=item B<EVENTID  = 250 : 'DETECT MOON PHASE (0 TO 100)'>

=item i  eventVal(1) = target moon phase

=item o  repId = 250 -> event found

=item B<EVENTID  = 260 : 'DETECT MOON ILLUMINATION MINIMUM'>

=item o  repId = 260 -> event found

=item B<EVENTID  = 270 : 'DETECT MOON ILLUMINATION MAXIMUM'>

=item o  repId = 270 -> event found

=item B<EVENTID  = 280 : 'DETECT MOON ILLUMINATION (0 TO 100)'>

=item i  eventVal(1) = target moon illumination

=item o  repId = 280 -> event found
      
=item B<EVENTID  = 300 : 'DETECT MERCURY INFERIOR CONJUNCTION'>

=item o  repId = 300 -> event found

=item B<EVENTID  = 310 : 'DETECT MERCURY SUPERIOR CONJUNCTION'>

=item o  repId = 310 -> event found

=item B<EVENTID  = 320 : 'DETECT MERCURY GREATEST WESTERN ELONGATION'>

=item o  repId = 320 -> event found

=item B<EVENTID  = 330 : 'DETECT MERCURY GREATEST EASTERN ELONGATION'>

=item o  repId = 330 -> event found
      
=item B<EVENTID  = 340 : 'DETECT VENUS INFERIOR CONJUNCTION'>

=item o  repId = 340 -> event found

=item B<EVENTID  = 350 : 'DETECT VENUS GREATEST WESTERN ELONGATION'>

=item o  repId = 350 -> event found

=item B<EVENTID  = 360 : 'DETECT VENUS SUPERIOR CONJUNCTION'>

=item o  repId = 360 -> event found

=item B<EVENTID  = 370 : 'DETECT VENUS GREATEST EASTERN ELONGATION'>

=item o  repId = 370 -> event found
      
=item B<EVENTID  = 380 : 'DETECT MARS CONJUNCTION'>

=item o  repId = 380 -> event found

=item B<EVENTID  = 390 : 'DETECT MARS WESTERN QUADRATURE'>

=item o  repId = 390 -> event found

=item B<EVENTID  = 400 : 'DETECT MARS OPPOSITION'>

=item o  repId = 400 -> event found

=item B<EVENTID  = 410 : 'DETECT MARS EASTERN QUADRATURE'>

=item o  repId = 410 -> event found
      
=item B<EVENTID  = 420 : 'DETECT JUPITER CONJUNCTION'>

=item o  repId = 420 -> event found

=item B<EVENTID  = 430 : 'DETECT JUPITER WESTERN QUADRATURE'>

=item o  repId = 430 -> event found

=item B<EVENTID  = 440 : 'DETECT JUPITER OPPOSITION'>

=item o  repId = 440 -> event found

=item B<EVENTID  = 450 : 'DETECT JUPITER EASTERN QUADRATURE'>

=item o  repId = 450 -> event found
      
=item B<EVENTID  = 460 : 'DETECT SATURN CONJUNCTION'>

=item o  repId = 460 -> event found

=item B<EVENTID  = 470 : 'DETECT SATURN WESTERN QUADRATURE'>

=item o  repId = 470 -> event found

=item B<EVENTID  = 480 : 'DETECT SATURN OPPOSITION'>

=item o  repId = 480 -> event found

=item B<EVENTID  = 490 : 'DETECT SATURN EASTERN QUADRATURE'>

=item o  repId = 490 -> event found
      
=item B<EVENTID  = 500 : 'DETECT MERCURY TRANSIT (SOMEWHERE ON EARTH)'>

=item o  repId = 500 -> transit starts

=item o  repId = 501 -> transit ends

=item B<EVENTID  = 520 : 'DETECT VENUS TRANSIT (SOMEWHERE ON EARTH)'>

=item o  repId = 520 -> transit starts

=item o  repId = 521 -> transit ends
      
=item B<EVENTID  = 550 : 'DETECT LUNAR ECLIPSE (MINOCC MAXOCC)'>

=item i  eventVal(1) = minimum occultation (0 to 100)

=item i  eventVal(2) = maximum occultation (0 to 100)

=item o  repId = 550 -> penumbra contact starts (P1)

=item o  repId = 551 -> umbra contact starts (U1)

=item o  repId = 552 -> total eclipse starts (U2)

=item o  repId = 553 -> repval = maximum occultation

=item o  repId = 554 -> total eclipse stops (U3)

=item o  repId = 555 -> umbra contact stops (U4)

=item o  repId = 556 -> penumbra contact stops (P2)

=item B<EVENTID  = 560 : 'DETECT LUNAR ECLIPSE -LUNECL[0]'>

=item o  repId = 560 -> penumbra contact starts (P1)

=item o  repId = 561 -> umbra contact starts (U1)

=item o  repId = 562 -> total eclipse starts (U2)

=item o  repId = 563 -> repval = maximum occultation

=item o  repId = 564 -> total eclipse stops (U3)

=item o  repId = 565 -> umbra contact stops (U4)

=item o  repId = 566 -> penumbra contact stops (P2)
      
=item B<EVENTID  = 600 : 'DETECT LOCAL DIURNAL SUN RISE'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 600 -> event found
=item B<EVENTID  = 610 : 'DETECT LOCAL DIURNAL SUN SET'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 610 -> event found

=item B<EVENTID  = 620 : 'DETECT LOCAL DIURNAL MAXIMUM SOLAR ELEVATION'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 620 -> repval = maximum solar elevation (deg)

=item B<EVENTID  = 630 : 'DETECT LOCAL DIURNAL MINIMUM SOLAR ELEVATION'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 630 -> repval = minimum solar elevation (deg)

=item B<EVENTID  = 640 : 'DETECT LOCAL DIURNAL CIVIL TWILIGHT START'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 640 -> event found

=item B<EVENTID  = 650 : 'DETECT LOCAL DIURNAL CIVIL TWILIGHT STOP'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 650 -> event found

=item B<EVENTID  = 660 : 'DETECT LOCAL DIURNAL NAUTICAL TWILIGHT START'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 660 -> event found

=item B<EVENTID  = 670 : 'DETECT LOCAL DIURNAL NAUTICAL TWILIGHT STOP'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 670 -> event found

=item B<EVENTID  = 680 : 'DETECT LOCAL DIURNAL ASTRONOMICAL TWILIGHT START'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 680 -> event found

=item B<EVENTID  = 690 : 'DETECT LOCAL DIURNAL ASTRONOMICAL TWILIGHT STOP'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 690 -> event found

=item B<EVENTID  = 700 : 'DETECT LOCAL DIURNAL NIGHT START'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 700 -> event found

=item B<EVENTID  = 710 : 'DETECT LOCAL DIURNAL NIGHT STOP'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 710 -> event found

=item B<EVENTID  = 750 : 'DETECT LOCAL DIURNAL SUN AZIMUTH (0=NORTH, 90=EAST)'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item i  eventVal(4) = sun azimuth (deg)

=item o  repId = 750 -> event found

=item B<EVENTID  = 760 : 'DETECT LOCAL DIURNAL APPARENT SOLAR TIME'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item i  eventVal(4) = apparent solar time (0 to 24)

=item o  repId = 760 -> event found

=item B<EVENTID  = 770 : 'DETECT LOCAL DIURNAL APPARENT LUNAR TIME'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item i  eventVal(4) = apparent lunar time (0 to 24)

=item o  repId = 770 -> event found

=item B<EVENTID  = 800 : 'DETECT LOCAL DIURNAL MOON RISE'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 800 -> event found

=item B<EVENTID  = 810 : 'DETECT LOCAL DIURNAL MOON SET'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 810 -> event found

=item B<EVENTID  = 820 : 'DETECT LOCAL DIURNAL MAXIMUM MOON ELEVATION'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 820 -> repVal = maximum moon elevation

=item B<EVENTID  = 830 : 'DETECT LOCAL DIURNAL MINIMUM MOON ELEVATION'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 830 -> repVal = minimum moon elevation

=item B<EVENTID  = 840 : 'DETECT LOCAL DIURNAL MOON AZIMUTH (0=NORTH, 90=EAST)'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item i  eventVal(4) = moon azimuth (deg)

=item o  repId = 840 -> event found
      
=item B<EVENTID  = 900 : 'DETECT LOCAL POLAR SUN DAY START'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 900 -> event found

=item o  repId = 901 -> previous sun rise

=item B<EVENTID  = 910 : 'DETECT LOCAL POLAR SUN DAY STOP'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 910 -> event found

=item o  repId = 911 -> next sun set

=item B<EVENTID  = 920 : 'DETECT LOCAL POLAR SUN NIGHT START'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 920 -> event found

=item o  repId = 921 -> previous sun set

=item B<EVENTID  = 930 : 'DETECT LOCAL POLAR SUN NIGHT STOP'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 930 -> event found

=item o  repId = 931 -> next sun rise

=item B<EVENTID  = 940 : 'DETECT LOCAL POLAR LUNAR DAY START'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 940 -> event found

=item o  repId = 941 -> previous moon rise

=item B<EVENTID  = 950 : 'DETECT LOCAL POLAR LUNAR DAY STOP'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 950 -> event found

=item o  repId = 951 -> next moon set

=item B<EVENTID  = 960 : 'DETECT LOCAL POLAR LUNAR NIGHT START'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 960 -> event found

=item o  repId = 961 -> previous moon set

=item B<EVENTID  = 970 : 'DETECT LOCAL POLAR LUNAR NIGHT STOP'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 970 -> event found

=item o  repId = 971 -> next moon rise

=item B<EVENTID  = 980 : 'DETECT LOCAL SOLAR ECLIPSE (MINOCC MAXOCC)'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item i  eventVal(4) = minimum occultation (0 to 100)

=item i  eventVal(5) = maximum occultation (0 to 100)

=item o  repId = 980 -> partial solar eclipse starts

=item o  repId = 981 -> total solar eclipse starts

=item o  repId = 982 -> repVal = maximum occultation

=item o  repId = 983 -> total solar eclipse stops

=item o  repId = 984 -> partial solar eclipse stops

=item B<EVENTID  = 990 : 'DETECT LOCAL SOLAR ECLIPSE'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item o  repId = 990 -> partial solar eclipse starts

=item o  repId = 991 -> total solar eclipse starts

=item o  repId = 992 -> repVal = maximum occultation

=item o  repId = 993 -> total solar eclipse stops

=item o  repId = 994 -> partial solar eclipse stops

=item B<EVENTID  = 1000 : 'REPORT LOCAL TC EF SOLAR SYSTEM POSITIONS AT TIME INCREMENT'>

=item i  eventVal(1) = latitude of observer (deg)

=item i  eventVal(2) = longtitude of observer (deg)

=item i  eventVal(3) = height of observer (deg)

=item i  eventVal(4) = time increment (days)

=item o  repId = 1000 -> repval = sun elevation (deg)

=item o  repId = 1001 -> repval = sun azimuth (deg)

=item o  repId = 1002 -> repval = sun range (km)

=item o  repId = 1010 -> repval = mercury elevation (deg)

=item o  repId = 1011 -> repval = mercury azimuth (deg)

=item o  repId = 1012 -> repval = mercury range (km)

=item o  repId = 1020 -> repval = venus elevation (deg)

=item o  repId = 1021 -> repval = venus azimuth (deg)

=item o  repId = 1022 -> repval = venus range (km)

=item o  repId = 1030 -> repval = moon elevation (deg)

=item o  repId = 1031 -> repval = moon azimuth (deg)

=item o  repId = 1032 -> repval = moon range (km)

=item o  repId = 1040 -> repval = mars elevation (deg)

=item o  repId = 1041 -> repval = mars azimuth (deg)

=item o  repId = 1042 -> repval = mars range (km)

=item o  repId = 1050 -> repval = jupiter elevation (deg)

=item o  repId = 1051 -> repval = jupiter azimuth (deg)

=item o  repId = 1052 -> repval = jupiter range (km)

=item o  repId = 1060 -> repval = saturn elevation (deg)

=item o  repId = 1061 -> repval = saturn azimuth (deg)

=item o  repId = 1062 -> repval = saturn range (km)

=item o  repId = 1070 -> repval = uranus elevation (deg)

=item o  repId = 1071 -> repval = uranus azimuth (deg)

=item o  repId = 1072 -> repval = uranus range (km)

=item o  repId = 1080 -> repval = neptun elevation (deg)

=item o  repId = 1081 -> repval = neptun azimuth (deg)

=item o  repId = 1082 -> repval = neptun range (km)

=item o  repId = 1090 -> repval = pluto elevation (deg)

=item o  repId = 1091 -> repval = pluto azimuth (deg)

=item o  repId = 1092 -> repval = pluto range (km)

=cut




=head1 CAVEATS

B<riseSetTransit>: The rise/set/transit dates close to the northpole 
and the southpole (88-90deg) don't converge and throw errors.

=head1 SEE ALSO

=head1 AUTHOR

Heiko Klein, E<lt>Heiko.Klein@met.noE<gt>
Frank Tveter, E<lt>Frank.Tveter@met.noE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by met.no

This perl library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
