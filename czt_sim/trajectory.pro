;plots trajectory
PRO trajectory,xac,zac,i,hole=hole

;INPUT
;------------------------------
;xac,zac : postion arrays
;i       : if 0 plot else oplot
;hole    : dotted line for holes

  IF i eq 0 THEN BEGIN 
     window,1,xsize=1200,ysize=300,xpos=0,ypos=400
     plot,xac,zac,yrange=[0.,5.],$
       xtitle='Distance Along Detector(mm)',ytitle='depth(mm)',$
       xrange=[xac[0]-0.5,xac[0]+0.5],thick=0.5

                                ;Define the placement of anodes
     obox,0.62,0,0.92,0.1
     polyfill,[0.62,0.92, 0.92, 0.62,0.62],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[1.82,2.12, 2.12, 1.82,1.82],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[3.02,3.32, 3.32, 3.02,3.02],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[4.27,4.47, 4.47, 4.27,4.27],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[5.47,5.67, 5.67, 5.47,5.47],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[6.67,6.87, 6.87, 6.67,6.67],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[7.92,8.02, 8.02, 7.92,7.92],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[9.12,9.22, 9.22, 9.12,9.12],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[10.32,10.42, 10.42, 10.32,10.32],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[11.52,11.62, 11.62, 11.52,11.52],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[12.62,12.92, 12.92, 12.62,12.62],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[13.82,14.12, 14.12, 13.82,13.82],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[15.02,15.32, 15.32, 15.02,15.02],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[16.07,16.67, 16.67, 16.07,16.07],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[17.27,17.87, 17.87, 17.27,17.27],[0.,0.,0.1,0.1,0.],color=150
     polyfill,[18.47,19.07, 19.07, 18.47,18.47],[0.,0.,0.1,0.1,0.],color=150
 
                                ;Now steering electrodes
     obox,0.00000,0,0.320000,0.1
     obox,1.22000,0,1.52000,0.1
     obox,2.42000,0,2.72000,0.1
     obox,3.62000,0,4.14500,0.1
     obox,4.59500,0,5.34500,0.1
     obox,5.79500,0,6.54500,0.1
     obox,6.99500,0,7.79500,0.1
     obox,8.14500,0,8.99500,0.1
     obox,9.34500,0,10.1950,0.1
     obox,10.5450,0,11.3950,0.1
     obox,11.7450,0,12.4200,0.1
     obox,13.1200,0,13.6200,0.1
     obox,14.3200,0,14.8200,0.1
     obox,15.5200,0,15.9200,0.1
     obox,16.8200,0,17.1200,0.1
     obox,18.0200,0,18.3200,0.1
     obox,19.2200,0,19.5400,0.1

  ENDIF ELSE BEGIN 
     IF keyword_set(hole) THEN oplot, xac,zac, linestyle=2, thick=0.5 ELSE oplot,xac,zac,thick=0.5
  ENDELSE
END
