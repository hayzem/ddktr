pro e_readgagetextek, ps=ps

IF NOT keyword_set(ps) THEN ps=0

;dfile = '1346077016_MulRec_CH3-6.dat'
;loc = 'C:\Program Files (x86)\Gage\CompuScope\CompuScope C SDK\#Octopus Digitiser Interface\Developing\v0.1\IniController\bin\Debug\'

data_dir='~/Dropbox/Lab-Data/Data'
infile1=dialog_pickfile(filter='*.dat',title='Filename', PATH=data_dir)

setfile1=infile1
setbase=strsplit(infile1,'/',/extract)
basef=setbase[5]
base2=strmid(basef,0,20)
base3=strmid(basef,21,strlen(basef))
setfile2=data_dir+'/'+base2+'3'+base3
setfile3=data_dir+'/'+base2+'5'+base3
setfile4=data_dir+'/'+base2+'7'+base3

readsinglegage,setfile1, t1, s1
readsinglegage,setfile2, t2, s2
readsinglegage,setfile3, t3, s3
readsinglegage,setfile4, t4, s4

;Determine the highest peak

sall=sort([avg(s1),avg(s2),avg(s3),avg(s4)])
;
;determine the start point

case sall[3] of
  0: ns=s1
  1: ns=s2
  2: ns=s3
  3: ns=s4
  endcase
  
yy=where(ns lt 0.2*avg(ns))
t0=t1[max(yy)]
t1=(t1-t0)
t2=(t2-t0)
t3=(t3-t0)
t4=(t4-t0)

xr=[-500,500]

;stop
;stop
; Draw all plots to the same window
!p.MULTI = [0,2,2]

IF not ps THEN BEGIN
  ; Resize the window
  WINDOW, /FREE, XSIZE=(720), YSIZE=(720), $
  TITLE='Preamp Out'

  ; Use a maximum of 256 colors and load a grayscale color map
  DEVICE, RETAIN=2, DECOMPOSED=0
  LOADCT, 0

  ; Set eye-pleasing drawing and background colors
  !p.color = 0
  !p.background = 255
ENDIF ELSE BEGIN
  set_plot,'ps'
  device,/encapsulated
  device,filename=data_dir+'outp.eps'
  ENDELSE
  
  


PLOT, t1*1e9, s1*1000., xtitle='time (ns)',ytitle='mV',xr=xr,psym=10
PLOT, t2*1e9, s2*1000., xtitle='time (ns)',ytitle='mV',xr=xr,psym=10
PLOT, t3*1e9, s3*1000., xtitle='time (ns)',ytitle='mV',xr=xr,psym=10
PLOT, t4*1e9, s4*1000., xtitle='time (ns)',ytitle='mV',xr=xr,psym=10
;PLOT, x, filter, TITLE='Filter Function '
;PLOT, x, y_signal + y_noise, TITLE='Signal + Noise'
;PLOT, x, y_filtered, TITLE='Signal + Noise (Filtered)'

; Reset the system variable to one plot per page
!p.MULTI=0

IF ps THEN BEGIN
  device,/close
  IF !version.os_family eq 'unix' THEN set_plot,'x' ELSE set_plot,'win'
ENDIF

END
