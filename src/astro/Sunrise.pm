# -*- coding: utf-8; -*-
# $Id: Sunrise.pm,v 1.3 2014-06-18 05:26:26 franktt Exp $

=head1 NAME

B<Sunrise> - When does the sun rise and set for a given place?

=head1 DESCRIPTION

Given a position in longitude and latitude and date, send a B<simple request> and
find out when the sun and the moon rise and set.  The elevation angle of the sun at
solar noon is also given. You can either specify a given date using the 
B<date> parameter or you can ask for a range, using the parameters 
B<from> and B<to> (which both are inclusive). 
Note that the algorithm estimates the timezone based on longitude, and events 
around midnight can therefore be misplaced with respect to the local date.

B<Direct request>s can also be sent to the underlying astronomical event library. 
This option is only recommended for advanced users.

The times are all in UTC. Coordinates are given with east and north as positive values.  

=head1 SCHEMA

Schema is available as [% productroot %]/1.0/schema

=head1 USAGE

A B<simple request> to retrieve processed Sun/Moon rise/set 
information has the following parameters:

=over 4

=item * B<lat> (latitude), in decimal degrees, B<mandatory>

=item * B<lon> (longtitude), in decimal degrees, B<mandatory>

=item * B<date>, given as YYYY-MM-DD

=item * B<from>, given as YYYY-MM-DD

=item * B<to>, given as YYYY-MM-DD

The from-to-query is limited to max 30 days per request.

=back

B<Sample simple request URLs> ("sunrise data for a day", "sunrise data for a period", "day with several moonrises")

=over 4

=item * [% productroot %]/1.0/?lat=71.0;lon=-69.58;date=2008-06-23

=item * [% productroot %]/1.0/?lat=60.10;lon=9.58;from=2009-04-01;to=2009-04-15

=item * [% productroot %]/1.0/?lat=70;lon=19;date=2011-06-07

=back

A B<direct request> to the underlying astronomical event library has the following parameters:

=over 4

=item * B<eventStart>,   start time given as YYYY-MM-DDTHH:MI:SSZ

=item * B<eventSearch>,  event search code; -1:previous, +1:next, 0: both, +2:until eventStop

=item * B<eventStop>,    report all events until eventStop given as YYYY-MM-DDTHH:MI:SSZ, must only be present if eventSearch=+2.

=item * B<eventId>,      requested event id (SEE TABLE BELOW)

=item * B<eventVal><N>,  input data (SEE TABLE BELOW) array, where <N> is the array index.


Several direct requests can be grouped in the same batch by 
assigning a sequence number (from 1 to 9) immediately 
after "event" in the parameter name, for instance "event3Id".
In this case, no identifier indicates the default values and 
the default request will not be processed.

=back

B<Sample direct request URLs> ("next solar eclipse", "previous and next sunset and sunrise" and "midnight sun start and stop for Kirkenes over two years").

=over 4

=item * [% productroot %]/1.0/?eventStart=2008-06-23T23:00:00Z;eventSearch=1;eventId=990;eventVal1=60.0;eventVal2=0.0;eventVal3=0.0

=item * [% productroot %]/1.0/?eventStart=2008-06-23T23:00:00Z;eventSearch=0;event1Id=600;event2Id=610;event3Id=800;event4Id=810;eventVal1=60.0;eventVal2=0.0;eventVal3=0.0

=item * [% productroot %]/1.0/?eventStart=2008-06-23T23:00:00Z;eventSearch=2;eventStop=2010-06-23T23:00:00Z;event1Id=900;event2Id=910;event3Id=820;eventVal1=69.7;eventVal2=30.1;eventVal3=0.0

=back

=head1 Changelog

=head2 version 2.0: 2012-01-11

=over 4

=item - Added direct request to astronomical event library.
=item - Uses JPL ephemerides DE405.
=item - Output now agrees well with "Almanakk for Norge".

=back

=head2 version 1.0: 2012-01-11

=over 4

=item - Maximum 30 days are accepted in from-to search

=back

=head2 version 1.0: 2009-06-02 

=over 4

=item - Better use of algorithm, should give more accurate data

=item - New parameters from and to, returning all events in the range

=item - Either date or from and to is now compulsory

=item - Version 0.9 will expire 2009-06-24

=back

=head2 version 0.9: 2008-09-10 

=over 4

=item - Algorithm for the computation is updated.  Should be more accurate.

=item - Version 0.8 will expire 2008-10-01

=back

=head2 version 0.8: 2008-06-24 

=over 4

=item - New product, not in accordance with the Norwegian almanac.

=back

=head1  ASTRONOMICAL EVENT IDENTIFICATION TABLE FOR "direct requests"

=over 8

=item B<eventId  = 100  'REPORT LOCAL INITIAL MOON STATE'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 100 -> if (repval >= 1) "moon is above horison" (repval <=-1) "moon is below"

=item o  repId = 101 -> if (repval >= 1) "lunar polar day" (repval =0) "no lunar polar effect" (repval<=-1) "lunar polar night"

=item o  repId = 102 -> moon phase

=item     B<EVENTID  = 105 : 'REPORT LOCAL VISIBLE MOON IN PERIOD'>

=item     i  eventVal1 = latitude of observer (deg)

=item     i  eventVal2 = longtitude of observer (deg)

=item     i  eventVal3 = height of observer (deg)

=item     o  repId = 105 -> repVal = hours visible moon in period

=item B<eventId  = 110 : 'REPORT LOCAL TC EF MOON POSITION AT TIME INCREMENT'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item i  eventVal4 = time increment (days)

=item o  repId = 110 -> repval = moon elevation (deg)

=item o  repId = 111 -> repval = moon azimuth (deg)

=item o  repId = 112 -> repval = moon range (km)

=item B<eventId  = 120 : 'REPORT LOCAL INITIAL SUN STATE'>
 
=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 120 -> if (repval >= 1) "sun is above horison" (repval <=-1) "sun is below"

=item o  repId = 121 -> if (repval >= 1) "polar day" (repval =0) "no polar effect" (repval<=-1) "polar night"

=item     B<EVENTID  = 125 : 'REPORT LOCAL VISIBLE SUN IN PERIOD'>

=item     i  eventVal1 = latitude of observer (deg)

=item     i  eventVal2 = longtitude of observer (deg)

=item     i  eventVal3 = height of observer (deg)

=item     o  repId = 125 -> repVal = hours visible sun in period

=item B<eventId  = 130 : 'REPORT LOCAL TC EF SUN POSITION AT TIME INCREMENT'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item i  eventVal4 = time increment (days)

=item o  repId = 130 -> repval = sun elevation (deg)

=item o  repId = 131 -> repval = sun azimuth (deg)

=item o  repId = 132 -> repval = sun range (km)
      
=item B<eventId  = 150 : 'DETECT WINTER SOLSTICE'>

=item o  repId = 150 -> event found

=item B<eventId  = 160 : 'DETECT VERNAL EQUINOX'>

=item o  repId = 160 -> event found

