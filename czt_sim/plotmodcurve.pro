;**************************************************************************
;get curve variables from variables.txt and plots the curve
;--------------------------------------------------------------------------

function equation,xx,cvar,const

  return,(-cvar[0]/xx+cvar[1])*exp(-xx^cvar[2]/cvar[3])+const

end 

pro plotmodcurve,andno,const,plot=plot,print=print,var=cvar,color=ccol
  
;--------------------------------------------------------------------------
;Yiğit Dallılar 28.06.2012
;--------------------------------------------------------------------------
;INPUT
;andno   : choosen anode ( from 0 to 15 )
;const   : shift in cathode energy direction
;OPTIONAL INPUT
;plot    : plot / oplot
;print   : prints cvar
;cvar    : optional cvar input
;ccol    : color of the line as integer
;--------------------------------------------------------------------------

andno = andno - 1

if not keyword_set(cvar) then begin 
   readvariables,'variables.txt',cvar
   cvar = reform (cvar[andno,*])
endif

xx = findgen(750)
xx = xx + 1
xx = xx / 5

if keyword_set(print) then print,cvar

if not keyword_set(ccol) then begin
   if keyword_set(plot) then plot,xx,equation(xx,cvar,const) $
   else oplot,xx,equation(xx,cvar,const)
endif else begin
   if keyword_set(plot) then plot,xx,equation(xx,cvar,const),color=ccol $
   else oplot,xx,equation(xx,cvar,const),color=ccol
endelse

end
;**************************************************************************
