PRO main2,data,event,efx,efz,wpa,wpc,wpst,eventnumb,time,qc,qa,qst, $
          qainde,qaindh,qcinde,qcindh,qstinde,qstindh,clouddiv=divcloud, $
          calct=tcalc,divide=divide,plot=plot

IF NOT keyword_set(divcloud) THEN divcloud = 1

temax=1001
thmax=601
inte=1
inth=1

geteventinfo,data,eventnumb,pos,ener
cloudnumb = n_elements(ener)
cloud = create_struct('xe_actual',dblarr(temax),'ze_actual',dblarr(temax),'te_actual',dblarr(temax))
holes = create_struct('xh_actual',dblarr(thmax),'zh_actual',dblarr(thmax),'th_actual',dblarr(thmax))
cloud = replicate (cloud,cloudnumb)
holes = replicate (holes,cloudnumb)
taue = 3e-6                     ;3e-6
tauh = 1e-6
Qr_e = ener                     ;???????? 2 choosen as bandgap !!!multiply by e
QAinde = dblarr(16,temax)
QCinde = dblarr(16,temax)
QSTinde = dblarr(5,temax)
Qr_h = -ener                    ;???????? 2 choosen as bandgap !!!multiply by e
QAindh = dblarr(16,thmax)
QCindh = dblarr(16,thmax)
QSTindh = dblarr(5,thmax)
q = dblarr(cloudnumb)

timee = findgen(temax+1)*1e-9*inte
timeh = findgen(thmax+1)*1e-8

IF NOT keyword_set(tcalc) THEN BEGIN
   tcalc = dblarr(divcloud,temax)
   cloudsize,sigma,timearr,ftime=1e-6
   FOR i=0,temax-1 DO BEGIN 
      grid_dist,sigma[i],divcloud,calc
      tcalc[0:divcloud-1,i] = calc
   ENDFOR
ENDIF

