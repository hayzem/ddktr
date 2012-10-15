;******************************************************************************
;gives array of mask
;------------------------------------------------------------------------------
pro maskarray,array,num,mask,pixsize=sizepix,plotarray=plotarray
;------------------------------------------------------------------------------
;yigit dallilar 11.10.2012
;INPUT
;array     : desired array for the mask
;num       : prime number for mura generation
;OUTPUT
;mask      : mask struct aperture function and positions of the pixels
;OPTIONAL
;pixsize   : determines pixel size
;plotarray : plots the array
;------------------------------------------------------------------------------

  muragen,num,apert,pos,pixsize=sizepix

  if keyword_set(plotarray) then parray=1 else parray=0
  if not keyword_set(sizepix) then sizepix=1
  nofmask=array[0]*array[1] 
  len=sqrt(n_elements(apert))
  mask=create_struct('apert',apert,'pos',pos)
  mask=replicate(mask,array[0],array[1])  
  midpos=dblarr(array[0],array[1],2)
  
  for i=0,array[0]-1 do midpos[i,*,1]=-findgen(array[1])+(array[1]-1)/2.
  for i=0,array[1]-1 do midpos[*,i,0]=+findgen(array[0])-(array[0]-1)/2.
  midpos=midpos*len*sizepix

  for i=0,array[0]-1 do begin
     for j=0,array[1]-1 do begin
        mask[i,j].pos[*,*,0]=pos[*,*,0]+midpos[i,j,0]
        mask[i,j].pos[*,*,1]=pos[*,*,1]+midpos[i,j,1]
        papert=mask[i,j].apert
        ppos=mask[i,j].pos
        if parray eq 1 then plotmura,papert,ppos,sizepix
     endfor
  endfor  

end
;******************************************************************************