=item B<eventId  = 170 : 'DETECT SUMMER SOLSTICE'>

=item o  repId = 170 -> event found

=item B<eventId  = 180 : 'DETECT AUTUMNAL EQUINOX'>

=item o  repId = 180 -> event found

=item B<eventId  = 190 : 'DETECT EARTH IN PERIHELION'>

=item o  repId = 190 -> repval = sun range (km)

=item B<eventId  = 200 : 'DETECT EARTH IN APHELION'>

=item o  repId = 200 -> repval = sun range (km)
      
=item B<eventId  = 210 : 'DETECT NEW MOON (PHASE=0/100)'>

=item o  repId = 210 -> event found

=item B<eventId  = 220 : 'DETECT FIRST QUARTER MOON (PHASE=25)'>

=item o  repId = 220 -> event found

=item B<eventId  = 230 : 'DETECT FULL MOON (PHASE=50)'>

=item o  repId = 230 -> event found

=item B<eventId  = 240 : 'DETECT LAST QUARTER MOON (PHASE=75)'>

=item o  repId = 240 -> event found

=item B<eventId  = 250 : 'DETECT MOON PHASE (0 TO 100)'>

=item i  eventVal1 = target moon phase

=item o  repId = 250 -> event found

=item B<eventId  = 260 : 'DETECT MOON ILLUMINATION MINIMUM'>

=item o  repId = 260 -> event found

=item B<eventId  = 270 : 'DETECT MOON ILLUMINATION MAXIMUM'>

=item o  repId = 270 -> event found

=item B<eventId  = 280 : 'DETECT MOON ILLUMINATION (0 TO 100)'>

=item i  eventVal1 = target moon illumination

=item o  repId = 280 -> event found
      
=item B<eventId  = 300 : 'DETECT MERCURY INFERIOR CONJUNCTION'>

=item o  repId = 300 -> event found

=item B<eventId  = 310 : 'DETECT MERCURY SUPERIOR CONJUNCTION'>

=item o  repId = 310 -> event found

=item B<eventId  = 320 : 'DETECT MERCURY GREATEST WESTERN ELONGATION'>

=item o  repId = 320 -> event found

=item B<eventId  = 330 : 'DETECT MERCURY GREATEST EASTERN ELONGATION'>

=item o  repId = 330 -> event found
      
=item B<eventId  = 340 : 'DETECT VENUS INFERIOR CONJUNCTION'>

=item o  repId = 340 -> event found

=item B<eventId  = 350 : 'DETECT VENUS GREATEST WESTERN ELONGATION'>

=item o  repId = 350 -> event found

=item B<eventId  = 360 : 'DETECT VENUS SUPERIOR CONJUNCTION'>

=item o  repId = 360 -> event found

=item B<eventId  = 370 : 'DETECT VENUS GREATEST EASTERN ELONGATION'>

=item o  repId = 370 -> event found
      
=item B<eventId  = 380 : 'DETECT MARS CONJUNCTION'>

=item o  repId = 380 -> event found

=item B<eventId  = 390 : 'DETECT MARS WESTERN QUADRATURE'>

=item o  repId = 390 -> event found

=item B<eventId  = 400 : 'DETECT MARS OPPOSITION'>

=item o  repId = 400 -> event found

=item B<eventId  = 410 : 'DETECT MARS EASTERN QUADRATURE'>

=item o  repId = 410 -> event found
      
=item B<eventId  = 420 : 'DETECT JUPITER CONJUNCTION'>

=item o  repId = 420 -> event found

=item B<eventId  = 430 : 'DETECT JUPITER WESTERN QUADRATURE'>

=item o  repId = 430 -> event found

=item B<eventId  = 440 : 'DETECT JUPITER OPPOSITION'>

=item o  repId = 440 -> event found

=item B<eventId  = 450 : 'DETECT JUPITER EASTERN QUADRATURE'>

=item o  repId = 450 -> event found
      
=item B<eventId  = 460 : 'DETECT SATURN CONJUNCTION'>

=item o  repId = 460 -> event found

=item B<eventId  = 470 : 'DETECT SATURN WESTERN QUADRATURE'>

=item o  repId = 470 -> event found

=item B<eventId  = 480 : 'DETECT SATURN OPPOSITION'>

=item o  repId = 480 -> event found

=item B<eventId  = 490 : 'DETECT SATURN EASTERN QUADRATURE'>

=item o  repId = 490 -> event found
      
=item B<eventId  = 500 : 'DETECT MERCURY TRANSIT (ANYWHERE ON EARTH)'>

=item o  repId = 500 -> transit starts

=item o  repId = 501 -> transit ends

=item B<eventId  = 520 : 'DETECT VENUS TRANSIT (ANYWHERE ON EARTH)'>

=item o  repId = 520 -> transit starts

=item o  repId = 521 -> transit ends
      
=item B<eventId  = 550 : 'DETECT LUNAR ECLIPSE (MINOCC MAXOCC)'>

=item i  eventVal1 = minimum occultation (0 to 100)

=item i  eventVal2 = maximum occultation (0 to 100)

=item o  repId = 550 -> penumbra contact starts (P1)

=item o  repId = 551 -> umbra contact starts (U1)

=item o  repId = 552 -> total eclipse starts (U2)

=item o  repId = 553 -> repval = maximum occultation

=item o  repId = 554 -> total eclipse stops (U3)

=item o  repId = 555 -> umbra contact stops (U4)

=item o  repId = 556 -> penumbra contact stops (P2)

=item B<eventId  = 560 : 'DETECT LUNAR ECLIPSE -LUNECL[0]'>

=item o  repId = 560 -> penumbra contact starts (P1)

=item o  repId = 561 -> umbra contact starts (U1)

=item o  repId = 562 -> total eclipse starts (U2)

=item o  repId = 563 -> repval = maximum occultation

=item o  repId = 564 -> total eclipse stops (U3)

=item o  repId = 565 -> umbra contact stops (U4)

=item o  repId = 566 -> penumbra contact stops (P2)
      
=item B<eventId  = 600 : 'DETECT LOCAL DIURNAL SUN RISE'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 600 -> event found

=item B<eventId  = 610 : 'DETECT LOCAL DIURNAL SUN SET'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 610 -> event found

=item B<eventId  = 620 : 'DETECT LOCAL DIURNAL MAXIMUM SOLAR ELEVATION'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 620 -> repval = maximum solar elevation (deg)

=item B<eventId  = 630 : 'DETECT LOCAL DIURNAL MINIMUM SOLAR ELEVATION'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 630 -> repval = minimum solar elevation (deg)

=item B<eventId  = 640 : 'DETECT LOCAL DIURNAL CIVIL TWILIGHT START'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 640 -> event found

=item B<eventId  = 650 : 'DETECT LOCAL DIURNAL CIVIL TWILIGHT STOP'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 650 -> event found

=item B<eventId  = 660 : 'DETECT LOCAL DIURNAL NAUTICAL TWILIGHT START'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 660 -> event found

