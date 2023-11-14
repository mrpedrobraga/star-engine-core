extends TextureRect
class_name ViewportInteractiveRect

@export var viewport: SubViewport

func _input(event):
	viewport.push_input(event)
