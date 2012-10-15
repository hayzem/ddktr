pro graphic_objSur

oSurface -> GETPROPERTY, XRANGE = xr, YRANGE = yr, $  
   ZRANGE = zr  
xs = NORM_COORD(xr)  
xs[0] = xs[0] - 0.5  
ys = NORM_COORD(yr)  
ys[0] = ys[0] - 0.5  
zs = NORM_COORD(zr)  
zs[0] = zs[0] - 0.5  
oSurface -> SETPROPERTY, XCOORD_CONV = xs, $  
   YCOORD_CONV = ys, ZCOORD = zs  
   
oSurface -> SetProperty, TEXTURE_MAP = oImage, $  
   COLOR = [255, 255, 255] 

oModel -> Add, oSurface  
oView -> Add, oModel 

oModel -> ROTATE, [1, 0, 0], -90  
oModel -> ROTATE, [0, 1, 0], 30  
oModel -> ROTATE, [1, 0, 0], 30

oWindow -> Draw, oView 



end