=item B<eventId  = 670 : 'DETECT LOCAL DIURNAL NAUTICAL TWILIGHT STOP'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 670 -> event found

=item B<eventId  = 680 : 'DETECT LOCAL DIURNAL ASTRONOMICAL TWILIGHT START'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 680 -> event found

=item B<eventId  = 690 : 'DETECT LOCAL DIURNAL ASTRONOMICAL TWILIGHT STOP'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 690 -> event found

=item B<eventId  = 700 : 'DETECT LOCAL DIURNAL NIGHT START'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 700 -> event found

=item B<eventId  = 710 : 'DETECT LOCAL DIURNAL NIGHT STOP'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 710 -> event found

=item B<eventId  = 750 : 'DETECT LOCAL DIURNAL SUN AZIMUTH (0=NORTH, 90=EAST)'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item i  eventVal4 = sun azimuth (deg)

=item o  repId = 750 -> event found

=item B<eventId  = 760 : 'DETECT LOCAL DIURNAL APPARENT SOLAR TIME'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item i  eventVal4 = apparent solar time (0 to 24)

=item o  repId = 760 -> event found

=item B<eventId  = 770 : 'DETECT LOCAL DIURNAL APPARENT LUNAR TIME'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item i  eventVal4 = apparent lunar time (0 to 24)

=item o  repId = 770 -> event found

=item B<eventId  = 800 : 'DETECT LOCAL DIURNAL MOON RISE'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 800 -> event found

=item B<eventId  = 810 : 'DETECT LOCAL DIURNAL MOON SET'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 810 -> event found

=item B<eventId  = 820 : 'DETECT LOCAL DIURNAL MAXIMUM MOON ELEVATION'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 820 -> repVal = maximum moon elevation

=item B<eventId  = 830 : 'DETECT LOCAL DIURNAL MINIMUM MOON ELEVATION'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 830 -> repVal = minimum moon elevation

=item B<eventId  = 840 : 'DETECT LOCAL DIURNAL MOON AZIMUTH (0=NORTH, 90=EAST)'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item i  eventVal4 = moon azimuth (deg)

=item o  repId = 840 -> event found
      
=item B<eventId  = 900 : 'DETECT LOCAL POLAR SUN DAY START'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 900 -> event found

=item o  repId = 901 -> previous sun rise

=item B<eventId  = 910 : 'DETECT LOCAL POLAR SUN DAY STOP'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 910 -> event found

=item o  repId = 911 -> next sun set

=item B<eventId  = 920 : 'DETECT LOCAL POLAR SUN NIGHT START'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 920 -> event found

=item o  repId = 921 -> previous sun set

=item B<eventId  = 930 : 'DETECT LOCAL POLAR SUN NIGHT STOP'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 930 -> event found

=item o  repId = 931 -> next sun rise

=item B<eventId  = 940 : 'DETECT LOCAL POLAR LUNAR DAY START'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 940 -> event found

=item o  repId = 941 -> previous moon rise

=item B<eventId  = 950 : 'DETECT LOCAL POLAR LUNAR DAY STOP'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 950 -> event found

=item o  repId = 951 -> next moon set

=item B<eventId  = 960 : 'DETECT LOCAL POLAR LUNAR NIGHT START'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 960 -> event found

=item o  repId = 961 -> previous moon set

=item B<eventId  = 970 : 'DETECT LOCAL POLAR LUNAR NIGHT STOP'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 970 -> event found

=item o  repId = 971 -> next moon rise

=item B<eventId  = 980 : 'DETECT LOCAL SOLAR ECLIPSE (MINOCC MAXOCC)'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item i  eventVal4 = minimum occultation (0 to 100)

=item i  eventVal5 = maximum occultation (0 to 100)

=item o  repId = 980 -> partial solar eclipse starts

=item o  repId = 981 -> total solar eclipse starts

=item o  repId = 982 -> repVal = maximum occultation

=item o  repId = 983 -> total solar eclipse stops

=item o  repId = 984 -> partial solar eclipse stops

=item B<eventId  = 990 : 'DETECT LOCAL SOLAR ECLIPSE'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item o  repId = 990 -> partial solar eclipse starts

=item o  repId = 991 -> total solar eclipse starts

=item o  repId = 992 -> repVal = maximum occultation

=item o  repId = 993 -> total solar eclipse stops

=item o  repId = 994 -> partial solar eclipse stops

=item B<eventId  = 1000 : 'REPORT LOCAL TC EF SOLAR SYSTEM POSITIONS AT TIME INCREMENT'>

=item i  eventVal1 = latitude of observer (deg)

=item i  eventVal2 = longtitude of observer (deg)

=item i  eventVal3 = height of observer (deg)

=item i  eventVal4 = time increment (days)

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

package Metno::WeatherAPI::Product::Sunrise;

use strict;
use warnings;

use base 'Metno::WeatherAPI::Product';

use Metno::WeatherAPI::Config;
use Metno::WeatherAPI::Util qw(read_file);
use Metno::WeatherAPI::Error;

use Metno::Astro::AlmanacAlgorithm qw(:all);

use DateTime;
use XML::LibXML;
use Time::HiRes qw/gettimeofday tv_interval/;

use constant SILENT         => 0;
use constant NEVER_SET      => 10;
use constant NEVER_RISE     => 20;
use constant ERROR          => 30;
use constant OTHER          => 99;

our $license_url;

our %moon_phases = ( 
    0 => 'New moon',
    1 => 'Waxing crescent',
    2 => 'First quarter',
    3 => 'Waxing gibbous',
    4 => 'Full moon',
    5 => 'Waning gibbous',
    6 => 'Third quarter',
    7 => 'Waning crescent',
    );

our $default = "Unique";

our $dbg=0;
our $ver=0;
our $dbgmsg = "";

