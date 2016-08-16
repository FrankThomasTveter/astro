#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "astroEvent.h"

#define JD2000 2451544.5 
#define true 1
#define false 0

MODULE = Metno::Astro::AlmanacAlgorithm		PACKAGE = Metno::Astro::AlmanacAlgorithm		

void
jplephOpen(char* path)
  PREINIT:
    int status;
    char *crc250;
    int slen;
    int clen;
  CODE:
        slen = strlen(path);
        crc250 = calloc(sizeof(char), 251);
        jplephopen_(path, crc250, &status, &slen, &clen);
        if (status != 0){croak("Error %d jplephOpen: '%s' '%s'", status, path,crc250);}
	free (crc250);

void
jplephClose()
  CODE:
        jplephclose_();        


void
J2000ToDTG(double j2000, OUTLIST int year, OUTLIST int month, OUTLIST int mday, OUTLIST int hour, OUTLIST int min, OUTLIST double secs)
  CODE:
        dj2000_(&j2000, &year, &month, &mday, &hour, &min, &secs);

void
DTGToJ2000(int year, int month, int mday, int hour, int min, double secs, OUTLIST double j2000)
  CODE:
        jd2000_(&j2000, &year, &month, &mday, &hour, &min, &secs );

void
aa_astroEvent(double tstart2000, int searchCode, double tend2000, int eventId, int neventVal, AV* eventValin, int secdec, int irc)
  PREINIT:
      double* eventVal;
      int maxrep = 100;
      int nrep;
      double* rep2000;
      int* repId;
      double* repVal;
      char *rep250;
      char *crc250;
      int ii;
      int lenr=250;
  PPCODE:
    /* allocate and assign input array */
    neventVal=av_len(eventValin)+1;
    if (neventVal<=0) { /* make sure at least one element exists */
     eventVal = malloc(sizeof(double));
     neventVal=0;
     eventVal[0]=0.;
    } else {
     eventVal = malloc(sizeof(double)*neventVal);
     for (ii=0; ii < neventVal; ii++ ) {
       SV** elem = av_fetch(eventValin, ii, 0);
       if  (elem != NULL) eventVal[ ii ] = SvNV(*elem);
     }
    }
    /* allocate output arrays */
    rep2000 = malloc(sizeof(double)*maxrep);
    repId = malloc(sizeof(int)*maxrep);
    repVal = malloc(sizeof(double)*maxrep);
    rep250 = calloc(sizeof(char), lenr*maxrep);
    crc250 = calloc(sizeof(char), lenr);
    nrep=0;
    /* call fortran subroutine */
/*printf("  EV(0)= %d %f", neventVal,eventVal[0]);*/
    astroevent_(&tstart2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc);
    if (irc != 0 ) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//      free(crc250);
      croak("aa_astroEvent Error return from astroevent (irc=%d, nrep=%d eventId=%d '%s')", irc, nrep, eventId,crc250); 
    }
    /* make return stack */
    if (irc == 0) {
       EXTEND(SP, 2+4*nrep);
       PUSHs(sv_2mortal(newSViv(irc)));
       PUSHs(sv_2mortal(newSViv(nrep)));
       for (ii=0; ii < nrep ; ii++ ) {
          PUSHs(sv_2mortal(newSVnv(rep2000[ii])));
       }
       for (ii=0; ii < nrep ; ii++ ) {
          PUSHs(sv_2mortal(newSViv(repId[ii])));
       }
       for (ii=0; ii < nrep ; ii++ ) {
          PUSHs(sv_2mortal(newSVnv(repVal[ii])));
       }
       for (ii=0; ii < nrep ; ii++ ) {
          PUSHs(sv_2mortal(newSVpv(&rep250[ii*250],250)));
       }
    };
    free(eventVal);
    free(rep2000);
    free(repId);
    free(repVal);
    free(rep250);
    free(crc250);

void
julianDay2calendar(double julianDay, OUTLIST int year, OUTLIST int month, OUTLIST int mday, OUTLIST int hour, OUTLIST int min, OUTLIST double secs)
  CODE:
        julianDay -= JD2000; /* convert to julian day 2000 (2000 as base) */
        dj2000_(&julianDay, &year, &month, &mday, &hour, &min, &secs);

void
calendar2julianDay(int year, int month, int mday, int hour, int min, double secs, OUTLIST double julianDay)
  CODE:
        jd2000_(&julianDay, &year, &month, &mday, &hour, &min, &secs );
        julianDay += JD2000; /* convert from julian day 2000 (2000 as base) */

