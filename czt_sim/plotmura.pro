;******************************************************************************
;plots mura to the screen
;------------------------------------------------------------------------------
pro plotmura,mura,pos,sizepix
;------------------------------------------------------------------------------
;Yigit Dallilar 11.11.2012
;INPUT
;mura    : mura aperture function 
;pos     : positions of the pixels
;sizepix : pixel size
;------------------------------------------------------------------------------

  num=sqrt(n_elements(mura))
  for i=0,num-1 do begin
     for j=0,num-1 do begin
        if mura[i,j] eq 0 then begin
           xx=pos[i,j,0]
           yy=pos[i,j,1]
           polyfill,[xx-0.5*sizepix,xx+0.5*sizepix, $
                     xx+0.5*sizepix,xx-0.5*sizepix], $
                    [yy-0.5*sizepix,yy-0.5*sizepix, $
                     yy+0.5*sizepix,yy+0.5*sizepix],color=white
        endif
     endfor
  endfor

end
;******************************************************************************
