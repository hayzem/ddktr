;************************************************************************
;to visualise posxz and evlist datas
;------------------------------------------------------------------------

PRO analyse,posxz,ener,evlist,rangex=rx,rangez=rz,grange=gry,enrange=ren,gthick=gth,cathodeno=catno, $
            anodeno=andno,anthr=an_thr,steerno=stno,symbol=sym,option=vopt,help=help,var=cvar
  
;------------------------------------------------------------------------
;Yiğit Dallılar 22.08.2012
;------------------------------------------------------------------------
;INPUT
;posxz      :  x and z positions of the first clouds
;evlist     :  evlist data as general output
;OPTIONAL
;range(x,z) :  x and z range for the events
;grange     :  result range for the graph
;cathodeno  :  cathode index starting from left to right (1,2,...,16)
;anodeno    :  anode index starting from left to right (1,2,....,16)
;steerno    :  index for middle three steering electrodes from left to right
;symbol     :  symbol for the plot procedure
;gthick     :  thickness for the plotting symbol
;option     :  options for the program
;cvar       :  variables  for depth correction formula
;     *use positions as parameter : 
;       - 0  :  cathode energies with respect to z
;       - 1  :  anode energies with respect to z
;       - 2  :  anode energies with respect to x
;       - 3  :  anode/cathode ratio with respect to z
;       - 4  :  cathode/anode ratio with respect to z
;       - 5  :  steering electrode energies with respect to z
;       - 6  :  steering electrode energies with respect to x
;     *use energies as parameter :
;       - 10 :  specified anode energy vs. previous neighbour anode energy
;       - 11 :  specified anode energy vs. specified cathode energy
;       - 12 :  specifide anode energy vs. specified steering electrode energy
;       - 13 :  specified steering energy vs. specified cathode energy
;       - 14 :  max anode energy vs. specified cathode energy
;       - 15 :  specified cathode energy vs. anode ratio 
;     *plot energy spectrums :
;       - 20 :  for specified anode
;       - 21 :  for specified cathode
;       - 22 :  for specified steering electrode
;       - 23 :  max anode energy
;       - 24 :  summed neighbour anodes
;     *depth corrected spectrum
;       - 30 :  for specified anode
;------------------------------------------------------------------------
;NOTES 
;-just to remember for evlist : 1,16 cathodes / 17,32 anodes / 33,35 steering..
;-option 2 and 6 can give an idea about the positions of electrodes 
;------------------------------------------------------------------------
;IMPORTANT UPDATES
;*24.08.2012:
;-anode threshold added. Choses events which are greater than
;threshold value.(the idea is to exclude clean steering electrode events.)
;------------------------------------------------------------------------

  if not keyword_set(rx) then rx = [0.,19.54]
  if not keyword_set(rz) then rz = [0.,5.]
  if not keyword_set(ren) then ren = [0.,150.]
  if not keyword_set(gth) then gth = 1
  if not keyword_set(catno) then catno = 11
  if not keyword_set(andno) then andno = 10
  if not keyword_set(stno) then stno = 2
  if not keyword_set(sym) then sym = 3
  if not keyword_set(vopt) then vopt = 0
  if not keyword_set(an_thr) then an_thr = 0
  if not keyword_set(cvar) then begin
     readvariables,'variables.txt',cvar
     cvar = reform (cvar[andno-1,*])
  endif

  if keyword_set(help) then begin
     readfw,'analyse.txt'
  endif else begin

  ;for anode no 
  andno = andno + 16
  stno = stno + 32

  index = where (posxz[0,*] gt rx[0] and posxz[0,*] lt rx[1] and posxz[1,*] gt rz[0] and posxz[1,*] lt rz[1] and evlist[andno,*] gt an_thr and $
                 ener gt ren[0] and ener lt ren[1])  

  xx = posxz[0,index]
  zz = posxz[1,index]

  cnt = n_elements(vopt) 
  ;for now 
  cnt = 1
  
  ;does all the options as specified above
  for i=0, cnt -1 do begin

     case vopt[i] of

        0 : begin
           if keyword_set(gry) then begin
               plot,zz,evlist[catno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                    ytitle='cathode '+strtrim(catno,1)+' (keV)',xtitle='distance from bottom (mm)'
            endif else begin
               plot,zz,evlist[catno,index],xrange=rz,psym=sym,thick=gth, $
                    ytitle='cathode '+strtrim(catno,1)+' (keV)',xtitle='distance from bottom (mm)'
            endelse
        end
        
        1 : begin
           if keyword_set(gry) then begin
              plot,zz,evlist[andno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                   ytitle='anode '+strtrim(andno-16,1)+' (keV)',xtitle='distance from bottom (mm)'
           endif else begin
              plot,zz,evlist[andno,index],xrange=rz,psym=sym,thick=gth, $
                   ytitle='anode '+strtrim(andno-16,1)+' (keV)',xtitle='distance from bottom (mm)'
           endelse
        end
        
        2 : begin
           if keyword_set(gry) then begin
              plot,xx,evlist[andno,index],xrange=rx,psym=sym,yrange=gry,thick=gth, $
                   ytitle='anode '+strtrim(andno-16,1)+' (keV)',xtitle='distance from left (mm)'
           endif else begin
              plot,xx,evlist[andno,index],xrange=rx,psym=sym,thick=gth, $
                   ytitle='anode '+strtrim(andno-16,1)+' (keV)',xtitle='distance from left (mm)'
           endelse
        end
        
        3 : begin
           if keyword_set(gry) then begin
              plot,zz,evlist[andno,index]/evlist[catno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                   ytitle='anode'+strtrim(andno-16,1)+'/cathode'+strtrim(catno,1)+' ratio',xtitle='distance from bottom (mm)'
           endif else begin
              plot,zz,evlist[andno,index]/evlist[catno,index],xrange=rz,psym=sym,thick=gth, $
                   ytitle='anode'+strtrim(andno-16,1)+'/cathode'+strtrim(catno,1)+' ratio',xtitle='distance from bottom (mm)'
           endelse
        end

        4 : begin
           if keyword_set(gry) then begin
              plot,zz,evlist[catno,index]/evlist[andno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+'/anode'+strtrim(andno-16,1)+' ratio',xtitle='distance from bottom (mm)'
           endif else begin
              plot,zz,evlist[catno,index]/evlist[andno,index],xrange=rz,psym=sym,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+'/anode'+strtrim(andno-16,1)+' ratio',xtitle='distance from bottom (mm)'
           endelse
        end

         5 : begin
           if keyword_set(gry) then begin
              plot,zz,evlist[stno,index],xrange=rz,psym=sym,yrange=gry,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='distance from bottom (mm)'
           endif else begin
              plot,zz,evlist[stno,index],xrange=rz,psym=sym,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='distance from bottom (mm)'
           endelse
        end

         6 : begin
           if keyword_set(gry) then begin
              plot,xx,evlist[stno,index],xrange=rx,psym=sym,yrange=gry,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='distance from left (mm)'
           endif else begin
              plot,xx,evlist[stno,index],xrange=rx,psym=sym,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='distance from left (mm)'
           endelse
        end

         10 : begin
           if keyword_set(gry) then begin
              plot,evlist[andno,index],evlist[andno-1,index],psym=sym,yrange=gry,thick=gth, $
                   ytitle='anode'+strtrim(andno-17,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endif else begin
              plot,evlist[andno,index],evlist[andno-1,index],psym=sym,thick=gth, $
                   ytitle='anode'+strtrim(andno-17,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endelse
        end

        11 : begin
           if keyword_set(gry) then begin
              plot,evlist[andno,index],evlist[catno,index],psym=sym,yrange=gry,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endif else begin
              plot,evlist[andno,index],evlist[catno,index],psym=sym,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endelse
        end

         12 : begin
           if keyword_set(gry) then begin
              plot,evlist[andno,index],evlist[stno,index],psym=sym,yrange=gry,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endif else begin
              plot,evlist[andno,index],evlist[stno,index],psym=sym,thick=gth, $
                   ytitle='steer'+strtrim(stno-32,1)+' (keV)',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
           endelse
        end

         13 : begin
           if keyword_set(gry) then begin
              plot,evlist[stno,index],evlist[catno,index],psym=sym,yrange=gry,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='steer'+strtrim(stno,1)+' (keV)'
           endif else begin
              plot,evlist[stno,index],evlist[catno,index],psym=sym,thick=gth, $
                   ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='steer'+strtrim(stno,1)+' (keV)'
           endelse
        end

         14 : begin 
            size = n_elements(index)-1
            anener = dblarr(size+1)
            for i = 0, size do begin
               anener[i] = max(evlist[17:32,index[i]])
            endfor
            if keyword_set(gry) then begin
               plot,anener,evlist[catno,index],psym=sym,yrange=gry,thick=gth, $
                    ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='max anode energy (keV)'
            endif else begin
               plot,anener,evlist[catno,index],psym=sym,thick=gth, $
                    ytitle='cathode'+strtrim(catno,1)+' (keV)',xtitle='max anode energy (keV)'
            endelse
         end
         
         15 : begin
            if keyword_set(gry) then begin
               plot,evlist[catno,index],evlist[andno,index],psym=sym,yrange=gry,thick=gth, $
                    ytitle='anode'+strtrim(andno-16,1)+'/cathode'+strtrim(catno,1)+' ratio',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
            endif else begin
               plot,evlist[catno,index],evlist[andno,index],psym=sym,thick=gth, $
                   ytitle='anode'+strtrim(andno-16,1)+'/cathode'+strtrim(catno,1)+' ratio',xtitle='anode'+strtrim(andno-16,1)+' (keV)'
            endelse
         end
         
         20 : begin 
            spe = histogram(evlist[andno,index]*2,min=0,max=260)
            if keyword_set(gry) then begin
               plot,spe,psym=10,yrange=gry, $
                    ytitle='count for anode'+strtrim(andno-16,1),xtitle='energy (keV)'
            endif else begin
               plot,spe,psym=10,yrange=[0,max(spe[20:260])*1.2], $
                    ytitle='count for anode'+strtrim(andno-16,1),xtitle='energy (keV)'
            endelse
         end

         21 : begin 
            spe = histogram(evlist[catno,index]*2,min=0,max=260)
            if keyword_set(gry) then begin
               plot,spe,psym=10,yrange=gry, $
                    ytitle='count for cathode'+strtrim(catno,1),xtitle='energy (keV)'
            endif else begin
               plot,spe,psym=10,yrange=[0,max(spe[20:260])*1.2], $
                    ytitle='count for cathode'+strtrim(catno-16,1),xtitle='energy (keV)'
            endelse
         end
         
         22 : begin 
            spe = histogram(evlist[stno,index]*2,min=0,max=260)
            if keyword_set(gry) then begin
               plot,spe,psym=10,yrange=gry, $
                    ytitle='count for steer'+strtrim(stno-32,1),xtitle='energy (keV)'
            endif else begin
               plot,spe,psym=10,yrange=[0,max(spe[20:260])*1.2], $
                    ytitle='count for steer'+strtrim(stno-32,1),xtitle='energy (keV)'
            endelse
         end
         
         23 : begin 
            spe = histogram((evlist[andno,index]+evlist[andno-1,index]+evlist[andno+1,index])*2,min=0,max=300)
            if keyword_set(gry) then begin
               plot,spe,psym=10,yrange=gry, $
                    ytitle='neigbour added count for anode'+strtrim(andno-16,1),xtitle='energy (keV)'
            endif else begin
               plot,spe,psym=10,yrange=[0,max(spe[20:300])*1.2], $
                    ytitle='neigbour added count for anode'+strtrim(andno-16,1),xtitle='energy (keV)'
            endelse
         end

         24 : begin
            size = n_elements(index)-1
            anener = dblarr(size+1)
            for i = 0, size do begin
               anener[i] = max(evlist[17:32,index[i]])
            endfor
            spe = histogram(anener*2,min=0,max=260)
            if keyword_set(gry) then begin
               plot,spe,psym=10,yrange=gry, $
                    ytitle='count',xtitle='max energy (keV)'
            endif else begin
               plot,spe,psym=10,yrange=[0,max(spe[20:260])*1.2], $
                    ytitle='count',xtitle='max energy (keV)'
            endelse
         end

         30 : begin
            aa = evlist[andno,index] - (-cvar[0]/evlist[catno,index]+cvar[1])*exp(-evlist[catno,index]^cvar[2]/cvar[3])
            aa = aa * cvar[4]
            spe = histogram (aa*2,min=0,max=300)
            if keyword_set(gry) then begin
               plot,spe,psym=10,yrange=gry, $
                    ytitle='count for anode'+strtrim(andno-16,1),xtitle='energy (keV)'
            endif else begin
               plot,spe,psym=10,yrange=[0,max(spe[20:260])*1.2], $
                    ytitle='count for anode'+strtrim(andno-16,1),xtitle='energy (keV)'
            endelse
         end

     endcase

  endfor

  endelse
  
END