void
aa_calcSetRise(double longitude, double latitude, double height, double temperature, double pressure, int jdflag, double deltaT, double julianDay, int planetNo, OUTLIST double dateTransit, OUTLIST double dateSet, OUTLIST double dateRise, OUTLIST double dateSetN, OUTLIST double dateRiseN, OUTLIST double visibleHours)
  PREINIT:
      double tstart2000;
      int searchCode=999;
      double tend2000;
      int eventId;
      int neventVal;
      double* eventVal;
      int maxrep, nrep;
      double* rep2000;
      int* repId;
      double* repVal;
      char *rep250;
      int secdec = 0;
      int irc = 0;
      int up;
      int upend;
      int polar;
      double dateSunTransitPrev,dateSunTransitNext;
      int lSet;
      int lRise;
      int lSetN;
      int lRiseN;
      char *crc250;
      double tz,me2000;
      int ii;
  CODE:
    /* returns next rise, set and transit times */
    /* allocate input arrays */
    neventVal=6;
    eventVal = malloc(sizeof(double)*neventVal);
    /* allocate output arrays */
    maxrep = 10;
    rep2000 = malloc(sizeof(double)*maxrep);
    repId = malloc(sizeof(int)*maxrep);
    repVal = malloc(sizeof(double)*maxrep);
    rep250 = calloc(sizeof(char), 251*maxrep);
    crc250 = calloc(sizeof(char), 251);
/** initialise */
    /* set start time */
    tstart2000=julianDay-JD2000;
    tend2000=tstart2000;
/** get closest sun transit time */
    eventId= 760; /* sun transit when apparent solar time = 12 */ 
    neventVal=4;
    eventVal[0]=latitude;
    eventVal[1]=longitude;
    eventVal[2]=height;
    eventVal[3]=12.0; /* transit at noon, solar time = 12 */
    searchCode=0; // find prev and next event
    secdec = 0;
    nrep = 0;
    irc = 0;
    astroevent_(&tstart2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc);
    if (irc != 0 || nrep != 2) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//     free(crc250);
      croak("aa_calcSetRise Error return from astroevent (irc=%d, nrep=%d, eventId=%d, '%s')", irc, nrep, eventId,crc250); 
    }
    dateSunTransitPrev = rep2000[0];
    dateSunTransitNext = rep2000[1];
//   croak("aa_calcSetRise Next '%s'", rep250); 
    if (fabs(dateSunTransitPrev-tstart2000) > fabs(dateSunTransitNext-tstart2000)) { // closest maxElevation
      tstart2000=dateSunTransitNext;
//      croak("aa_calcSetRise Next '%s'", rep250); 
    } else {
      tstart2000=dateSunTransitPrev;
//      croak("aa_calcSetRise Prev '%s'", rep250); 
    }
/** estimate time zone */
    tz=(floor(0.5+(longitude/15.)))/24.;
/** estimate start of date */
    tstart2000=floor(tstart2000+tz)-tz;
    tend2000=tstart2000+1.0;
/** get maximum elevation */
    switch (planetNo) {
       case 0: /*sun*/
         eventId= 620; /* max sun elevation*/ 
         break;
       case 3: /*moon*/
         eventId= 820; /* max moon elevation */ 
         break;
       default:
	 free(eventVal);
	 free(rep2000);
	 free(repId);
	 free(repVal);
	 free(rep250);
	 free(crc250);
         croak("aa_calcSetRise not implemented for planet %d", planetNo); 
    }
    neventVal=3;
    eventVal[0]=latitude;
    eventVal[1]=longitude;
    eventVal[2]=height;
    secdec = 0;
    nrep = 0;
    irc = 0;
    searchCode=+1;  // next event
    astroevent_(&tstart2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc); 
    if (irc != 0 || nrep != 1) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//      free(crc250);
      croak("aa_calcSetRise Error return from astroevent (irc=%d, nrep=%d, eventId=%d, '%s')", irc, nrep, eventId,crc250); 
    }
    me2000=rep2000[0];
/** get state (up/down and polar-effects) */
    switch (planetNo) {
       case 0: /*sun*/
         eventId= 120; /* sun state */ 
         break;
       case 3: /*moon*/
         eventId= 100; /* moon state */ 
         break;
       default:
	 free(eventVal);
	 free(rep2000);
	 free(repId);
	 free(repVal);
	 free(rep250);
	 free(crc250);
         croak("aa_calcSetRise not implemented for planet %d", planetNo); 
    }
    neventVal=3;
    eventVal[0]=latitude;
    eventVal[1]=longitude;
    eventVal[2]=height;
    secdec = 0;
    nrep = 0;
    irc = 0;
    searchCode=0;  // not used
    astroevent_(&me2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc);
    if (irc != 0 ||((eventId==100&&nrep!=3)||(eventId==120&&nrep!=2))) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//     free(crc250);
      croak("aa_calcSetRise Error return from astroevent (irc=%d, nrep=%d, eventId=%d, '%s')", irc, nrep, eventId,crc250); 
    }
    up=floor(repVal[0]+0.5);
    polar=floor(repVal[1]+0.5);
