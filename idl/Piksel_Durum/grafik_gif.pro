pro grafik_gif, infile, t, v, dfile, loc


loc = 'C:\emrahdropbox\Dropbox\Lab-Data\Data\'
reffile = '1346077016_MulRec_CH1-1.dat'

CONTOURFILE = MAKE_ARRAY(4, 4, /String, VALUE = reffile)

;1-4 pixels
CONTOURFILE[0,0] = ''
CONTOURFILE[0,1] = ''
CONTOURFILE[0,2] = ''
CONTOURFILE[0,3] = ''
;5-7 pixels
CONTOURFILE[1,0] = ''
CONTOURFILE[1,1] = '1346077016_MulRec_CH1-1.dat'
CONTOURFILE[1,2] = '1346077016_MulRec_CH3-1.dat'
CONTOURFILE[1,3] = ''
;8-11 pixels
CONTOURFILE[2,0] = ''
CONTOURFILE[2,1] = '1346077016_MulRec_CH5-1.dat'
CONTOURFILE[2,2] = ''
CONTOURFILE[2,3] = ''
;12-16 pixels
CONTOURFILE[3,0] = ''
CONTOURFILE[3,1] = ''
CONTOURFILE[3,2] = ''
CONTOURFILE[3,3] = ''

!P.MULTI = [0, 8, 4, 0, 0]
!p.color = 0
!p.background = 255
; Resize the window
WINDOW, /FREE, XSIZE=(1680), YSIZE=(1000), $
   TITLE='Plots'

;pik'in oldugu bolgeye gore buraya otomatik bir fonk yazılabilir
;xRange
bas=950
son=1100


infile = loc + reffile
datasize=file_lines(infile)-12

;her birim zamanda alınan tüm piksellerdeki datayı tek bir array'de tutar
SURFACEDATA = MAKE_ARRAY(1,datasize, /FLOAT, VALUE = 0.0)

;verilen aralıktaki piksellerdeki datanın ortalamasını tutar
CONTOURDATA = MAKE_ARRAY(4, 4, /FLOAT, VALUE = 0.0)

;samplerate's unit is in Hertz
samplerate = 125000000

;time
t = FINDGEN(datasize-13)
;the constant of microsecond
ms = (1E6)/samplerate
;the constant of nanosecond
ns = (1E9)/samplerate


for i=0,3 do begin
  for j=0,3 do begin
  
    D = STRSPLIT(CONTOURFILE[j,i],'_',/EXTRACT)
    IF (D[0] EQ '') THEN BEGIN
      array = MAKE_ARRAY(1,datasize, /FLOAT, VALUE = 0.0)
    ENDIF ELSE BEGIN

      infile = loc + CONTOURFILE[j,i]
      alines=file_lines(infile)
      OPENR, lun, infile, /GET_LUN
      array = ''
      line = ''
      count=1
      WHILE NOT EOF(lun) DO BEGIN
        READF, lun, line
        IF (count GT 13) THEN BEGIN
             array = [[array], [line]]
        ENDIF ELSE BEGIN
          IF count EQ 2 THEN peakpoint = line
        ENDELSE
        count = count + 1
      ENDWHILE
      
      

      
      ;creating directory for the results
      FILE_MKDIR, loc + D[0]

      FREE_LUN, lun
    ENDELSE
    
    array = FLOAT(array)
  
      ;BUTTERWORTH Filter
    y_summation = array*1000
    
    ; Create a Butterworth filter
    filter = BUTTERWORTH(N_ELEMENTS(array))
    
    ; Do a forward Fourier transform of the image, and then do
    ; an inverse Fourier transform of the filtered image
    y_filtered = FFT( FFT(y_summation, -1) * filter, 1 )
  
    SURFACEDATA = [[SURFACEDATA],y_filtered]
    
    

    
    
    ;take data from around the peak point
    peak_array = array[bas:son]
    peak_filtered = y_filtered[bas:son]
    peak_t = t[bas:son]
    
    
    ;Plotting
    PLOT, peak_t , peak_array*1000.,  xtitle='time (ms)',ytitle='mV',  psym=10 
    PLOT, peak_t, peak_filtered*1000, TITLE='Signal (Filtered)'
    
    ;chgraph = PLOT( t*ms , array*1000.,  xtitle='time (ms)',ytitle='mV')
    ;Save, CONTOURFILE[i,j]+'.JPG'
    ;WRITE_JPEG, ResDir + CONTOURFILE[i,j]+'.JPG', chgraph, TRUE=1
    
    v = TOTAL(array[bas:son])
    print,v
    
    CONTOURDATA[i,j] = v
  
  endfor
endfor

!p.MULTI=0

print, CONTOURDATA
print, size(surfacedata)

;surface plots
say = 0
for d=bas,son do begin
  b = SURFACEDATA[*,say,*]
  frame = MAKE_ARRAY(4,4, /FLOAT, VALUE = 0.0)
  for i=0,3 do begin
    for j=0,3 do begin
      frame[j,i] = b[i+j+1]
    endfor
  endfor

ISURFACE, MIN_CURVE_SURF(frame), TITLE = 'D'


;  shade_surf, MIN_CURVE_SURF(frame), charsize=2, $
;    xtitle='Pixels in x-direction (RA)', $
;    ytitle='Pixels in y-direction (Dec)', $
;    ztitle='Digital number', $
;    title='Star BS4030 (35 Leo) in 2.36 um'
  
  
  ;surf_hann = SURFACE(frame, COLOR='light_blue')


;  smooth = CONTOUR(MIN_CURVE_SURF(frame), TITLE='Detector'+say,  $
;   /CURRENT,  RGB_TABLE=0, $
;   /FILL, N_LEVELS=10)

  ;SHADE_SURF( frame, AZ=0, AX=90 )
  
  print,size(frame)
  ;filename = FILEPATH(string(say)+'.jpg')
 ; WRITE_JPEG, filename, TVRD(/TRUE), /TRUE
  ;smooth.save, filename
  
  
  ;PRINT, 'File written to ', filename
  
  say = say + 1
endfor



print,count
;b = SURFACEDATA[1,*,*]

;surf_hann = SURFACE(SURFACEDATA[0:1], COLOR='light_blue')

;data = RANDOMU(seed, 8, 8)
;CONTOUR, CONTOURDATA, TITLE='Channels' 
;c = CONTOUR(MIN_CURVE_SURF(CONTOURDATA, /REGULAR),  TITLE='Channels')
;PLOT,c

smooth = CONTOUR(MIN_CURVE_SURF(CONTOURDATA), TITLE='Detector', $
   /CURRENT,  RGB_TABLE=13, $
   /FILL, N_LEVELS=10)

;Plot,smooth
;smooth.save, ResDir + CONTOURFILE[i,j]+'.JPG'

end


;Notlar
;bu progamdan sonra gif şeklinde grafikler yapılabilir
;her bir data için sırasıyla grafikler oluşturulup onlar ard arda gif şeklinde işlenebilir
;arraylarin boyutlarını iyi ayarlaamk lazım ona göre grafikler olusturmak lazım 16,datasize yapmak lazım
