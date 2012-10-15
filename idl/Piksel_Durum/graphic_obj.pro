pro graphic_obj

; Create a view 2 units high by 100 units wide
; with its origin at (0,-1):
view = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0,-1,100,2])
; Create a model:
model = OBJ_NEW('IDLgrModel')
; Create a plot line of a sine wave:
plot = OBJ_NEW('IDLgrPlot', SIN(FINDGEN(100)/10))
; Create a window into which the plot line will be drawn:
window = OBJ_NEW('IDLgrWindow')
; Add the plot line to the model object:
model->ADD, plot
; Add the model object to the view object:
view->ADD, model
; Render the contents of the view object in the window:
window->DRAW, view

end