IF NOT keyword_set(divide) THEN BEGIN
   FOR i=0,cloudnumb-1 DO BEGIN
      electron_motion,0.,pos[0,i],pos[2,i],efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
      lene = floor(max(te_actual)*1e9)/inte
      xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
      ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
      FOR j=0,lene DO BEGIN
         cloud[i].xe_actual[j]=xe_actual[j]
         IF cloud[i].xe_actual[j] gt 19.54 THEN cloud[i].xe_actual[j] = 19.54
         IF cloud[i].xe_actual[j] lt 0 THEN cloud[i].xe_actual[j] = 0
         cloud[i].ze_actual[j]=ze_actual[j]
      ENDFOR
      FOR j=lene+1,temax-1 DO BEGIN
         cloud[i].xe_actual[j]=xe_actual[lene]
         cloud[i].ze_actual[j]=ze_actual[lene]
      ENDFOR
   ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENDIF ELSE BEGIN
   t = intarr(cloudnumb*divcloud)
   dvdcloud = create_struct('xe_actual',dblarr(temax),'ze_actual',dblarr(temax),'te_actual',dblarr(temax))
   dvdcloud = replicate(dvdcloud,cloudnumb*divcloud)
   index = where (pos[2,*] le 1.1,count)
   IF count eq 0 THEN BEGIN
      FOR i=0,cloudnumb-1 DO BEGIN
         electron_motion,1.,pos[0,i],pos[2,i],efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
         lene = floor(max(te_actual)*1e9/inte)
         xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
         ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
         FOR k=0,divcloud-1  DO BEGIN 
            t[divcloud*i+k]=lene
            FOR j=0,lene DO BEGIN
               dvdcloud[divcloud*i+k].xe_actual[j]=xe_actual[j]+(k-(divcloud-1)/2)*0.005
               ;should be inside the detector
               IF dvdcloud[divcloud*i+k].xe_actual[j] gt 19.54 THEN dvdcloud[divcloud*i+k].xe_actual[j] = 19.54
               IF dvdcloud[divcloud*i+k].xe_actual[j] lt 0 THEN dvdcloud[divcloud*i+k].xe_actual[j] = 0
               dvdcloud[divcloud*i+k].ze_actual[j]=ze_actual[j]
            ENDFOR
         ENDFOR  
      ENDFOR

      FOR i=0,cloudnumb*divcloud-1 DO BEGIN
         ;electron_motion,0.,dvdcloud[i].xe_actual[t[i]],1.07,efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
         xe_actual=event[round(dvdcloud[i].xe_actual[t[i]]/0.005)].xac[0:event[i].size]
         ze_actual=event[round(dvdcloud[i].xe_actual[t[i]]/0.005)].zac[0:event[i].size]
         te_actual=event[round(dvdcloud[i].xe_actual[t[i]]/0.005)].tac[0:event[i].size]
         lene = floor(max(te_actual)*1e9/inte)
         xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
         ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
         FOR j=t[i]+1,t[i]+lene+1 DO BEGIN
            dvdcloud[i].xe_actual[j]=xe_actual[j-t[i]-1]
            IF dvdcloud[i].xe_actual[j] gt 19.54 THEN dvdcloud[i].xe_actual[j] = 19.54
            IF dvdcloud[i].xe_actual[j] lt 0 THEN dvdcloud[i].xe_actual[j] = 0
            dvdcloud[i].ze_actual[j]=ze_actual[j-t[i]-1]
         ENDFOR
         FOR j=t[i]+lene+1,temax-1 DO BEGIN
            dvdcloud[i].xe_actual[j]=xe_actual[lene]
            dvdcloud[i].ze_actual[j]=ze_actual[lene]
         ENDFOR
      ENDFOR

   ENDIF ELSE BEGIN

      FOR i=0,cloudnumb-1 DO BEGIN
         FOR k=0,divcloud-1 DO BEGIN
            place = pos[0,i]+(k-(divcloud-1)/2)*0.005
            IF place gt 19.54 THEN place = 19.54
            IF place lt 0 THEN place = 0
            electron_motion,0.,place,pos[2,i],efx,efz,a,b,c,te_actual,xe_actual,ze_actual,coarsegridpos=[1.025,4.5]
            lene = floor(max(te_actual)*1e9/inte)
            xe_actual=interpol(xe_actual,te_actual,timee[0:lene])
            ze_actual=interpol(ze_actual,te_actual,timee[0:lene])
            ind = where(dvdcloud[divcloud*i+k].xe_actual ne 0.,count)
            FOR j=count+1,count+lene+1 DO BEGIN
               dvdcloud[i].xe_actual[j]=xe_actual[j-count-1]
               IF dvdcloud[i*divcloud+k].xe_actual[j] gt 19.54 THEN dvdcloud[i].xe_actual[j] = 19.54
               IF dvdcloud[i*divcloud+k].xe_actual[j] lt 0 THEN dvdcloud[i].xe_actual[j] = 0
               dvdcloud[i*divcloud+k].ze_actual[j]=ze_actual[j-count-1]
            ENDFOR
            FOR j=count+lene+2,temax-1 DO BEGIN
               dvdcloud[i*divcloud+k].xe_actual[j]=xe_actual[lene]
               dvdcloud[i*divcloud+k].ze_actual[j]=ze_actual[lene]
            ENDFOR
         ENDFOR
      ENDFOR
   ENDELSE
ENDELSE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FOR i=0,cloudnumb-1 DO BEGIN
   hole_motion,pos[0,i],pos[2,i],efx,efz,a,b,c,th_actual,xh_actual,zh_actual,coarsegridpos=[1.025,4.5]
   lenh = floor(max(th_actual)*1e8)
   IF lenh gt thmax-1 THEN lenh = thmax-1
   xh_actual=interpol(xh_actual,th_actual,timeh[0:lenh])
   zh_actual=interpol(zh_actual,th_actual,timeh[0:lenh])
   FOR j=0,lenh DO BEGIN
      holes[i].xh_actual[j]=xh_actual[j]
      IF holes[i].xh_actual[j] gt 19.54 THEN holes[i].xh_actual[j] = 19.54
      IF holes[i].xh_actual[j] lt 0 THEN holes[i].xh_actual[j] = 0
      holes[i].zh_actual[j]=zh_actual[j]
   ENDFOR
   FOR j=lenh,thmax-1 DO BEGIN
      holes[i].xh_actual[j]=xh_actual[lenh]
      holes[i].zh_actual[j]=zh_actual[lenh]
   ENDFOR
ENDFOR

;**********************************************************************************************

