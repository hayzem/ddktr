pro test,max,int,res
  
  res = dblarr(max+1)
  res[0] = 1
  For i=1,max do begin
     res[i] = res[i-1] * exp(-i/int)
  endfor

end
