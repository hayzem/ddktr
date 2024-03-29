; THIS PROGRAM DETERMINES THE ELECTRON MOTION INSIDE A DETECTOR ALONG THE FIELD LINES
; AND CALCULATES THE INDUCED CHARGE ON A SPECIFIC ELECTRODE.

pro electron_motion,lastpos, xstart, zstart, Efieldx, Efieldz, WP_Ano, WP_Cath, WP_ST,$
 te_actual, xe_actual, ze_actual, QA_ind_e, QC_ind_e, QST_ind_e,$
   ypos = posy, etau=taue, emob=mobe, plotout=plotout, plotps=plotps, fname=namef,$
   verbose=verbose, coarsegridpos=poscoarsegrid

;INPUTS
;xstart: start position in the x direction in mm
;zstart: start position in the z direction in mm
;Efieldx: x component of the electric field
;Efieldz: z component of the electric field
;WP_Ano: Weihgting potential of the anode
;WP_Cath: Weighting potential of the cathode
;WP_ST  : Weighting potential of the steering electrode
;
;OPTIONAL INPUTS
;taue: trapping time of electrons
;mobe : electron mobility
;posy : fixed y position for calculating cathode signal. If not given, 
;       assumed to be the center of the cathode
;verbose: if set screen output for diagnostic is produced. The default
;         parameters to be shown are x, z, t, QA_ind_e, QC_ind_e
;poscoarsegrid : one can set where coarse gridding starts and end default=[0.5,4.5] mm

;
;OUTPUTS
;te_actual: time variable with respect to the motion of electrons
;xe_actual: actual x position with respect to the motion of electrons
;ze_actual: actual z position with respect to the motion of electrons
;QA_ind_e: Induced charge of electrons on the anode side
;QC_ind_e: Induced charge of electrons on the cathode side
;QST_ind_e: Induced charge of electrons on the steering electrodes
;
;OPTIONAL OUTPUTS
;plotout: If this option is selected, user gets plots on the screen
;plotps: If this option is selected, user gets plots as a ps file
;namef: output postscript filename

;=======NOTES, BUG Fixes
;August 14, 2011, A bug on the definition of posy was fixed as well
;as a bug on cathode weighting potential definition

;Still going in a loop at negative electric fields, maybe it is not
;physical. For now I will write a routine to catch the loop and get
;out with a warning message

;August 15, 2011, verbose keyword added, minor fixes on description

;August 18, 2011, yet another stupid mistake, when z goes by 5, gz must go by 5*0.005
;major effect on time and x position. In fact a coarsegrid position variable is set so
;that one can adjust which part of the detector is coarse and which part is fine

;further tets show that at the edge of the detector electron may try to get out. Now the
;electron is placed back in the detector.

;There still is a problem with going into loop at special values. current solution is demanding
;that the absolute value of the electric field in z direction to be minimum 3, however, I need
;to find a better fix to this problem.

IF NOT keyword_set(plotout) THEN plotout=0
IF NOT keyword_set(plotps) THEN plotps=0
IF NOT keyword_set(verbose) THEN verbose=0

aa = size(Efieldz)

QT_e = dblarr(aa[1],aa[2])          ; Trapped Charge array

IF NOT KEYWORD_SET(taue) THEN taue=3E-6 ; electron trapping time in s
IF NOT KEYWORD_SET(mobe) THEN mobe=1E5 ; mm^2/V.s, electron mobility
z_thick = 5.0                       ; mm. Detector z thickness
x_length = 19.54                    ; mm. Detector x length

gx = 0.005                          ; Default x grid spacing in mm
gz = 0.005                          ; Default z grid spacing in mm
gy = 0.005

;coarse and finegrid indexes

IF NOT keyword_set(poscoarsegrid) THEN BEGIN
  coarsezstart=100
  coarsezend=900
  ENDIF ELSE BEGIN
  coarsezstart=floor(poscoarsegrid[0]/gz)
  coarsezend=floor(poscoarsegrid[1]/gz)
  ENDELSE
  
;y position for cathode
;IF NOT KEYWORD_SET(posy) then BEGIN
;  slice=reform(WP_Cath[*,950])
;  y=where(slice eq max(slice))
;ENDIF ELSE y=floor(posy/gy)