IF keyword_set(plot) THEN BEGIN
   IF NOT keyword_set(divide) THEN BEGIN
      FOR i=0,cloudnumb-1 DO BEGIN
         xe_actual = reform(cloud[i].xe_actual[where(cloud[i].xe_actual ne 0 )])
         ze_actual = reform(cloud[i].ze_actual[where(cloud[i].ze_actual ne 0 )])
         trajectory,xe_actual,ze_actual,i
      ENDFOR
   ENDIF ELSE BEGIN
      FOR i=0,cloudnumb*divcloud-1 DO BEGIN
         xe_actual = reform(dvdcloud[i].xe_actual[where(dvdcloud[i].xe_actual ne 0 )])
         ze_actual = reform(dvdcloud[i].ze_actual[where(dvdcloud[i].ze_actual ne 0 )])
         trajectory,xe_actual,ze_actual,i
      ENDFOR
   ENDELSE
   FOR i=0,cloudnumb-1 DO BEGIN
      xe_actual = reform(holes[i].xh_actual[where(holes[i].xh_actual ne 0 )])
      ze_actual = reform(holes[i].zh_actual[where(holes[i].zh_actual ne 0 )])
      trajectory,xe_actual,ze_actual,1,/hole
   ENDFOR
ENDIF

;**********************************************************************************************
QAindte=dblarr(16,cloudnumb*divcloud)
QCindte=dblarr(16,cloudnumb*divcloud)
QSTindte=dblarr(5,cloudnumb*divcloud)

IF NOT keyword_set(divide) THEN BEGIN
   FOR m=0,temax-1 DO BEGIN
      FOR i=0,cloudnumb-1 DO BEGIN
         x=floor(cloud[i].xe_actual[m]/0.005)
         z=floor(cloud[i].ze_actual[m]/0.005)
         IF z gt 2 THEN q[i] = Qr_e[i]*exp(-timee[m+1]/taue)
         FOR k=0,divcloud-1 DO BEGIN
            place = x+k-(divcloud-1)/2
            IF place gt 3908 THEN place = 3908
            IF place lt 0 THEN place = 0
            IF z gt 2 THEN BEGIN 
               trapq = Qr_e[i]*(exp(-timee[m]/taue)-exp(-timee[m+1]/taue))            
               FOR j=0,15 DO BEGIN
                  QAindte[j,divcloud*i+k] = QAindte[j,divcloud*i+k] + wpa[j,x,z]*calc[k]*trapq
                  QCindte[j,divcloud*i+k] = QCindte[j,divcloud*i+k] + wpc[j,x,z]*calc[k]*trapq
                  IF (j lt 5) THEN QSTindte[j] = QSTindte[j] + wpst[j,x,z]*calc[k]*trapq
               ENDFOR
            ENDIF
            FOR j=0,15 DO BEGIN
               QAinde[j,m] = QAinde[j,m] + QAindte[j,divcloud*i+k] + wpa[j,place,z]*tcalc[k,m]*q[i]
               QCinde[j,m] = QCinde[j,m] + QCindte[j,divcloud*i+k] + wpc[j,place,z]*tcalc[k,m]*q[i]
               IF (j lt 5) THEN QSTinde[j,m] = QSTinde[j,m] + QSTindte[j,divcloud*i+k] + wpst[j,place,z]*tcalc[k,m]*q[i]
            ENDFOR
         ENDFOR
      ENDFOR
   ENDFOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENDIF ELSE BEGIN
   FOR m=0,temax-1 DO BEGIN
      FOR i=0,cloudnumb-1 DO BEGIN
         IF t[i]*1e-9 le timee[m] THEN calc = tcalc[*,m] ELSE calc = tcalc[*,t[i]]
         FOR k=0,divcloud-1 DO BEGIN
            x=floor(dvdcloud[divcloud*i+k].xe_actual[m]/0.005)
            z=floor(dvdcloud[divcloud*i+k].ze_actual[m]/0.005)
            IF z gt 2 THEN q[i] = Qr_e[i]*exp(-timee[m]/taue)
            IF z gt 2 THEN BEGIN
               trapq = Qr_e[i]*(exp(-timee[m]/taue)-exp(-timee[m+1]/taue))            
               FOR j=0,15 DO BEGIN
                  QAindte[j,divcloud*i+k] = QAindte[j,divcloud*i+k] + wpa[j,x,z]*calc[k]*trapq
                  QCindte[j,divcloud*i+k] = QCindte[j,divcloud*i+k] + wpc[j,x,z]*calc[k]*trapq
                  IF (j lt 5) THEN QSTindte[j,divcloud*i+k] = QSTindte[j,divcloud*i+k] + wpst[j,x,z]*calc[k]*trapq
               ENDFOR
            ENDIF
            FOR j=0,15 DO BEGIN
               QAinde[j,m] = QAinde[j,m] + QAindte[j,divcloud*i+k] + wpa[j,x,z]*calc[k]*q[i]
               QCinde[j,m] = QCinde[j,m] + QCindte[j,divcloud*i+k] + wpc[j,x,z]*calc[k]*q[i]
               IF (j lt 5) THEN QSTinde[j,m] = QSTinde[j,m] + QSTindte[j,divcloud*i+k] + wpst[j,x,z]*calc[k]*q[i]
            ENDFOR
         ENDFOR
      ENDFOR
   ENDFOR
