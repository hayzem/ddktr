;*****************************************************************************
;returns posxz and energy datas
;-----------------------------------------------------------------------------

PRO getposxzen,count,data,posxz,en
  
;-----------------------------------------------------------------------------
;Yiğit Dallılar 27.08
;-----------------------------------------------------------------------------
;INPUTS
;count  : number of events to be included
;data   : geant output data
;OUTPUTS
;posxz  : (x,z) position datas
;en     : energy data
;-----------------------------------------------------------------------------

  ind = where(data[0,*] eq 0)
  
  posxz = dblarr(2,count)
  posxz[0,*] = data[1,ind[0:count-1]]
  posxz[1,*] = data[3,ind[0:count-1]]

  en = dblarr(count)
  FOR i=0,count-1 DO BEGIN
     cn = ind[i+1]-ind[i]
     ener = data[4,ind[i]:ind[i+1]-1]
     sum = 0
     FOR j = 0 , cn -1 DO sum = sum + ener[j]
     en[i] = sum*1000
  ENDFOR
  
END
;*****************************************************************************
