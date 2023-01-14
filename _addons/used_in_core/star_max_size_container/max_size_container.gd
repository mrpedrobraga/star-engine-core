@tool
extends Container
class_name MaxSizeContainer

##Container that scales its children up to a maximum size.

@export_category("MaxSizeContainer")

##The maximum size of the children.
##
##Any coordinate that equals -1 will be ignored in the calculation.
@export var maximum_size := Vector2(-1, -1):
	set(v):
		maximum_size = v
		_calc()

## Where the children will be located if they reach maximum size.
@export_enum("Centered", "Top Left") var positioning = 0:
	set(v):
		positioning = v
		_calc()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_calc()

func _calc():
	var r := Rect2()
	
	if maximum_size.x == -1:
		r.size.x = size.x
	else:
		r.size.x = min(size.x, maximum_size.x)
	
	if maximum_size.y == -1:
		r.size.y = size.y
	else:
		r.size.y = min(size.y, maximum_size.y)
	
	match positioning:
		0:
			r.position = 0.5 * (size - r.size)
		1:
			r.position = Vector2.ZERO
	
	for i in get_children():
		fit_child_in_rect(i, r)
