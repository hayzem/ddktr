pro reorganize_mix,evlist,an_thr,cat_thr,se_thr,clean,outstr=outstr,$
  catn=cats,anotn=anots,sen=ses,inse=inse, semap=mapse

;this program creates a structure that holds all share information neatly for event lists
;coming either from RENA or MPA system. The program allows more than one cathode, and also 
;holds steering electrode information

;INPUTS
;
;evlist: event list array, can be channels or calibrated energies
;
;an_thr: minimum acceptable anode signal (be careful it depends on channel or energy depending on your event list)
;
;cat_thr: minimum acceptable planar signal
;
;se_thr: minimum acceptable steering electrode signal, not implemented yet
;
;OUTPUT
;clean: structure that holds only events above threshold with planar information
;
;OPTIONAL ARGUMENTS
;
;cats=array of the cathodes
;
;anots=array of the anodes
;
;ses=array of the steering electrodes
;
;outstr: optional structure with all events, used for diagnostics.
;
;inse: if set, include steering electrode good events in the clean
;
;mapse: it sets the actual steering electrode channel
;
;Used by:
;
;
;Uses
;
;reorganize_anodes.pro
;reorganize_cathodes.pro
;
;Created by Emrah Kalemci
;30/01/2012
;
;NOTES & BUG FIXES
;
;steering electrode added, 07/02/2012
;
;steering electrode map added 27/02/2012
;

IF NOT keyword_set(cats) THEN cats=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
IF NOT keyword_set(anots) THEN anots=[17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]
IF NOT keyword_set(ses) THEN ses=[33,34,35]
IF NOT keyword_set(inse) THEN inse=0
IF NOT keyword_set(mapse) THEN mapse=[1,3,5]

;definition of flags
;
;general and noise related, same for both anodes and cathodes
;
; thresh : everything 0 (should not happen)
; thresh_x : x=1,2,3,4,m cathode below threshod, x number of anodes below threshold

; anode flags (if cathode above threshold, then flags are the same as anode flags)
; single : single anode above anode threshold, cathode(s) above cathode threshold; single_an : single anode above anode threshold, cathode(s) below cathode threshold
; double : double anode above anode threshold, cathode(s) above cathode threshold
; triple : triple anode above anode threshold, cathode(s) above cathode threshold
; quad : quadrupole anode above anode threshold, cathode(s) above cathode threshold
; mult : multiple anode above anode threshold, cathode(s) above cathode threshold
;
;cathode flags
;
; single : single cathode above cathode threshold, anode(s) above anode threshold
; double : double cathode above cathode threshold, anode(s) above anode threshold
; triple : triple cathode above cathode threshold, anode(s) above anode threshold
; quad : quadrupole cathode above cathode threshold, anode(s) above anode threshold
; mult : multiple cathode above cathode threshold, anode(s) above anode threshold
;
sz=size(evlist)

 outstr1=create_struct('aflag','','cflag','','sflag','','flag','',$
  'en',fltarr(4),'toten',0.,'det',intarr(4), $
  'cadet',intarr(4),'caten',0.,'catend',fltarr(4),'car',0.,$
  'sedet',intarr(3),'seen',0.,'seend',fltarr(3))
  outstr=replicate(outstr1,sz(2))

;now call anode, cathode and steering electrode reorganizing routines

reorganize_anodes,evlist,an_thr,outstr,anotn=anots
reorganize_cathodes,evlist,cat_thr,outstr,catn=cats
reorganize_se, evlist, se_thr, outstr, sen=ses , semap=mapse

;redefine flags for clean only!
;

;good cathodes
casig=where((outstr.cflag eq 'single') or (outstr.cflag eq 'double') or $
  (outstr.cflag eq 'triple') or (outstr.cflag eq 'quad') or (outstr.cflag eq 'mult'))

;good anode events get the same flag 
xx=where(outstr[casig].aflag eq 'single')
outstr[casig[xx]].flag='single'
clean=outstr[casig[xx]]
xx=where(outstr[casig].aflag eq 'double')

IF xx[0] NE -1 THEN BEGIN
  outstr[casig[xx]].flag='double'
  clean=[clean,outstr[casig[xx]]]
ENDIF

xx=where(outstr[casig].aflag eq 'triple')
IF xx[0] NE -1 THEN BEGIN
  outstr[casig[xx]].flag='triple'
  clean=[clean,outstr[casig[xx]]]
ENDIF

xx=where(outstr[casig].aflag eq 'quad')
IF xx[0] NE -1 THEN BEGIN
  outstr[casig[xx]].flag='quad'
  clean=[clean,outstr[casig[xx]]]
ENDIF

xx=where(outstr[casig].aflag eq 'mult')
IF xx[0] NE -1 THEN BEGIN
  outstr[casig[xx]].flag='mult'
  clean=[clean,outstr[casig[xx]]]
ENDIF


clean.car=clean.caten/clean.toten
IF inse THEN BEGIN
   xx=where(outstr[casig].sflag eq 'single')
   IF xx[0] NE -1 THEN BEGIN
      clean=[clean,outstr[casig[xx]]]
   ENDIF
ENDif


END