sub run {
    my ($self, $params) = @_;

    # find out if this is a call to "astroEvent"

    my %info;
    $license_url = config_value('license_url');
    $dbg  = defined $params->{'debug'};
    $ver=0;
    if (defined $params->{'version'}) {
	$ver= $params->{'version'};
    };
    my $keystring=join('|', keys %$params);
    if ($keystring =~m/lat/ && $keystring =~m/lon/) { # lat lon are mandatory when calling riseSetTransit
# call syntax  productroot %]/1.0/?lat=71.0;lon=-69.58;date=2008-06-23
	my $lat  = $params->{'lat'};
	my $lon  = $params->{'lon'};
	my $alt  = $params->{'alt'};
	my $date = $params->{'date'};
	my $from = $params->{'from'};
	my $to   = $params->{'to'};
	
	$date = _create_dt($date) if $date;
	$from = _create_dt($from) if $from;
	$to   = _create_dt($to) if $to;
	
	# Check for sane values
	_verify_parameters($lat, $lon, $date, $from, $to);
	
	if (!$from && !$to) {
	    $from = $date;
	    $to   = $date;
	}
	
	my $tmp_dt = $from->clone;
	while ($tmp_dt <= $to) { 
	    $dbgmsg = "";
	    # Get rise/set info for sun and moon
	    _set_info($lat, $lon, $tmp_dt, SUN, \%info);
	    _set_info($lat, $lon, $tmp_dt, MOON, \%info);
	    
	    $info{$tmp_dt}{'moonphase'} = moon_phase($tmp_dt->year,
						     $tmp_dt->month,
						     $tmp_dt->day);
	    
	    # Maybe we should check that moon rise is for correct date.
	    # It turned out to be messy and not worth it.
	    
	    $tmp_dt->add( days => 1);
	}


    } else {  # call astroEvent if any parameters contain "event"
# call syntax  productroot %]/1.0/?eventStart=2008-06-23t23:00:00Z;eventSearch=1;event1Id=600;event2Id=620;eventVal1=60.;eventVal2=0.;eventVal3=0.
	my %callSeq=(); # the call sequence 
	my $seqFound=0;         # only default so far
	foreach my $par (keys %$params) { # loop over parameters and create input
	    if ($par =~ m/^event(\d*)Start$/ ) {
		$callSeq{$1?$1:$default}{"eventStart"}="$params->{$par}Z";
	    } elsif ($par =~ m/^event(\d*)Search$/ ) {
		$callSeq{$1?$1:$default}{"eventSearch"}=$params->{$par};
	    } elsif ($par =~ m/^event(\d*)Stop$/ ) {
		$callSeq{$1?$1:$default}{"eventStop"}="$params->{$par}Z";
	    } elsif ($par =~ m/^event(\d*)Id$/ ) {
		$callSeq{$1?$1:$default}{"eventId"}=$params->{$par};
	    } elsif ($par =~ m/^event(\d*)Val(\d*)$/ ) {
		$callSeq{$1?$1:$default}{"eventVal"}{$2}=$params->{$par};
	    } elsif ($par =~ m/^debug$/ ) {
	    } else {
		############### report error in input parameter names ($par)
		Metno::WeatherAPI::Error::Parameter->throw(param_name =>  $par,
							   message    => 'Not valid astroEvent key');
	    }
	    if ($par =~ m/^event(\d+)(\w+)$/) {$seqFound=1;} # we have at least one sequence, do not execute default sequence
	}
	# loop over input parameter sets and create reports
#	my $ret="";
#	foreach my $seq (keys %callSeq) {
#	    $ret="$ret|$seq";
#	}
#	Metno::WeatherAPI::Error::Parameter->throw(param_name =>  "test",
#						   message    => $ret);
	foreach my $seq (keys %callSeq) {
	    if ($seqFound && "$seq" eq "$default") {next;} # do not execute default sequence
	    my $sseq="";
	    if ("$seq" ne "$default") {$sseq=$seq;}
	    my $eventStart=undef;
	    my $eventStartJ2000=undef;
	    my $eventSearch=undef;
	    my $eventStop=undef;
	    my $eventStopJ2000=undef;
	    my $eventId=undef;
	    my %eventVal;
	    if ("$seq" ne "$default") { # set default values
		if (defined $callSeq{$default}{"eventStart"}) {$eventStart=$callSeq{$default}{"eventStart"};}
		if (defined $callSeq{$default}{"eventSearch"}) {$eventSearch=$callSeq{$default}{"eventSearch"};}
		if (defined $callSeq{$default}{"eventStop"}) {$eventStop=$callSeq{$default}{"eventStop"};}
		if (defined $callSeq{$default}{"eventId"}) {$eventId=$callSeq{$default}{"eventId"};}
		foreach my $valno (sort keys %{$callSeq{$default}{"eventVal"}}) {
		    $eventVal{$valno}=$callSeq{$default}{"eventVal"}{$valno};
		}
	    }
	    if (defined $callSeq{$seq}{"eventStart"}) {$eventStart=$callSeq{$seq}{"eventStart"};}
	    if (defined $callSeq{$seq}{"eventSearch"}) {$eventSearch=$callSeq{$seq}{"eventSearch"};}
	    if (defined $callSeq{$seq}{"eventStop"}) {$eventStop=$callSeq{$seq}{"eventStop"};}
	    if (defined $callSeq{$seq}{"eventId"}) {$eventId=$callSeq{$seq}{"eventId"};}
	    foreach my $valno (sort keys %{$callSeq{$seq}{"eventVal"}}) {
		$eventVal{$valno}=$callSeq{$seq}{"eventVal"}{$valno};
	    }
	    if ("$eventId" eq "") {
		Metno::WeatherAPI::Error::Parameter->throw(param_name => "event".$sseq."Id",
							   message    => "Missing.");
	    }
	    if ("$eventStart" eq "") {
		Metno::WeatherAPI::Error::Parameter->throw(param_name => "event".$sseq."Start",
							   message    => "Missing.");
	    }
	    if ("$eventSearch" eq "") {
		Metno::WeatherAPI::Error::Parameter->throw(param_name => "event".$sseq."Search",
							   message    => "Missing.");
	    }
	    if ( "$eventSearch" eq "2" && "$eventStop" eq "") {
		Metno::WeatherAPI::Error::Parameter->throw(param_name => "event".$sseq."Stop",
							   message    => "Missing (eventSearch=$eventSearch).");
	    } 
	    # make times
	    if ($eventStart =~ m/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z/) {
		$eventStartJ2000=DTGToJ2000($1,$2,$3,$4,$5,$6);
	    } else {
		############### report error in $eventStart
		Metno::WeatherAPI::Error::Parameter->throw(param_name => "event".$sseq."Start",
							   message    => "Unable to extract date from '$eventStart'.");
	    }
	    if ("$eventSearch" ne "" && $eventSearch==2 && $eventStop =~ m/^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)Z/) {
		$eventStopJ2000=DTGToJ2000($1,$2,$3,$4,$5,$6);
	    } elsif ("$eventSearch" ne "" && ($eventSearch==-1 || $eventSearch==0 || $eventSearch==+1)) {
	    } else {
		############### report error in $eventStop $eventSearch
		my $msg="Mismatch";
		if ("$eventStart"ne"") {$msg=$msg." Start time:$eventStart";}
		if ("$eventStop"ne"") {$msg=$msg." Stop time:$eventStop";}
		if ("$eventSearch"ne"") {$msg=$msg." Search code:$eventSearch";}
		Metno::WeatherAPI::Error::Parameter->throw(param_name =>  "event".$sseq."Search",
							   message    => $msg);
	    }
	    # make eventVal array, based on ascending order of input eventVal
	    my @eventVal=();
	    foreach my $valno (sort keys %eventVal) {
		if ("$eventVal{$valno}"ne"") { push (@eventVal, $eventVal{$valno}); }
	    }
	    # call astroEvent
	    my $irc;
	    my $nrep;
	    my $rep2000;
	    my $repId;
	    my $repVal;
	    my $rep250;
#	    my $msg="$eventStartJ2000,$eventSearch,$eventStopJ2000,$eventId,@eventVal,$#eventVal";
#	    Metno::WeatherAPI::Error::Internal->throw(message    => "astroEvent call: $msg\n");
	    my $start_time = [gettimeofday];
 	    eval {
		if ("$eventSearch" eq "2") {      # use $eventStop
		    ($irc,$nrep,$rep2000,$repId,$repVal,$rep250) = astroEvent($eventStartJ2000,$eventSearch,$eventStopJ2000,$eventId,\@eventVal,0,0);
		} else {
		    $eventStop="";
		    ($irc,$nrep,$rep2000,$repId,$repVal,$rep250) = astroEvent($eventStartJ2000,$eventSearch,$eventId,\@eventVal,0,0);
		}
	    };
	    if ( $@ ) { # astroEvent croaked...
		Metno::WeatherAPI::Error::Internal->throw(message    => "astroEvent: Croak message: $@\n");
	    }
	    $info{$seq}{'Cost'}=sprintf("%.1fms", 1000*tv_interval($start_time));
	    my $total_time = tv_interval($start_time);
 	    # store output
	    $info{'astroEvent'}=1; # the info hash contains results from direct calls to astroEvent
	    if ($irc == 0) {
		if ("$eventStart" ne "") {$info{$seq}{'eventStart'}=$eventStart;}
		if ("$eventSearch" ne "") {$info{$seq}{'eventSearch'}=$eventSearch;}
		if ("$eventStop" ne "") {$info{$seq}{'eventStop'}=$eventStop;}
		if ("$eventId" ne "") {$info{$seq}{'eventId'}=$eventId;}
		my $eventValSize=scalar(@eventVal);
		for (my $ii=0; $ii < $eventValSize; $ii++) {
		    $info{$seq}{'eventVal'}{$ii}=$eventVal[$ii];
		}
		$info{$seq}{'nrep'}=$nrep; # number of reports
		for (my $ii=0; $ii < $nrep; $ii++) {
		    $info{$seq}{'rep2000'}{$ii}=$$rep2000[$ii];
		    $info{$seq}{'repId'}{$ii}=$$repId[$ii];
		    $info{$seq}{'repVal'}{$ii}=$$repVal[$ii];
		    $info{$seq}{'rep250'}{$ii}=$$rep250[$ii];
		}
	    } else {
		############### report error in irc
		Metno::WeatherAPI::Error::Parameter->throw(param_name => 'astroEvent',
							   message    => 'Error return from astroEvent. $irc');
	    }
	}
    }
    my $expire = DateTime->now;
    $expire->add( minutes => 60*2 );
    $expire->add( minutes => int( rand(180) ) );
    
    my $exp = $expire->strftime('%a, %d %b %Y %T GMT');
    
    # and in the end, return XML:
    my $xml = $self->create_xml(\%info);
    
    return ($xml, { 'status'  => 'OK',
		    'expires' => $exp,
		    'type'    => 'text/xml',}
	);
}

