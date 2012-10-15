pro risetime

loc = 'C:\emrahdropbox\Dropbox\Lab-Data\Data\'
reffile = '1346077016_MulRec_CH1-1.dat'

infile = loc + reffile
alines=file_lines(infile)
OPENR, lun, infile, /GET_LUN
array = ''
line = ''
count=1
WHILE NOT EOF(lun) DO BEGIN
  READF, lun, line
  IF (count GT 13) THEN BEGIN
       array = [[array], [line]]
  ENDIF ELSE BEGIN
    IF count EQ 2 THEN peakpoint = line
  ENDELSE
  count = count + 1
ENDWHILE

FREE_LUN, lun


array = FLOAT(array)

maxpoint = MAX(array,MXP)
minpoint = MIN(array[MXP-500:MXP],MNP)
print, maxpoint , MXP
print,minpoint, MNP

per10 = ((maxpoint-minpoint)*0.1)+minpoint
per90 = ((maxpoint-minpoint)*0.9)+minpoint
print, per10,per90

B = WHERE(array LT per90 , count, COMPLEMENT=B_C, NCOMPLEMENT=count_c)

A = WHERE( B GT per10, RT, NCOMPLEMENT=RT_C)

yy=where(ns lt 0.2*avg(ns))


print,B
print, '-------------------------------------------------------------'
print, A

;; Print how many and which elements met the search criteria:
;
;PRINT, 'Number of elements > ',maxpoint,': ', count
;;
;PRINT, 'Subscripts of elements > 5: ', B
;;
;PRINT, 'Number of elements <= ',maxpoint,': ', count_c
;;
;PRINT, 'Subscripts of elements <= 5: ', B_C




end