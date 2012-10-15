mywindow = OBJ_NEW('IDLgrWindow')

myview = OBJ_NEW('IDLgrView')

mymodel = OBJ_NEW('IDLgrModel')

data = DIST(20)

mycontour = OBJ_NEW('IDLgrSurface', data

mycontour->SetProperty, STYLE=6, COLOR=[0,255,0]

myview->Add, mymodel

mymodel->Add, mycontour

mywindow->Draw, myview 