/*    fprintf(stderr, "Here rise");*/
/** get next rise time */
    switch (planetNo) {
       case 0: /*sun*/
         eventId= 600; /* sun rise */ 
         break;
       case 3: /*moon*/
         eventId= 800; /* moon rise */ 
         break;
       default:
	 free(eventVal);
	 free(rep2000);
	 free(repId);
	 free(repVal);
	 free(rep250);
	 free(crc250);
         croak("aa_calcSetRise not implemented for planet %d", planetNo); 
    }
    searchCode=+2; // find all events
    tend2000=tstart2000+1.0;
    neventVal=3;
    eventVal[0]=latitude;
    eventVal[1]=longitude;
    eventVal[2]=height;
    secdec = 0;
    nrep = 0;
    irc = 0;
    astroevent_(&tstart2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc);
    if (irc != 0) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//      free(crc250);
      croak("aa_calcSetRise Error return from astroevent (irc=%d, nrep=%d, eventId=%d, '%s')", irc, nrep, eventId,crc250); 
    };
    lRise=0;
    dateRise = -1;
    lRiseN=0;
    dateRiseN = -1;
    if (nrep>=1) {
      for (ii=0; ii < nrep; ii++ ) {
	if (rep2000[ii]-tstart2000 <= 1.0) {
	  if (lRise==0) {
	    dateRise = rep2000[ii]+ JD2000;
	    lRise=1;
	  } else {
	    dateRiseN = rep2000[ii]+ JD2000;
	    lRiseN=1;
	  }
	}
      }
    }
/** get next set time */
    switch (planetNo) {
       case 0: /*sun*/
         eventId= 610; /* sun set */ 
         break;
       case 3: /*moon*/
         eventId= 810; /* moon set */ 
         break;
       default:
	 free(eventVal);
	 free(rep2000);
	 free(repId);
	 free(repVal);
	 free(rep250);
	 free(crc250);
         croak("aa_calcSetRise not implemented for planet %d", planetNo); 
    }
    neventVal=3;
    eventVal[0]=latitude;
    eventVal[1]=longitude;
    eventVal[2]=height;
    searchCode=+2; // find all events
    tend2000=tstart2000+1.0;
    secdec = 0;
    nrep = 0;
    irc = 0;
    astroevent_(&tstart2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc);
    if (irc != 0) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//      free(crc250);
      croak("aa_calcSetRise Error return from astroevent (irc=%d, nrep=%d, eventId=%d, '%s')", irc, nrep, eventId,crc250); 
    };
    lSet=0;
    dateSet = -1;
    lSetN=0;
    dateSetN = -1;
    if (nrep>=1) {
      for (ii=0; ii < nrep; ii++ ) {
	if (rep2000[ii]-tstart2000 <= 1.0) {
	  if (lSet==0) {
	    dateSet = rep2000[ii]+ JD2000;
	    lSet=1;
	  } else {
	    dateSetN = rep2000[ii]+ JD2000;
	    lSetN=1;
	  };
	};
      };
    }
/** get transit time */
    switch (planetNo) {
       case 0: /*sun*/
         eventId= 760; /* solar time */ 
         break;
       case 3: /*moon*/
         eventId= 770; /* lunar time */ 
         break;
       default:
	 free(eventVal);
	 free(rep2000);
	 free(repId);
	 free(repVal);
	 free(rep250);
	 free(crc250);
         croak("aa_calcSetRise not implemented for planet %d", planetNo); 
    }
    neventVal=4;
    eventVal[0]=latitude;
    eventVal[1]=longitude;
    eventVal[2]=height;
    eventVal[3]=12.; /* transit is at 12 apparent solar/lunar time */
    searchCode=+1; // find next event
    secdec = 0;
    nrep = 0;
    irc = 0;
    astroevent_(&tstart2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc);
    if (irc != 0) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//      free(crc250);
      croak("aa_calcSetRise Error return from astroevent (irc=%d, nrep=%d, eventId=%d, '%s')", irc, nrep, eventId,crc250); 
    } else if ( nrep == 1) {
      dateTransit = rep2000[0]+ JD2000;
    } else {
      dateTransit=-1;
    }
