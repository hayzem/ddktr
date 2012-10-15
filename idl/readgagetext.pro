pro readgagetext, infile, t, v, dfile, loc, data_dir, dosya, dosyayazi

srate = 125000000

IF NOT keyword_set(data_dir) THEN data_dir='C:\Program Files (x86)\Gage\CompuScope\CompuScope C SDK\#Lab#C Samples\GageMultipleRecord\'
infile=dialog_pickfile(filter='*.dat',title='Veri Sec',GET_PATH=path,PATH=data_dir)

dosyazaman = STRMID(infile, 90, 10)
print,dosyazaman

dosyayazi = STRMID(infile, 101, strpos(infile,'-')-101)
print,dosyayazi

Result = FILE_SEARCH(data_dir+dosyazaman+'*.dat', /EXPAND_TILDE, /FOLD_CASE)
print,Result
;Durum = DIALOG_MESSAGE( 'Heyy' , TITLE='string' )
dsayisi = N_ELEMENTS(Result)
;dsayisi=1

segsayisi=2

;IF  segsayisi


FOR j=1,dsayisi  DO BEGIN
;FOR k=1,segsayisi  DO BEGIN
dosya = data_dir+string(dosyazaman)+'_'+dosyayazi+'-'+STRCOMPRESS(string(j), /REMOVE_ALL)+'.dat'
alines=file_lines(dosya)
str=''
openr,1,dosya
for i=0,11 do readf,1,str
tunit=double(strmid(str,strpos(str,'=')+1,15))

print,tunit

readf,1,str
v=dblarr(alines-13)


readf,1,v
t=dindgen(alines-13)


;xw = 580 & yh = 480
;window, 0, xsize=xw, ysize=yh
;!p.multi=[0,0,0,0,0]
;!p.font=-1

;frekansına bakmak lazım
filter=1.0/(1+(t/40)^10)
highpass=fft(fft((v),1)*(1.0-filter),-1)

plot,highpass,title='HP Filter',/ystyle,xrange=[500.,2000.]

;p = plot( (t/srate)*1d9, v*1000, xrange=[0.,50000.],xtitle = 'T(ns)', ytitle = 'V(mV)')

;plot, (t/srate)*1d9, v*1000, xrange=[0.,50000.],xtitle = 'T(ns)', ytitle = 'V(mV)', /ystyle

;p.Save, dosya+".png" , BORDER=10, RESOLUTION=10000

close,1

ENDFOR
end
