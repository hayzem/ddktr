;*************************************************************************************
;turns given geant output to an event and returns induced charge for all electrodes.
;-------------------------------------------------------------------------------------

PRO main3,data,event,efx,efz,wpa,wpc,wpst,eventnumb,time,qc,qa,qst,plot=plot

;-------------------------------------------------------------------------------------
;Yiğit Dallılar : 21.08.2012
;-------------------------------------------------------------------------------------
;INPUTS
;data        : output from geant which can be read with geteventinfo
;event       : event input (x,z,t)ac -> x,y position and time
;                          w(a,c,st) -> have electrode signals with time
;                          size      -> has how many elements
;efx,efz     : electric field input
;wp(a,c,st)  : weighting potential input
;eventnumb   : index of the event in current data.
;OUTPUTS
;time        : time scale specified in the program
;q(c,a,st)   : induced charged on electrodes with respect to time
;OPTIONAL INPUT
;plot        : plots trajectory of the all clouds
;-------------------------------------------------------------------------------------

;gets event info for all clouds in the (eventnumb)th event.
geteventinfo,data,eventnumb,pos,ener
cloudnumb = n_elements(ener)
Qr_e = ener                     ; only Qr_e because hol_motion returns as negative

;time scaling
timee = findgen(1001)*1e-9
timeh = findgen(1001)*1e-8
time=[timee,timeh[where(timeh gt max(timee))]]

;defining output data
QA = dblarr(16,n_elements(time))
QC = dblarr(16,n_elements(time))
QST = dblarr(16,n_elements(time))