/** get state (up/down and polar-effects) at end time */
    switch (planetNo) {
       case 0: /*sun*/
         eventId= 120; /* sun state */ 
         break;
       case 3: /*moon*/
         eventId= 100; /* moon state */ 
         break;
       default:
	 free(eventVal);
	 free(rep2000);
	 free(repId);
	 free(repVal);
	 free(rep250);
	 free(crc250);
         croak("aa_calcSetRise not implemented for planet %d", planetNo); 
    }
    neventVal=3;
    tend2000=tstart2000+1.0;
    me2000=tend2000;
    eventVal[0]=latitude;
    eventVal[1]=longitude;
    eventVal[2]=height;
    secdec = 0;
    nrep = 0;
    irc = 0;
    searchCode=0;  // not used
    astroevent_(&me2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc);
    if (irc != 0 ||((eventId==100&&nrep!=3)||(eventId==120&&nrep!=2))) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//      free(crc250);
      croak("aa_calcSetRise Error return from astroevent (irc=%d, nrep=%d, eventId=%d, '%s')", irc, nrep, eventId,crc250); 
    }
    upend=floor(repVal[0]+0.5);
/** 
 ** make output
 **/
    if (upend==1) {
      visibleHours=1.0;
    } else {
      visibleHours=0.0;
    }
    if (lRise) {
      visibleHours=visibleHours - (dateRise-JD2000) + tstart2000;
    }
    if (lRiseN) {
      visibleHours=visibleHours - (dateRiseN-JD2000) + tstart2000;
    }
    if (lSet) {
      visibleHours=visibleHours + (dateSet-JD2000) - tstart2000;
    }
    if (lSetN) {
      visibleHours=visibleHours + (dateSetN-JD2000) - tstart2000;
    }
    visibleHours=visibleHours*24.0;
// croak("aa_calcSetRise SUN IS UP %d %d, lrise=%d %f %d %f lset=%d %f %d %f , visible=%f start=%f end=%f", upend,up,lRise,dateRise,lRiseN,dateRiseN,lSet,dateSet,lSetN,dateSetN,visibleHours,tend2000,tstart2000);
    if ( up == -1 || visibleHours < 0) {  /* body is below horison */
      visibleHours = 0;
    } else if (visibleHours > 24) {
      visibleHours = 24;
    }; 
    free(eventVal);
    free(rep2000);
    free(repId);
    free(repVal);
    free(rep250);
    free(crc250);
  OUTPUT:


void
aa_calcAzimuthAltitude(double longitude, double latitude, double height, double temperature, double pressure, int jdflag, double deltaT, double julianDay, int planetNo, OUTLIST double az, OUTLIST double alt)
  PREINIT:
      double tstart2000;
      int searchCode;
      double tend2000;
      int eventId;
      int neventVal;
      double* eventVal;
      int maxrep=0;
      int nrep=0;
      double* rep2000;
      int* repId;
      double* repVal;
      char *rep250;
      int secdec = 0;
      int irc = 0;
      double range;
      char *crc250;
  CODE:
    tstart2000=julianDay-JD2000;
    tend2000=tstart2000;
    switch (planetNo) {
       case 0: /*sun*/
         eventId= 130; /* sun azimuth */ 
          break;
       case 3: /*moon*/
         eventId= 110; /* sun azimuth */ 
          break;
       default:
          croak("aa_calcSetRise not implemented for planet %d", planetNo); 
    }
    maxrep = 3;
    rep2000 = malloc(sizeof(double)*maxrep);
    repId = malloc(sizeof(int)*maxrep);
    repVal = malloc(sizeof(double)*maxrep);
    rep250 = calloc(sizeof(char), 251*maxrep);
    crc250 = calloc(sizeof(char), 251);
    neventVal=4;
    eventVal = malloc(sizeof(double)*neventVal);
    eventVal[0]=latitude;
    eventVal[1]=longitude;
    eventVal[2]=height;
    eventVal[3]=1.; /* time increment */
    searchCode=1; // search for next
    secdec = 0;
    nrep = 0;
    irc = 0;
    /*    fprintf(stderr, "Here rise");*/
    astroevent_(&tstart2000,&searchCode,&tend2000,&eventId,&neventVal,eventVal,&maxrep,&nrep,rep2000,repId,repVal,rep250,&secdec,crc250,&irc);
    if (irc != 0 || nrep != 3) {
      free(eventVal);
      free(rep2000);
      free(repId);
      free(repVal);
      free(rep250);
//      free(crc250);
      croak("aa_calcSetRise Error return from astroevent (irc=%d, nrep=%d, eventId=%d, '%s')", irc, nrep, eventId,crc250); 
    }
    alt = repVal[0];
    az = repVal[1];
    range = repVal[2];
    free(eventVal);
    free(rep2000);
    free(repId);
    free(repVal);
    free(rep250);
    free(crc250);
OUTPUT:

