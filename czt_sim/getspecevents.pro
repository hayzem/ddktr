;******************************************************************************
;returns data with same format to geant output to use these specified events
PRO getspecevents,data,outdata,vmaxnum=maxnum,vxrange=xrange,vyrange=yrange,vzrange=zrange,venrange=enrange,verbose=verbose
  
  ;INPUT
  ;data : geant output
  ;OUTPUT
  ;outdata : output data
  ;OPTIONAL
  ;maxnum : gives maximum number events to be taken
  ;(x,y,z)range : position range for events
  ;enrange : energy range for events
  ;verbose : alerts when program finds an event
  
  if Not keyword_set(maxnum) then maxnum = 100
  if Not keyword_set(xrange) then xrange = [0.,19.54]
  if Not keyword_set(yrange) then yrange = [0.,19.54]
  if Not keyword_set(zrange) then zrange = [0.,5.]
  if Not keyword_set(enrange) then enrange = [121.,123.]
  cntr = 0
  rest = 0
  tempdata = dblarr(5,1000000)

  for i = 1 , 300000 do begin
     geteventinfo,data,i,pos,ener
     size=n_elements(ener)
     sum = 0
     verif=1
     for j = 0, size -1 do begin
        if pos[0,j] lt xrange[0] or pos[0,j] gt xrange[1] then begin
           verif=0
           break
        endif
        if pos[1,j] lt yrange[0] or pos[1,j] gt yrange[1] then begin
           verif=0
           break
        endif
        if pos[2,j] lt zrange[0] or pos[2,j] gt zrange[1] then begin
           verif=0
           break
        endif
        sum = sum + ener[j]
     endfor
     if sum lt enrange[0] or sum gt enrange[1] then verif=0
     if verif eq 1 then begin
        tempdata[0,rest+1:rest+size] = findgen(size)
        tempdata[1:3,rest+1:rest+size] = pos[*,0:size-1]
        tempdata[4,rest+1:rest+size] = ener/1000
        rest = rest + size
        cntr = cntr + 1
        if keyword_set(verbose) then print,cntr, 'event found ....'
     endif
     if cntr eq maxnum then break
  endfor

  outdata = tempdata[*,1:rest]
  print, cntr ,'number of events found ...'

END
;******************************************************************************