ENDELSE

QAindth=dblarr(16,cloudnumb)
QCindth=dblarr(16,cloudnumb)
QSTindth=dblarr(5,cloudnumb)

FOR m=0,thmax-1 DO BEGIN
   FOR i=0,cloudnumb-1 DO BEGIN
      x=floor(holes[i].xh_actual[m]/0.005)
      z=floor(holes[i].zh_actual[m]/0.005)
      IF holes[i].zh_actual[m] lt 4.99 THEN q[i] = Qr_h[i]*exp(-timeh[m]/tauh)
      IF holes[i].zh_actual[m] lt 4.99 THEN BEGIN
         trapq = Qr_h[i]*(exp(-timeh[m]/tauh)-exp(-timeh[m+1]/tauh))  
         FOR j=0,15 DO BEGIN
            QAindth[j,i] = QAindth[j,i] + wpa[j,x,z]*trapq
            QCindth[j,i] = QCindth[j,i] + wpc[j,2555,z]*trapq
            IF (j lt 5) THEN QSTindth[j,i] = QSTindth[j,i] + wpst[j,x,z]*trapq
         ENDFOR
      ENDIF
      FOR j=0,15 DO BEGIN
         QAindh[j,m] = QAindh[j,m] + QAindth[j,i] + wpa[j,x,z]*q[i]
         QCindh[j,m] = QCindh[j,m] + QCindth[j,i] + wpc[j,2555,z]*q[i]
         IF (j lt 5) THEN QSTindh[j,m] = QSTindh[j,m] + QSTindth[j,i] + wpst[j,x,z]*q[i]
      ENDFOR
   ENDFOR
ENDFOR

timee = timee[0:n_elements(timee)-2]
timeh = timeh[0:n_elements(timeh)-2]
time = [timee, timeh[where(timeh gt max(timee))]]

qa=dblarr(16,n_elements(time))
qc=dblarr(16,n_elements(time))
qst=dblarr(5,n_elements(time))

FOR i=0,15 DO BEGIN
   qa[i,0:n_elements(timee)-1] = qainde[i,*] 
   qa[i,n_elements(timee)-1:n_elements(time)-1] = qainde[i,n_elements(timee)-1]
   qa[i,*] = qa[i,*] + interpol(qaindh[i,*],timeh,time)
   qc[i,0:n_elements(timee)-1] = qcinde[i,*] 
   qc[i,n_elements(timee)-1:n_elements(time)-1] = qcinde[i,n_elements(timee)-1]
   qc[i,*] = qc[i,*] + interpol(qcindh[i,*],timeh,time)
   if i lt 5 then begin
      qst[i,0:n_elements(timee)-1] = qstinde[i,*] 
      qst[i,n_elements(timee)-1:n_elements(time)-1] = qstinde[i,n_elements(timee)-1]
      qst[i,*] = qst[i,*] + interpol(qstindh[i,*],timeh,time)
   endif
ENDFOR

IF 1 eq 0 then begin
qa=dblarr(16,thmax-1)
qc=dblarr(16,thmax-1)
qst=dblarr(5,thmax-1)

FOR i=0,15 DO BEGIN
   qa[i,*] = interpol(qainde[i,*],timee[0:temax-2],timeh[0:thmax-2]) + qaindh[i,*]
   qc[i,*] = interpol(qcinde[i,*],timee[0:temax-2],timeh[0:thmax-2]) + qcindh[i,*]
   IF i lt 5 THEN qst[i,*] = interpol(qstinde[i,*],timee[0:temax-2],timeh[0:thmax-2]) + qstindh[i,*]
ENDFOR

time=timeh[0:thmax-1]
endif

END
