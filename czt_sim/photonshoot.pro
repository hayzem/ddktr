;******************************************************************************
;creates photons on the source shoots them over the mask and holds
;placement data on the detector for the ones who passes the mask
;------------------------------------------------------------------------------
pro photonshoot,nofphot,mask,maskhit,dethit,photsource=source
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;Yigit Dallilar 14.10.2012
;INPUT
;nofphot     : number of photons to be simulated
;mask        : mask aperture function (dont know maybe use in another program)
;OUTPUT
;maskhit     : mask hit positions
;dethit      : detector hit positions
;OPTIONAL
;photsource  : photon source can be added from outside
;------------------------------------------------------------------------------


  if not keyword_set(source) then $
     source=create_struct('radius',5,'theta',0.5*!pi,'phi',0.25*!pi,'pos',[0,0,8])

;variable initialisation
  radius=[1,1,sqrt(randomu(systime(1),nofphot+1))]*(source.radius)
  angle=[!pi*0.2,-!pi*0.2,randomu(systime(1)+1,nofphot+1)*2*!pi]
  xp=radius[*]*cos(angle[*])
  yp=radius[*]*sin(angle[*])
  refpos=dblarr(2,3)
  pos=dblarr(nofphot,3)
  maskhit=dblarr(nofphot,2)
  maskpix=lonarr(nofphot,2)
  dethit=dblarr(nofphot,2)
  denom=dblarr(3)
  detz=-10
  
;calculation of denominators with two reference positions in the circle 
  for i=0,1 do begin
     refpos[i,0] = xp[i]*sin(source.phi)-yp[i]*sin(source.theta)*cos(source.phi)+ $
                   source.pos[0]
     refpos[i,1] = -xp[i]*cos(source.phi)-yp[i]*sin(source.theta)*sin(source.phi)+ $
                   source.pos[1]
     refpos[i,2] = yp[i]*cos(source.theta)+source.pos[2]
  endfor
  denom[2]=(refpos[1,0]-source.pos[0])*(refpos[0,1]-source.pos[1]) $
           -(refpos[1,1]-source.pos[1])*(refpos[0,0]-source.pos[0])      
  denom[0]=(refpos[1,1]-source.pos[1])*(refpos[0,2]-source.pos[2]) $
           -(refpos[1,2]-source.pos[2])*(refpos[0,1]-source.pos[1])
  denom[1]=(refpos[1,2]-source.pos[2])*(refpos[0,0]-source.pos[0]) $
           -(refpos[1,0]-source.pos[0])*(refpos[0,2]-source.pos[2])
  
;cartesian coordinates and denominator calculation
  for i=0,nofphot-1 do begin
     pos[i,0] = xp[i+2]*sin(source.phi)-yp[i+2]*sin(source.theta)*cos(source.phi)+ $
                source.pos[0]
     pos[i,1] = -xp[i+2]*cos(source.phi)-yp[i+2]*sin(source.theta)*sin(source.phi)+ $
                source.pos[1]
     pos[i,2] = yp[i+2]*cos(source.theta)+source.pos[2]
  endfor

;mask & detector hit positions z should be zero & detz
  for i=0,nofphot-1 do begin
     maskhit[i,0]=-(denom[0]/denom[2])*pos[i,2]+pos[i,0]
     maskhit[i,1]=-(denom[1]/denom[2])*pos[i,2]+pos[i,1]
     maskpix[i,0]=where(maskhit[i,0] le mask.pos[*,0,0]+mask.pixsize*0.5 and $
                maskhit[i,0] ge mask.pos[*,0,0]-mask.pixsize*0.5)
     maskpix[i,1]=where(maskhit[i,1] le mask.pos[0,*,1]+mask.pixsize*0.5 and $
                maskhit[i,1] ge mask.pos[0,*,1]-mask.pixsize*0.5)                
  endfor

  for i=0,nofphot-1 do begin
     dethit[i,0]=((denom[0]/denom[2])*(-pos[i,2]+detz)+pos[i,0])* $
                 mask.apert[maskpix[i,0],maskpix[i,1]]
     dethit[i,1]=((denom[1]/denom[2])*(-pos[i,2]+detz)+pos[i,1])* $
                 mask.apert[maskpix[i,0],maskpix[i,1]]
  endfor

end
;******************************************************************************