sub _local_noon {
    my ($dt, $lon) = @_;
    
    my $local_noon = abs(($lon/15) + $lon/360);
    my $sign = ( $lon > 0 ) ? -1 : +1;
    
    my $hour = int($local_noon);
    my $min  = int(($local_noon - $hour) * 60);
    my $tmp  = ($local_noon - $hour) * 60;
    my $sec  = int(($tmp - $min)*60);
    
    $dt->add(   
	hours => $sign*$hour,
	minutes => $sign*$min,
	seconds => $sign*$sec
	);    
}

sub _create_dt {
    my ($dt) = @_;
    
    # Some insist of doing this:  
    # Argument "\x{662}\x{660}..." isn't numeric in numeric eq (==) 
    # This fails because we use "use utf8;".  Which we really don't need
#    $dt =~ tr/\x{660}-\x{669}/0-9/;

    if ($dt =~ m{\A (\d{4})-(\d{2})-(\d{2}) \z}x ) {	
	if ($1 == 0 && $2 == 0 && $3 == 0) {
	    my $msg = q{Year 0 does not exist, $dt!};
	    Metno::WeatherAPI::Error::Parameter->throw(param_name => 'date',
						       message    => $msg);
	}
	
	$dt = DateTime->new(year  => $1,
			    month => $2,
			    day   => $3,
			    hour  => 12,
			    minute => 0,
			    second => 0,
			    time_zone => 'UTC');
	
	
    }
    
    return $dt;
}

sub extract_date {
    my ($tst) = @_;
    
    my ($date) = ( $tst =~ m{(\d{4}-\d{2}-\d{2})T} );
    
    return $date;
}

# Compute rise and set info for $object.
sub _set_info {
    my ($lat, $lon, $date, $object, $info) = @_;
    # We want to adjust for local noon in what we send to the algorithm
    my $jd = $date->clone;
#    if ($object == MOON) {
    _local_noon( $jd, $lon );
#    }
    my $julianday = $jd->jd;
    my ($rise, $set, $transit, $visible, $riseN, $setN);
    # Get the values, all time answers are given as julian days:
    my $start_time = [gettimeofday];

#    my ($yy,$mm,$dd,$hh,$mi,$sec)=($jd->year,$jd->month,$jd->day,$jd->hour,$jd->minute,$jd->second);
#    my $date=sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ",$yy,$mm,$dd,$hh,$mi,$sec);
#    Metno::WeatherAPI::Error::Internal->throw(message    => "riseSetTransit: Time:$date\n");


    eval {
	($rise, $set, $transit, $visible, $riseN, $setN) 
	    = riseSetTransit($lat, $lon, $julianday, $object);
    };
    if ($@) {
	Metno::WeatherAPI::Error::Internal->throw(message    => "riseSetTransit: Croak message: $@\n");
    };
    $dbgmsg=$dbgmsg . " riseSetTransit($lat, $lon, $julianday, $object)=($rise, $set, $transit, $visible, $riseN, $setN)";
    $info->{$date}{$lat}{$lon}{$object}{'Cost'} = sprintf("%.1fms", 1000*tv_interval($start_time));
    # Check for sane values before we try to convert to epoch
    $info->{$date}{$lat}{$lon}{$object}{'visible'} = sprintf("%is", $visible);

    if ($ver == 0) {
# fall back to old format...#################
	$riseN=-1;
	$setN=-1;
	if (($rise == -1 && $set != -1)||($rise != -1 && $set == -1)) {
	    $rise=-1;
	    $set=-1;
	    if ($visible > 12*60*60) {
		$visible=24*60*60;
	    } else {
		$visible=0;
	    }
	}
    };
#############################################
    if ("$visible"eq"") {
	$info->{$date}{$lat}{$lon}{$object}{'event'} = ERROR;
    } elsif ($visible==0) {
	$info->{$date}{$lat}{$lon}{$object}{'event'} = NEVER_RISE;
    } elsif ($visible == 24*60*60) {
	$info->{$date}{$lat}{$lon}{$object}{'event'} = NEVER_SET;
    } else  {
	$info->{$date}{$lat}{$lon}{$object}{'event'} = OTHER;
    }
    # store rise and set info as DateTime-objects:
    if ($rise != -1) {
	$info->{$date}{$lat}{$lon}{$object}{'rise'} 
	= DateTime->from_epoch( epoch => julianDay2epoch($rise));
    }
    if ($set != -1) {
	$info->{$date}{$lat}{$lon}{$object}{'set'}  
	= DateTime->from_epoch( epoch => julianDay2epoch($set));
    }
    if ($riseN != -1) {
	$info->{$date}{$lat}{$lon}{$object}{'riseNext'} 
	= DateTime->from_epoch( epoch => julianDay2epoch($riseN));
    }
    if ($setN != -1) {
	$info->{$date}{$lat}{$lon}{$object}{'setNext'}  
	= DateTime->from_epoch( epoch => julianDay2epoch($setN));
    }
    # Compute the transit if object is visible at all:
    if ("$visible"ne"" && $visible > 0) {
	my ($dir_deg, $altitude) 
	    = azimuthAltitude($lat, $lon, $transit, $object);
	$info->{$date}{$lat}{$lon}{$object}{'transit'}
	    =  DateTime->from_epoch( epoch => julianDay2epoch($transit));
	$info->{$date}{$lat}{$lon}{$object}{'altitude'} = $altitude;
    }
#    if ($object == MOON) {
#	my $msg="Rise:$rise  Set:$set  Transit:$transit Visible:$visible\n";
#	Metno::WeatherAPI::Error::Internal->throw(message    => "riseSetTransit: $msg\n");
#    }
    return;
}