;------ ELECTRON MOTION --------
;In the following, electron motion along the electric field lines are obtained

xe_actual = xstart               ; Obtain actual x position of electron along the grid at starting point
xev = xe_actual                 ; record for later use
ze_actual= zstart               ;record for the full array

te_actual=0.                        ; Initial actual time

x = floor(xstart/gx)                ; Initial electron position in x
z = floor(zstart/gz)                ; Initial electron position in z



;Qr_e = 1.                           ; At start position remaining charge is all the charge
;QT_e[x,z] = 0.                      ; At xstart and zstart initial trapped charge is 0.
;QTindA = 0.                         ; initial induced charges due to trapped electrons
;QTindC = 0.
;QTindST = 0.

;QA_ind_e  = Qr_e*WP_Ano[x,z]        ; Initial induced Charge on the anode site
;QC_ind_e  = Qr_e*WP_Cath[y,z]       ; Initial induced Charge on the cathode site
;QST_ind_e = Qr_e*WP_ST[x,z]         ; Initial induced Charge on the steering electodes

t=0.                                ; Starting time

;------ OBTAIN INDUCED CHARGES WITH RESPECT TO THE DIRECTON OF ELECTRIC FIELD ------

loopcheck=1
;;;;;;;;;;;;;;;;;;????????????????????????
IF z lt 15 THEN cntrl = 1 ELSE cntrl = 0

WHILE ((z gt floor(lastpos/0.005)+15)  AND (Abs(Efieldz[x,z]) GT 3.) AND loopcheck) DO BEGIN

;I am not happy about this magic number 3 here, need to find another way to 
;catch this problem

IF n_elements(z) GT 1 THEN STOP
; Start while loop, except z=0 calculate actual x dimension and time
; Check electric field and make sure electron moves

IF ((z LT coarsezstart) OR (z GT coarsezend)) THEN gz=0.005 ELSE gz=0.025
;;;;;??????????????????????????
Dte = ABS(gz/(mobe*Efieldz[x,z]))          ; Obtain time step
t = t+Dte
te_actual = [te_actual,t]           ; In order to find in terms of nanosecond, I multiplied by *(1*E9)

Dxe = -mobe*Efieldx[x,z]*Dte          ; Obtain x step, since electron has negative charge, multiplied with -1.
xev = xev + Dxe                     ;actual x position

;L = Sqrt(Dxe^2+gz^2)                ;total distance travelled
;L_e = (taue*mobe)*sqrt(Efieldx[x,z]^2+Efieldz[x,z]^2)  ; Le is the minority carrier diffusion length.

;QT_e[x,z] = Qr_e*(1.-Exp(-L/L_e))        ; Trapped charge along the field lines
;Qr_e = Qr_e*Exp(-L/L_e)                  ; Remaining induced charge after trapping
;QTindA=QTindA+(QT_e[x,z]*WP_Ano[x,z])    ;this is an approximation that may be problematic for large x movements
;QTindC=QTindC+(QT_e[x,z]*WP_Cath[y,z])    ;this is an approximation that may be problematic for large x movements
;QTindST=QTindST+(QT_e[x,z]*WP_ST[x,z])    ;this is an approximation that may be problematic for large x movements

;keep in the detector
IF xev GE 19.54 THEN xev=19.54
IF xev LT 0. THEN xev=0


;----- CHECK THE DIRECTION OF ELECTRIC FIELD LINES -------
; Electron moves through the anode

IF Efieldz[x,z] LT 0 THEN BEGIN          ; Obtain the Electric field lines.

   IF ((z LT coarsezstart) OR (z GT coarsezend)) THEN z=z+1 ELSE z=z+5

ENDIF ELSE BEGIN

   IF ((z LT coarsezstart) or (z GT coarsezend)) THEN z=z-1 ELSE z=z-5

ENDELSE

x=floor(xev/gx+0.5)                       ; Obtain new x position in the nearest grid point

;should stay in the detector
IF x gt 3908 THEN x = 3908
IF x lt 0 THEN x = 0

;make sure x stays in detector

