pro grafik, infile, t, v, dfile, loc

;dfile = '1312543102_MulRec_CH5-1.dat'


loc = 'C:\emrahdropbox\Dropbox\Lab-Data\Data_090512\'
;infile = loc + dfile
;alines=file_lines(infile)
;str=''
;openr,1,infile


;for i=0,11 do readf,1,str
;tunit=double(strmid(str,strpos(str,'=')+1,15))
;print,tunit

;readf,1,str
;v=dblarr(alines-13)

;readf,1,v
;t=dindgen(alines-13)*10.

;plot, t, v, xr=[0.995D4,1.01D4],xtitle = 'x-axis', ytitle = 'y-axis', psym=10, /xstyle
;;p.Save, infile+".png" , BORDER=10, RESOLUTION=10000
;close,1

CONTOURFILE = MAKE_ARRAY(4, 4, /String, VALUE = '1346853412_MulRec_CH8-1.dat')
CONTOURDATA = MAKE_ARRAY(4, 4, /FLOAT, VALUE = 0.0)

;samplerate's unit is in Hertz
samplerate = 125000000

CONTOURFILE[0,0] = '1346860442_MulRec_CH1-1.dat'
CONTOURFILE[0,1] = '1346860442_MulRec_CH2-1.dat'
CONTOURFILE[0,2] = '1346860442_MulRec_CH3-1.dat'
CONTOURFILE[0,3] = '1346860442_MulRec_CH4-1.dat'
CONTOURFILE[1,0] = '1346860442_MulRec_CH5-1.dat'
CONTOURFILE[1,1] = '1346860442_MulRec_CH6-1.dat'
CONTOURFILE[1,2] = '1346860442_MulRec_CH7-1.dat'
CONTOURFILE[1,3] = 'empty.dat'
CONTOURFILE[2,0] = 'empty.dat'
CONTOURFILE[2,1] = 'empty.dat'
CONTOURFILE[2,2] = 'empty.dat'
CONTOURFILE[2,3] = 'empty.dat'
CONTOURFILE[3,0] = 'empty.dat'
CONTOURFILE[3,1] = 'empty.dat'
CONTOURFILE[3,2] = 'empty.dat'
CONTOURFILE[3,3] = 'empty.dat'


for i=0,3 do begin
  for j=0,3 do begin
  
    infile = loc + CONTOURFILE[i,j]
    alines=file_lines(infile)
    OPENR, lun, infile, /GET_LUN
    array = ''
    line = ''
    count=1
    WHILE NOT EOF(lun) DO BEGIN
      READF, lun, line
      IF (count GT 13) THEN BEGIN
           array = [array, line]
      ENDIF ELSE BEGIN
;        IF count EQ 3 THEN samplerate = line
      ENDELSE
      count = count + 1
    ENDWHILE
    
    ;time
    t = FINDGEN(alines-13)
    ;the constant of microsecond
    ms = (1E6)/samplerate
    ;the constant of nanosecond
    ns = (1E9)/samplerate
    
    ;creating directory for the results
    D = STRSPLIT(CONTOURFILE[i,j],'_',/EXTRACT)
      IF (D[0] EQ 'empty.dat') THEN BEGIN
           D[0] = ''
      ENDIF
    FILE_MKDIR, loc + D[0]
    ResDir = loc + D[0]
    
    
    array = FLOAT(array)
    PLOT, t*ms , array*1000.,  xtitle='time (ms)',ytitle='mV',psym=10
    
    ;Save, CONTOURFILE[i,j]+'.JPG'
    v = TOTAL(array)
    print,v
    
    CONTOURDATA[i,j] = v
    
    FREE_LUN, lun
  
  endfor
endfor

print, CONTOURDATA

;data = RANDOMU(seed, 8, 8)
CONTOUR, CONTOURDATA, TITLE='Channels' 

end
