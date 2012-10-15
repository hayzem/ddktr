xw = 580 & yh = 480
window, 0, xsize=xw, ysize=yh
!p.multi=[0,0,0,0,0]
!p.font=-1
a = fltarr(2, 361)
go = strarr(1)
print, 'A Simple plot'
openr,1,'C:\Documents and Settings\Administrator\sine.dat'
while not EOF(1) do readf, 1, a
close, 1
a = transpose(a)

plot, a(*,0), a(*,1), xtitle = 'x-axis', ytitle = 'y-axis', $
  title = 'Simple Sine Curve'


print, 'Hit return to continue'
readf, 0, go

;;;;;;;;;;;;;;;;;;;; multiple plots using !p.multi ;;;;;;;;;;;;;;;;;;;;;;

print, 'Multiple plots using !p.multi'

; define array x=[-5.0,5.0] at intervals of 0.2, and subsequent
; functions of x
x = (findgen(50)/5.0) - 5.0
y1 = sin(x)
y2 = exp(x)
y3 = atan(x)
y4 = cosh(x)

; plot 4 plots on one page using the !p.multi command, with various
; font labels and plot symbols
!p.multi=[0, 2, 2, 0, 0]

plot, x, y1, title = 'Sin(x)', psym=2
plot, x, y2, title = '!6Exp(x)', psym=4
plot, x, y3, title = '!8Atan(x)', psym=3
plot, x, y4, title = '!13Cosh(x)', psym=1

; reset global variable !p.multi or it screws up subsequent plots
!p.multi=[0, 0, 0, 0, 0]

print, 'Hit return to continue'
readf, 0, go

;;;;;;;;;;;; multiple plots using position option with plot command;;;;;;;;;;;;

print, 'Multiple plots by specifying position/Logarithmic Plots'
print, 'with Postscript fonts'

; define postscript font to be used
!p.font=0
device,font='-adobe-helvetica-bold-r-normal-*-16-*-*-*-*-*-*-*'

; manually determine parameters to position plots
w = xw/3.0
h = 0.5*yh - xw/8.0
x1s=w & y1s=0.5*w+h
x2s=w & y2s=w/4.0

; plot two graphs and position them using the pos=[...] option
plot, x, y2, /xlog, title = 'Exp(x) vs Log(x)',/device, $
  pos=[x1s, y1s, x1s+w, y1s+h]
plot, x, y2, /ylog,/noerase, title = 'Log(Exp(x)) vs x',/device, $
  pos=[x2s, y2s, x2s+w, y2s+h]

; reset global multiple plot and font variables
!p.multi=[0,0,0,0,0]
!p.font=-1

end
