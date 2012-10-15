;******************************************************************************
;gets all the mask aperture function and pixel positions
;------------------------------------------------------------------------------
pro getmask,array,num,mask,pixsize=sizepix
;------------------------------------------------------------------------------

  maskarray,array,num,maskarr,pixsize=sizepix

  mask=create_struct('apert',bytarr(array[0]*num+1,array[1]*num+1), $
                    'pos',dblarr(array[0]*num+1,array[1]*num+1,2))

  for i=0,array[0]-1 do begin
     for j=0,array[1]-1 do begin
        for k=0,num-1 do begin
           for l=0,num-1 do begin
              mask.pos[i*num+k,j*num+l,*]=maskarr[i,j].pos[k,l,*]
              mask.apert[i*num+k,j*num+l]=maskarr[i,j].apert[k,l]
           endfor
        endfor
     endfor
  endfor

  mask.apert[0,*]=0
  mask.apert[array[0]*num,*]=0
  mask.apert[*,array[1]*num]=0
  mask.pos[array[0]*num,*,0]=mask.pos[array[0]*num-1,*,0]+sizepix
  mask.pos[*,array[1]*num,1]=mask.pos[*,array[1]*num-1,1]-sizepix
  mask.pos[array[0]*num,*,1]=mask.pos[array[0]*num-1,*,1]
  mask.pos[*,array[1]*num,0]=mask.pos[*,array[1]*num-1,0]

  for i=0,num*array[0] do begin
     for j=0,num*array[1] do begin
        plotmura,mask.apert[i,j],mask.pos[i,j,*],sizepix
     endfor
  endfor

end
;******************************************************************************