sub _verify_parameters {
    my ($lat, $lon, $date, $from, $to) = @_;

    if (!$from && !$to && !$date) {
	my $msg = q{Either from/to or date must be given.};
	Metno::WeatherAPI::Error::Parameter->throw(param_name => 'date',
						 message    => $msg);
    }
    
    if ( ($from && !$to) || (!$from && $to) ) {
      my $msg = q{The parameters from and to must be used together};
      Metno::WeatherAPI::Error::Parameter->throw(param_name => 'from',
						 message    => $msg);
    }

    # We want time as DateTime-objects:
    if (!$date && !$from && !$to) {
	$date = DateTime->now();
	$date->set( hour => 12,
		    minute => 0,
		    second => 0);
	$date->set_time_zone('UTC');	
    }
    
    # Do some basic checking of the coordinates:
    if ($lat < -90 || $lat > 90) {
	Metno::WeatherAPI::Error::Parameter->throw(param_name => 'lat',
						   message    => 'Invalid latitude');
    }
    
    if ($lon < -180 || $lon > 180) {
	Metno::WeatherAPI::Error::Parameter->throw(param_name => 'lon',
						   message    => 'Invalid longitude');
	  	  
      }

    # Because of the use of epoch, we can't go higher than 2038-01-18
    my $epoch_dt = DateTime->new(year => 2038,
				 month => 1,
				 day => 18);

    my $day_in_sec = 24*60*60;
    if ($from && $to) {
	my $period_time = $to->epoch - $from->epoch;
	if ($period_time > 30*$day_in_sec) {
	    my $msg = q{Maximum 30 days between from and to};
	    Metno::WeatherAPI::Error::Parameter->throw(param_name => 'from',
						 message    => $msg);
	}
    }

    if ($date > $epoch_dt ) {
	Metno::WeatherAPI::Error::Outsidetimerange
	    ->throw(asked_for   => $date->year,
		    valid_start => 0,
		    valid_end   => $epoch_dt->year);	  
      }
    
    return $date;
}

