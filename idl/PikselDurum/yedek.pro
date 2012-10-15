pro grafik, infile, t, v, dfile, loc

;dfile = '1312543102_MulRec_CH5-1.dat'


loc = 'C:\Program Files (x86)\Gage\CompuScope\CompuScope C SDK\#Lab#C Samples\GageMultipleRecord\'
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

CONTOURFILE = MAKE_ARRAY(4, 4, /String, VALUE = '1312543102_MulRec_CH5-1.dat')
CONTOURDATA = MAKE_ARRAY(4, 4, /FLOAT, VALUE = 0.0)

for i=0,3 do begin
  for j=0,3 do begin
  
    infile = loc + CONTOURFILE[i,j]
    OPENR, lun, infile, /GET_LUN
    array = ''
    line = ''
    count=1
    WHILE NOT EOF(lun) DO BEGIN
      READF, lun, line
      array = [array, line]
    ENDWHILE
    
    ;v = TOTAL(array)
    print,array
    
    ;CONTOURDATA[i,j] = v
    print, CONTOURDATA[i,j]
    
  endfor
endfor



data = RANDOMU(seed, 8, 8)
CONTOUR, MIN_CURVE_SURF(data), TITLE='Channels' 

end