IF x GE aa[1] THEN BEGIN
  IF verbose THEN print,'at the edge of detector, at 19.54'
  x=aa[1]-1L
  ENDIF
  
IF x LE 0. THEN BEGIN
  IF verbose THEN print,'at the edge of detector, at 0'
  x=0
  ENDIF
 
;stop
IF ((Efieldz[x,z] LT 0.) AND (Abs(Dxe/gx) LT 1.)) THEN BEGIN
   loopcheck=0 
   IF verbose THEN print, 'motion will be stopped here to avoid loop'
ENDIF

xe_actual = [xe_actual,xev]
ze_actual = [ze_actual,z*0.005]

;QA_ind_e = [QA_ind_e, Qr_e*WP_Ano[x,z] + QTindA]     ; Final induced charge on anode site
;QC_ind_e = [QC_ind_e, Qr_e*WP_Cath[y,z] + QTindC]   ; Final induced charge on cathode site
;QST_ind_e = [QST_ind_e, Qr_e*WP_ST[x,z] + QTindST]     ; Final induced charge on steering electrode site

IF verbose THEN $
                IF (((z mod 10) eq 0) OR (z LT 10)) THEN $
                print, x,z,t, QA_ind_e[n_elements(te_actual)-1],$
                       QC_ind_e[n_elements(te_actual)-1]

ENDWHILE

IF lastpos eq 0 THEN BEGIN
   WHILE z ne 0 DO BEGIN
      deltax=xe_actual(n_elements(xe_actual)-1)-xe_actual(n_elements(xe_actual)-2)
      deltat=te_actual(n_elements(te_actual)-1)-te_actual(n_elements(te_actual)-2)
      xe_actual=[xe_actual,xe_actual(n_elements(xe_actual)-1)+deltax]
      te_actual=[te_actual,te_actual(n_elements(te_actual)-1)+deltat]
      z=z-1
      ze_actual=[ze_actual,z*0.005]
   ENDWHILE
ENDIF

IF (plotout or plotps) THEN BEGIN

  IF plotps THEN BEGIN
    SET_PLOT,'ps'
    IF NOT KEYWORD_SET(namef) then namef='electronmotion.ps'
    device, filename=namef
    ENDIF
 
  IF NOT plotps THEN window,1,xsize=800,ysize=200
  plot,xe_actual,ze_actual,yrange=[0.,5.],xtitle='Distance Along Detector(mm)',ytitle='depth(mm)',title='Electron',xrange=[0.,20.]
  ; Obtain the placement of anodes
  obox,0.337,0,0.637,0.1
  obox,1.311,0,1.611,0.1
  obox,2.285,0,2.585,0.1
  obox,3.709,0,3.909,0.1
  obox,5.033,0,5.233,0.1
  obox,6.357,0,6.557,0.1
  obox,7.781,0,7.881,0.1
  obox,9.105,0,9.205,0.1
  obox,10.429,0,10.529,0.1
  obox,11.753,0,11.853,0.1
  obox,12.727,0,13.027,0.1
  obox,13.901,0,14.201,0.1
  obox,15.075,0,15.375,0.1
  obox,16.049,0,16.649,0.1
  obox,17.323,0,17.923,0.1
  obox,18.595,0,19.195,0.1

  IF NOT plotps THEN window,2,xsize=500,ysize=500
  plot, te_actual*1E9, QA_ind_e,xtitle='Time (ns)',ytitle='Q/Qo',title='Anode';,xrange=[0,50]
  IF NOT plotps THEN window,3,xsize=500,ysize=500
  plot, te_actual*1E9, QC_ind_e,xtitle='Time (ns)',ytitle='Q/Qo',title='Cathode';,xrange=[0,50]
  IF NOT plotps THEN window,4,xsize=500,ysize=500
  plot, te_actual*1E9, QST_ind_e,xtitle='Time (ns)',ytitle='Q/Qo',title='Steering Electrode';,xrange=[0,50]

  IF plotps THEN BEGIN
    device,/close
    IF !version.os_family EQ 'unix' THEN SET_PLOT,'x' ELSE SET_PLOT,'WIN'
    ENDIF

ENDIF


END
