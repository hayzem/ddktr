pro readgagetext02, infile, t, v, dfile, loc, y

dfile = '1346077016_MulRec_CH1-1.dat'

loc = 'C:\Program Files (x86)\Gage\CompuScope\CompuScope C SDK\#Octopus Digitiser Interface\Developing\v0.1\IniController\bin\Debug\'
infile = loc + dfile
alines=file_lines(infile)
str=''
openr,1,infile
for i=0,11 do readf,1,str
tunit=double(strmid(str,strpos(str,'=')+1,15))
print,tunit

readf,1,str
v=dblarr(alines-13)

readf,1,v
t=dindgen(alines-13)*10.

;srate = 125000000
;y=[findgen(100),findgen(100)-100]
;y[101:199]=reverse(y[0:98])
;filter=1.0/(1+(y/40)^10)
;highpass=fft(fft((v*1000),1)*(1.0-filter),-1)
;plot,highpass,title='HP Filter',/ystyle,xrange=[500.,1000.]

;plot, t, v,xtitle = 'x-axis', ytitle = 'y-axis', psym=10, /xstyle
;p.Save, infile+".png" , BORDER=10, RESOLUTION=10000

; Create a sine wave
;x = 4*!PI/1000 * FINDGEN(1000) 
x = t/125000000
;y_signal = (SIN(x)+1)
y_signal = v

; Create random noise
;y_noise = RANDOMU(SEED,6000)
; Freq
f = 154000000
y_noise = SIN(2*!PI*f*t)

; Add the noise to the sine data
;y_summation = y_signal + y_noise
y_summation = v

; Create a Butterworth filter
filter = BUTTERWORTH(6000)

; Do a forward Fourier transform of the image, and then do
; an inverse Fourier transform of the filtered image
y_filtered = FFT( FFT(y_summation, -1) * filter, 1 )

; Draw all plots to the same window
!p.MULTI = [0,0,3,0,0]

; Resize the window
WINDOW, /FREE, XSIZE=(720), YSIZE=(720), $
   TITLE='Butterworth Filter'

; Use a maximum of 256 colors and load a grayscale color map
DEVICE, RETAIN=2, DECOMPOSED=0
LOADCT, 0

; Set eye-pleasing drawing and background colors
!p.color = 0
!p.background = 255

PLOT, x, y_signal, TITLE='Signal'
PLOT, x, filter, TITLE='Filter Function '
;PLOT, x, y_signal + y_noise, TITLE='Signal + Noise'
PLOT, x, y_filtered, TITLE='Signal + Noise (Filtered)'

; Reset the system variable to one plot per page
!p.MULTI=0

close,1
end
