PRO gettrajectory,efx,efz,wpa,wpc,wpst,event

event=create_struct('xac',dblarr(500),'zac',dblarr(500),'tac',dblarr(500),'wa',dblarr(16,500),'wc',dblarr(16,500), 'wst',dblarr(5,500),'size',0)
event=replicate(event,3909)

FOR i=0,3908 DO BEGIN
  elec_motion,0.,cnt,i*0.005,0.75,efx,efz,wpa,wpc,wpst,t,x,z,qaind,qcind,qstind,coarsegridpos=[1.1,4]
  asize = n_elements(t)-1
  event[i].xac[0:asize-1] = x[1:asize]
  event[i].zac[0:asize-1] = z[1:asize]
  event[i].tac[0:asize-1] = t[1:asize]
  event[i].wa[*,0:asize-1] = qaind[*,1:asize]
  event[i].wc[*,0:asize-1] = qcind[*,1:asize]
  event[i].wst[*,0:asize-1] = qstind[*,1:asize]
  event[i].size = asize
ENDFOR

END