# This isn't weatherdata!
# So I call it astrodata.. Create element so that we easily can put in
# moon phase later on.
sub create_xml {
    my ($self, $info) = @_;

    my $doc = XML::LibXML::Document->new('1.0', 'utf-8');
    $doc->setEncoding('utf-8');
    
    my $root = $doc->createElement('astrodata');
    $doc->setDocumentElement($root);

    $root->setAttribute('xmlns:xsi',
                        'http://www.w3.org/2001/XMLSchema-instance');

    $root->setAttribute('xsi:noNamespaceSchemaLocation',
                        sprintf("%s/sunrise/%s/schema",
                              config_value('webroot_url'),
                              $self->{'version'} ));

    my $meta = $doc->createElement('meta');
    $meta->setAttribute('licenseurl', $license_url);
    $root->appendChild($meta);
    if (defined $info->{'astroEvent'}) { # the info hash contains results from direct calls to astroEvent
	foreach my $seq (sort keys %$info) {
	    if ($seq eq 'astroEvent') {next;}
	    my $event=$doc->createElement('Event');
	    my $seqno=$event->setAttribute('Seq', $seq);
	    if (defined $info->{$seq}{'eventId'}) {$event->setAttribute('Id', $info->{$seq}{'eventId'});}
	    if (defined $info->{$seq}{'eventStart'}) {$event->setAttribute('Start', $info->{$seq}{'eventStart'});}
	    if (defined $info->{$seq}{'eventSearch'}) {$event->setAttribute('Search', $info->{$seq}{'eventSearch'});}
	    if (defined $info->{$seq}{'eventStop'}) {$event->setAttribute('Stop', $info->{$seq}{'eventStop'});}
	    for (my $ii=1; $ii <= 6; $ii++) {
		my $valstr="Val$ii";
		if (defined $info->{$seq}{'eventVal'}{$ii-1}) {$event->setAttribute($valstr, $info->{$seq}{'eventVal'}{$ii-1});}
	    }
	    my $nrep=$info->{$seq}{'nrep'};
	    my $repno=$event->setAttribute('reports', $nrep);
	    if ($dbg && defined $info->{$seq}{'Cost'}) {$event->setAttribute('cost', $info->{$seq}{'Cost'});}
	    for (my $ii=0; $ii < $nrep; $ii++) {
		my $report=$doc->createElement('Report');
		$report->setAttribute('no',$ii+1);
		my ($yy,$mm,$dd,$hh,$mi,$sec)=J2000ToDTG($info->{$seq}{'rep2000'}{$ii});
		my $date=sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ",$yy,$mm,$dd,$hh,$mi,$sec);
		$report->setAttribute('time',$date);
		$report->setAttribute('repId',$info->{$seq}{'repId'}{$ii});
		if ("$info->{$seq}{'repVal'}{$ii}" ne "-99999") {
		    $report->setAttribute('repVal',$info->{$seq}{'repVal'}{$ii});
		}
		$report->setAttribute('hint',$info->{$seq}{'rep250'}{$ii});
		$event->appendChild($report);
	    }
	    $root->appendChild($event);
	}
    } else {
	foreach my $date (sort keys %$info) {
	    my $time = $doc->createElement('time');
	    $time->setAttribute('date', extract_date($date));
	    
	    # Moonphase is not dependent of place:
	    my $moonphase =	$info->{$date}{'moonphase'};
	    
	    foreach my $lat (keys %{$info->{$date}}) {
		next if $lat eq q[moonphase];
		foreach my $lon (keys %{$info->{$date}{$lat}}) {
		    my $location = $doc->createElement('location');
		    $location->setAttribute('latitude', $lat);
		    $location->setAttribute('longitude', $lon);
		    
		    my $sun_object = SUN;
		    my $sun_event = $info->{$date}{$lat}{$lon}{$sun_object}{'event'};		
		    my $sun     = $doc->createElement('sun');
		    my $sunrise = $info->{$date}{$lat}{$lon}{$sun_object}{'rise'};
		    my $sunset  = $info->{$date}{$lat}{$lon}{$sun_object}{'set'};
		    my $sunriseNext = $info->{$date}{$lat}{$lon}{$sun_object}{'riseNext'};
		    my $sunsetNext  = $info->{$date}{$lat}{$lon}{$sun_object}{'setNext'};
		    my $sun_trans = $info->{$date}{$lat}{$lon}{$sun_object}{'transit'};
		    my $altitude = $info->{$date}{$lat}{$lon}{$sun_object}{'altitude'};
		    # Add attributes according to the parameters:
		    if ($sun_event == ERROR) {
			my $s_error     = $doc->createElement('error');
			$s_error->setAttribute('rise', 'Failed to compute rise time');
			$sun->appendChild($s_error);
			my $r_error     = $doc->createElement('error');
			
			$r_error->setAttribute('set', 'Failed to compute set time');
			$sun->appendChild($r_error);
		    } elsif ($sun_event == NEVER_SET) {
			$sun->setAttribute('never_set', 'true');
			if (defined $altitude && $ver!=0) {
                            # Add transit-info:
                            # my $noon->setAttribute('time', $sun_trans->iso8601 . 'Z');
			    my $noon = $doc->createElement('noon');
			    $noon->setAttribute('altitude', sprintf("%.3f", $altitude));
			    $sun->appendChild($noon);
			}
		    } elsif ($sun_event == NEVER_RISE) {
			$sun->setAttribute('never_rise', 'true');
		    } else {
			if (defined $sunrise ) {		    
			    $sun->setAttribute('rise', $sunrise->iso8601 . q[Z]);
			}
			if (defined $sunset ) {		    
			    $sun->setAttribute('set',  $sunset->iso8601 . q[Z]);
			}
			if (defined $sunriseNext ) {		    
			    $sun->setAttribute('rise_next', $sunriseNext->iso8601 . q[Z]);
			}
			if (defined $sunsetNext ) {		    
			    $sun->setAttribute('set_next',  $sunsetNext->iso8601 . q[Z]);
			}
			if (defined $altitude) {
# Add transit-info:
#		my $noon->setAttribute('time', $sun_trans->iso8601 . 'Z');
			    my $noon = $doc->createElement('noon');
			    if ($ver == 0) {
				$noon->setAttribute('altitude', sprintf("%.13f", $altitude));
			    } else {
				$noon->setAttribute('altitude', sprintf("%.3f", $altitude));
			    };
			    $sun->appendChild($noon);
			}
		    }
		    if ($dbg) {
			if (defined $info->{$date}{$lat}{$lon}{$sun_object}{'Cost'}) {$sun->setAttribute('cost', $info->{$date}{$lat}{$lon}{$sun_object}{'Cost'});}
			if (defined $info->{$date}{$lat}{$lon}{$sun_object}{'visible'}) {$sun->setAttribute('visible', $info->{$date}{$lat}{$lon}{$sun_object}{'visible'});}
		    }
		    $location->appendChild($sun);
		    
		    ## ..and the moon info
		    my $moon_object = MOON;
		    my $moon_event = $info->{$date}{$lat}{$lon}{$moon_object}{'event'};
		    my $moon = $doc->createElement('moon');
		    $moon->setAttribute('phase', $moon_phases{$moonphase});
		    my $moonrise = $info->{$date}{$lat}{$lon}{$moon_object}{'rise'};
		    my $moonset  = $info->{$date}{$lat}{$lon}{$moon_object}{'set'};
		    my $moonriseNext = $info->{$date}{$lat}{$lon}{$moon_object}{'riseNext'};
		    my $moonsetNext  = $info->{$date}{$lat}{$lon}{$moon_object}{'setNext'};		    
		    # Add attributes according to the parameters:
		    if ($moon_event==ERROR) {
			my $s_error     = $doc->createElement('error');
			$s_error->setAttribute('rise', 'Failed to compute rise time');
			
			$moon->appendChild($s_error);
			my $r_error     = $doc->createElement('error');
			
			$r_error->setAttribute('set', 'Failed to compute set time');
			$moon->appendChild($r_error);
		    } elsif ($moon_event == NEVER_SET) {
			if ($ver==0) {
			    $moon->setAttribute('never_rise', 'true');
			} else {
			    $moon->setAttribute('never_set', 'true');
			};
		    } elsif ($moon_event == NEVER_RISE) {
			$moon->setAttribute('never_rise', 'true');
		    } else {
			if ($moonrise) {
			    $moon->setAttribute('rise', $moonrise->iso8601 . q[Z]);
			}
			if ($moonset) {
			    $moon->setAttribute('set',  $moonset->iso8601 . q[Z]);
			} 
			if ($moonriseNext) {
			    $moon->setAttribute('rise_next', $moonriseNext->iso8601 . q[Z]);
			}
			if ($moonsetNext) {
			    $moon->setAttribute('set_next',  $moonsetNext->iso8601 . q[Z]);
			} 
		    }
		    if ($dbg) {
			if (defined $info->{$date}{$lat}{$lon}{$moon_object}{'Cost'}) {$moon->setAttribute('cost', $info->{$date}{$lat}{$lon}{$moon_object}{'Cost'});}
			if (defined $info->{$date}{$lat}{$lon}{$moon_object}{'visible'}) {$moon->setAttribute('visible', $info->{$date}{$lat}{$lon}{$moon_object}{'visible'});}
		    }
		    $location->appendChild($moon);
		    $time->appendChild($location);
		}
	    }
	    if ($dbg) {$time->setAttribute('DBGMSG', $dbgmsg);}
	    $root->appendChild($time);
	}
    }    
    my $xml_content = $doc->toString(2);
    return $xml_content;
}

# Based on http://voidware.com/moon_phase.htm
#
#  calculates the moon phase (0-7), accurate to 1 segment.
#  0 = > new moon.
#  4 => full moon.
sub moon_phase {
    my ($year, $month, $day) = @_;

    my ($c, $e, $jd, $b);
    
    if ($month < 3) {
        $year--;
        $month += 12;
    }
    $month++;
    
    $c = 365.25*$year;
    $e = 30.6*$month;
    $jd = $c+$e+$day-694039.09; # jd is total days elapsed
    
    $jd /= 29.53;  # divide by the moon cycle (29.53 days)
    $b = int($jd); # int(jd) -> b, take integer part of jd
    $jd -= $b;     # subtract integer part to leave fractional part of original jd

    $b = $jd*8 + 0.5;   # scale fraction from 0-8 and round by adding 0.5
    $b = $b & 7;        # 0 and 8 are the same so turn 8 into 0
    return int($b);
}


