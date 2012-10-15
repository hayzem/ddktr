; Create X and Y arrays:

nx = 128L

ny = 100L

X = FINDGEN(nx) # REPLICATE(1.0, ny)

Y = REPLICATE(1.0, nx) # FINDGEN(ny)

 

; Define input function parameters:

aAxis = nx/6.

bAxis = ny/10.

h = 0.5*nx

k = 0.6*ny

tilt = 30*!PI/180

A = [ 5., 10., aAxis, bAxis, h, k, tilt]

 

; Create an ellipse:

xprime = (X - h)*cos(tilt) - (Y - k)*sin(tilt)

yprime = (X - h)*sin(tilt) + (Y - k)*cos(tilt)

U = (xprime/aAxis)^2 + (yprime/bAxis)^2

 

; Create gaussian Z with random noise:

Zideal = A[0] + A[1] * EXP(-U/2)

Z = Zideal + RANDOMN(seed, nx, ny)

B = [] ; clear out the variable

 

; Make about 20% of the points be "bad" data.

bad = WHERE(RANDOMU(1, nx, ny) gt 0.8)

Z[bad] = 999

 

; Create the mask of the bad data points.

mask = REPLICATE(1, nx, ny)

mask[bad] = 0

 

;***** Fit the function *****

yfit = GAUSS2DFIT(Z, B, /TILT, MASK=mask)

 

; Report results:

PRINT, 'Should be: ', STRING(A, FORMAT='(6f10.4)')

PRINT, 'Is: ', STRING(B, FORMAT='(6f10.4)')

 

; Create an array with our fitted results

xprime = (X - B[4])*cos(B[6]) - (Y - B[5])*sin(B[6])

yprime = (X - B[4])*sin(B[6]) + (Y - B[5])*cos(B[6])

Ufit = (xprime/B[2])^2 + (yprime/B[3])^2

Zfit = B[0] + B[1] * EXP(-Ufit/2)

 

; Plot the results. The black dots are missing data.

im = IMAGE(BYTSCL(Z, MAX=20), RGB_TABLE=40, LAYOUT=[1,1,1])

 

; Contour plot of the fit.

c = CONTOUR(Zfit, /OVERPLOT, C_THICK=[4], COLOR='red')
