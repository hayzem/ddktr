;calculates charge distribution with position interval 5
;INPUT
;----------------------------
;sigma : sigma of the cloud getting from cloudsize.pro
;num   : number of grids to calculate the charge stayed of border
;added to border grids
;OUTPUT
;----------------------------
;calc  : array of calculation with size of num value

;function for rieman integral
FUNCTION integ,x,f,l
  int=0.1
  steps=((l-f)/int)
  result=0
  sum=dblarr(2)
  FOR i=0,steps-1 DO BEGIN
     FOR j=0,1 DO sum[j]=(1/(sqrt(2*!pi*x^2)))*exp(-(f+(int*(i+j)))^2/(2*x^2))
     result=result+(sum[0]+sum[1])*int/2
  ENDFOR
RETURN,result
END

PRO grid_dist,sigma,num,calc

  ;makes calculation
  sigma = sigma*1000000
  total=0
  calc=dblarr(num)
  FOR i=0,num-1 DO BEGIN
     calc[i]=integ(sigma,-num*2.5+i*5,-num*2.5+(i+1)*5)
     total=total+calc[i]
  ENDFOR

  ;add out of border charges to last grids
  calc[0]=calc[0] + (1-total)/2
  calc[n_elements(calc)-1] = calc[n_elements(calc)-1] + (1-total)/2

END