# Which parameter is used.
# Remember to minimise use of default parameters.
sub parameters {
  my ($self) = @_;

  return {
	'debug'  => ':i',
	'version'  => ':i',
	'lat'  => ':f',
	'lon'  => ':f',
	'date' => ':d',
	'alt'  => ':f',
	'from' => ':d',
	'to'   => ':d',
        'eventStart' => ':t',
        'event1Start' => ':t',
        'event2Start' => ':t',
        'event3Start' => ':t',
        'event4Start' => ':t',
        'event5Start' => ':t',
        'event6Start' => ':t',
        'event7Start' => ':t',
        'event8Start' => ':t',
        'event9Start' => ':t',
        'event10Start' => ':t',
        'event11Start' => ':t',
        'event12Start' => ':t',
        'event13Start' => ':t',
        'event14Start' => ':t',
        'event15Start' => ':t',
        'event16Start' => ':t',
        'event17Start' => ':t',
        'event18Start' => ':t',
        'event19Start' => ':t',
        'event20Start' => ':t',
        'eventSearch' => ':i',
        'event1Search' => ':i',
        'event2Search' => ':i',
        'event3Search' => ':i',
        'event4Search' => ':i',
        'event5Search' => ':i',
        'event6Search' => ':i',
        'event7Search' => ':i',
        'event8Search' => ':i',
        'event9Search' => ':i',
        'event10Search' => ':i',
        'event11Search' => ':i',
        'event12Search' => ':i',
        'event13Search' => ':i',
        'event14Search' => ':i',
        'event15Search' => ':i',
        'event16Search' => ':i',
        'event17Search' => ':i',
        'event18Search' => ':i',
        'event19Search' => ':i',
        'event20Search' => ':i',
        'eventStop' => ':t',
        'event1Stop' => ':t',
        'event2Stop' => ':t',
        'event3Stop' => ':t',
        'event4Stop' => ':t',
        'event5Stop' => ':t',
        'event6Stop' => ':t',
        'event7Stop' => ':t',
        'event8Stop' => ':t',
        'event9Stop' => ':t',
        'event10Stop' => ':t',
        'event11Stop' => ':t',
        'event12Stop' => ':t',
        'event13Stop' => ':t',
        'event14Stop' => ':t',
        'event15Stop' => ':t',
        'event16Stop' => ':t',
        'event17Stop' => ':t',
        'event18Stop' => ':t',
        'event19Stop' => ':t',
        'event20Stop' => ':t',
        'eventId' => ':i',
        'event1Id' => ':i',
        'event2Id' => ':i',
        'event3Id' => ':i',
        'event4Id' => ':i',
        'event5Id' => ':i',
        'event6Id' => ':i',
        'event7Id' => ':i',
        'event8Id' => ':i',
        'event9Id' => ':i',
        'event10Id' => ':i',
        'event11Id' => ':i',
        'event12Id' => ':i',
        'event13Id' => ':i',
        'event14Id' => ':i',
        'event15Id' => ':i',
        'event16Id' => ':i',
        'event17Id' => ':i',
        'event18Id' => ':i',
        'event19Id' => ':i',
        'event20Id' => ':i',
        'eventVal1' => ':f',
        'eventVal2' => ':f',
        'eventVal3' => ':f',
        'eventVal4' => ':f',
        'eventVal5' => ':f',
        'event1Val1' => ':f',
        'event1Val2' => ':f',
        'event1Val3' => ':f',
        'event1Val4' => ':f',
        'event1Val5' => ':f',
        'event2Val1' => ':f',
        'event2Val2' => ':f',
        'event2Val3' => ':f',
        'event2Val4' => ':f',
        'event2Val5' => ':f',
        'event3Val1' => ':f',
        'event3Val2' => ':f',
        'event3Val3' => ':f',
        'event3Val4' => ':f',
        'event3Val5' => ':f',
        'event4Val1' => ':f',
        'event4Val2' => ':f',
        'event4Val3' => ':f',
        'event4Val4' => ':f',
        'event4Val5' => ':f',
        'event5Val1' => ':f',
        'event5Val2' => ':f',
        'event5Val3' => ':f',
        'event5Val4' => ':f',
        'event5Val5' => ':f',
        'event6Val1' => ':f',
        'event6Val2' => ':f',
        'event6Val3' => ':f',
        'event6Val4' => ':f',
        'event6Val5' => ':f',
        'event7Val1' => ':f',
        'event7Val2' => ':f',
        'event7Val3' => ':f',
        'event7Val4' => ':f',
        'event7Val5' => ':f',
        'event8Val1' => ':f',
        'event8Val2' => ':f',
        'event8Val3' => ':f',
        'event8Val4' => ':f',
        'event8Val5' => ':f',
        'event9Val1' => ':f',
        'event9Val2' => ':f',
        'event9Val3' => ':f',
        'event9Val4' => ':f',
        'event9Val5' => ':f',
        'event10Val1' => ':f',
        'event10Val2' => ':f',
        'event10Val3' => ':f',
        'event10Val4' => ':f',
        'event10Val5' => ':f',
        'event11Val1' => ':f',
        'event11Val2' => ':f',
        'event11Val3' => ':f',
        'event11Val4' => ':f',
        'event11Val5' => ':f',
        'event12Val1' => ':f',
        'event12Val2' => ':f',
        'event12Val3' => ':f',
        'event12Val4' => ':f',
        'event12Val5' => ':f',
        'event13Val1' => ':f',
        'event13Val2' => ':f',
        'event13Val3' => ':f',
        'event13Val4' => ':f',
        'event13Val5' => ':f',
        'event14Val1' => ':f',
        'event14Val2' => ':f',
        'event14Val3' => ':f',
        'event14Val4' => ':f',
        'event14Val5' => ':f',
        'event15Val1' => ':f',
        'event15Val2' => ':f',
        'event15Val3' => ':f',
        'event15Val4' => ':f',
        'event15Val5' => ':f',
        'event16Val1' => ':f',
        'event16Val2' => ':f',
        'event16Val3' => ':f',
        'event16Val4' => ':f',
        'event16Val5' => ':f',
        'event17Val1' => ':f',
        'event17Val2' => ':f',
        'event17Val3' => ':f',
        'event17Val4' => ':f',
        'event17Val5' => ':f',
        'event18Val1' => ':f',
        'event18Val2' => ':f',
        'event18Val3' => ':f',
        'event18Val4' => ':f',
        'event18Val5' => ':f',
        'event19Val1' => ':f',
        'event19Val2' => ':f',
        'event19Val3' => ':f',
        'event19Val4' => ':f',
        'event19Val5' => ':f',
        'event20Val1' => ':f',
        'event20Val2' => ':f',
        'event20Val3' => ':f',
        'event20Val4' => ':f',
        'event20Val5' => ':f',
   };
}

# Versions, past, present and future.  Date is which time that version
# stops working
sub versions {
    return {
	'0.8' => '2008-10-01',
	'0.9' => '2009-06-24',
	'1.0' => 'CURRENT',
    };
}

# Any schema related to this product?
sub schema {
  my ($self) = @_;

  return ('astrodata', 1.2);
}

1;
