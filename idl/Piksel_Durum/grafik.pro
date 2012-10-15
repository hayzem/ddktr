; Create a simple dataset:

data = RANDOMU(seed, 9, 9)

 

; Plot the unsmoothed data:

unsmooth = CONTOUR(data, TITLE='Unsmoothed', $

   LAYOUT=[2,1,1], RGB_TABLE=13, /FILL, N_LEVELS=10)

; Draw the outline of the 10 levels

outline1 = CONTOUR(data, N_LEVELS=10, /OVERPLOT)

 

; Plot the smoothed data:

smooth = CONTOUR(MIN_CURVE_SURF(data), TITLE='Smoothed', $

   /CURRENT, LAYOUT=[2,1,2], RGB_TABLE=13, $

   /FILL, N_LEVELS=10)

; Draw the outline of the 10 levels

outline2 = CONTOUR(MIN_CURVE_SURF(data), $

   N_LEVELS=10, /OVERPLOT)
   
