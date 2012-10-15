;returns data to position and energy arrays for a specific event
PRO geteventinfo,data,evindex,pos,ener

;INPUT
;data  : geant output from binary file
;evindex : index of the event starts from 1 not 0
;------------------------------------
;OUTPUT
;pos   : postion array of the event
;ener  : energy array of the event
;------------------------------------
;NOTE : 
;data[0,*] --> index
;data[1,*] --> position in x
;data[2,*] --> position in y
;data[3,*] --> position in z
;data[4,*] --> energy as keV

;getting numb array to be able to differ events first clouds have 0 index
numb = reform(data[0,*])
numb = [numb,0]
index = where(numb EQ 0.)

;creating position and energy arrays
pos = dblarr(3,index[evindex]-index[evindex-1])
ener = dblarr(index[evindex]-index[evindex-1])

;getting data
FOR i=0,index[evindex]-index[evindex-1]-1 DO BEGIN
   ener[i] = data[4,index[evindex-1]+i]*1000
   FOR j=0,2 DO pos[j,i] = data[1+j,index[evindex-1]+i]
ENDFOR

END
