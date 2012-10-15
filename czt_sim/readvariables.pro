;*************************************************************************
;read variables from a file for depth correction
;-------------------------------------------------------------------------

pro readvariables,fname,cvar
  
;-------------------------------------------------------------------------
;Yiğit Dallılar 28.02.2012
;-------------------------------------------------------------------------
;INPUT 
;fname    :  name of the input file
;OUTPUT
;cvar     :  variables for the depth correction equation
;-------------------------------------------------------------------------
  
  openr,1,fname
  
  cvar = dblarr(16,5)

  while ~ eof(1) do begin
     str = ''
     readf,1,str
     aa = byte(str)
     ;stop
     if aa[0] ne 35 then begin
        str = strsplit(str,' ',/extract)
        ;stop
        cvar(long(str[0]),0:4) = double(str[1:5])
     endif
  endwhile
  
  close,1

end
;**************************************************************************