;for all clouds do the weighting potential calculation
FOR i=0,cloudnumb-1 DO BEGIN
   ;control for limit where event data used.
   index = where(pos[2,*] lt 0.85)
   ;does as the old system
   IF index[0] ne -1 THEN BEGIN
      ;new elec_motion calculates induced charge for all electrodes
      elec_motion,0., cnt, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
                  te_actual, xe_actual, ze_actual, QAinde, QCinde, QSTinde, qtinda,qtindc,qtindst,coarsegridpos=[0.75,4.7]     
      te_actual = te_actual[1:cnt]
      t=floor(max(te_actual)*1e9)
      ;clouds get their own energy
      QAinde = Qainde*Qr_e[i]
      QCinde = QCinde*Qr_e[i]
      QSTinde = QSTinde*Qr_e[i] 
      ;interpolation and adding last data beyond the te_actual
      FOR j=0,15 DO BEGIN
         QA[j,0:t] = QA[j,0:t] + interpol(QAinde[j,1:cnt],te_actual,time[0:t])
         QC[j,0:t] = QC[j,0:t] + interpol(QCinde[j,1:cnt],te_actual,time[0:t])
         IF j lt 5 THEN QST[j,0:t] = QST[j,0:t] + interpol(QSTinde[j,1:cnt],te_actual,time[0:t])
         QA[j,t+1:n_elements(time)-1] = QA[j,t+1:n_elements(time)-1] + QAinde[j,cnt]
         QC[j,t+1:n_elements(time)-1] = QC[j,t+1:n_elements(time)-1] + QCinde[j,cnt]
         IF j lt 5 THEN QST[j,t+1:n_elements(time)-1] = QST[j,t+1:n_elements(time)-1] + QSTinde[j,cnt]
      ENDFOR
   ;starting new system
   ENDIF ELSE BEGIN
      ;electron goes to 0.75 mm
       elec_motion,0.75, cnt, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
                  te_actual, xe_actual, ze_actual, QAinde, QCinde, QSTinde, qtinda,qtindc,qtindst,restq,coarsegridpos=[0.75,4.7]
       
       ;adding event data after 0.75 mm
       xpos = round(xe_actual[cnt]/0.005)
       IF xpos gt 3908 THEN xpos = 3908
       IF xpos lt 0 THEN xpos = 0
       cnt2 = event[xpos].size-1
       te_actual = [te_actual[1:cnt],event[xpos].tac[1:cnt2]+te_actual[cnt]]
       xe_actual = [xe_actual[1:cnt],event[xpos].xac[1:cnt2]]
       ze_actual = [ze_actual[1:cnt],event[xpos].zac[1:cnt2]]

       ;the same job as above
       t=floor(max(te_actual)*1e9)
       Qainde2 = dblarr(16,cnt+cnt2+1)
       Qcinde2 = dblarr(16,cnt+cnt2+1)
       Qstinde2 = dblarr(5,cnt+cnt2+1)
       FOR a=0,15 DO BEGIN 
          ;can not combine first and second so it becomes 4 ligne work
          first = Qainde[a,1:cnt]*Qr_e[i]
          second = Qr_e[i]*(event[xpos].wa[a,1:cnt2]*restq+qtinda[a])
          QAinde2[a,1:cnt] = first
          Qainde2[a,cnt+1:cnt+cnt2] = second
          first = Qcinde[a,1:cnt]*Qr_e[i]
          second = Qr_e[i]*(event[xpos].wc[a,1:cnt2]*restq+qtindc[a])
          QCinde2[a,1:cnt] = first
          QCinde2[a,cnt+1:cnt+cnt2] = second
          IF a lt 5 THEN BEGIN 
             first = Qstinde[a,1:cnt]*Qr_e[i]
             second = Qr_e[i]*(event[xpos].wst[a,1:cnt2]*restq+qtindst[a])
             Qstinde2[a,1:cnt] = first
             Qstinde2[a,cnt+1:cnt+cnt2] = second
          ENDIF
       ENDFOR
       ;the same job as above
       FOR j=0,15 DO BEGIN
         QA[j,0:t] = QA[j,0:t] + interpol(QAinde2[j,1:cnt+cnt2],te_actual,time[0:t])
         QC[j,0:t] = QC[j,0:t] + interpol(QCinde2[j,1:cnt+cnt2],te_actual,time[0:t])
         IF j lt 5 THEN QST[j,0:t] = QST[j,0:t] + interpol(QSTinde2[j,1:cnt+cnt2],te_actual,time[0:t])
         QA[j,t+1:n_elements(time)-1] = QA[j,t+1:n_elements(time)-1] + QAinde2[j,cnt+cnt2]
         QC[j,t+1:n_elements(time)-1] = QC[j,t+1:n_elements(time)-1] + Qcinde2[j,cnt+cnt2]
         IF j lt 5 THEN QST[j,t+1:n_elements(time)-1] = QST[j,t+1:n_elements(time)-1] + QStinde2[j,cnt+cnt2]
      ENDFOR
    ENDELSE
   ;plots trajectory of electrons.
   IF keyword_set(plot) THEN trajectory,xe_actual,ze_actual,i
   ;old system for holes
   hol_motion, cnt, pos[0,i], pos[2,i], efx, efz, wpa, wpc, wpst,$
               th_actual, xh_actual, zh_actual, QAindh, QCindh, QSTindh, coarsegridpos=[0.75,4.7]     
   cnt = cnt -1
   th_actual = th_actual[1:cnt]
   t=floor(max(th_actual-1e-6)*1e8)+1000
   if t gt 1800 then t = 1800
   QAindh = Qaindh*Qr_e[i]
   QCindh = QCindh*Qr_e[i]
   QSTindh = QSTindh*Qr_e[i]
   FOR j=0,15 DO BEGIN
      QA[j,0:t] = QA[j,0:t] + interpol(QAindh[j,1:cnt],th_actual,time[0:t])
      QC[j,0:t] = QC[j,0:t] + interpol(QCindh[j,1:cnt],th_actual,time[0:t])
      IF j lt 5 THEN QST[j,0:t] = QST[j,0:t] + interpol(QSTindh[j,1:cnt],th_actual,time[0:t])
      QA[j,t+1:n_elements(time)-1] = QA[j,t+1:n_elements(time)-1] + QAindh[j,cnt]
      QC[j,t+1:n_elements(time)-1] = QC[j,t+1:n_elements(time)-1] + QCindh[j,cnt]
      IF j lt 5 THEN QST[j,t+1:n_elements(time)-1] = QST[j,t+1:n_elements(time)-1] + QSTindh[j,cnt]
   ENDFOR
    IF keyword_set(plot) THEN trajectory,xh_actual,zh_actual,1,/hole
ENDFOR

END
;*********************************************************************************************************
