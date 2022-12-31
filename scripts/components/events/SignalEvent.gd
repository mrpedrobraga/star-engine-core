@tool
##Simple class that emits a signal when triggered.
##You can connect and use this signal to do whatever in your code.
extends __EventBase
class_name SignalEvent

##The signal emitted when this event is triggered.
signal triggered()

func _init():
	color = Color(0.93940514326096, 0.76372146606445, 0.10725440829992)

func _trigger():
	triggered.emit()

var _icon = preload("res://_engine/scripts/icons/icon_event_small.png")

func _draw():
	if not Engine.is_editor_hint():
		return
	super()
	
	draw_set_transform(Vector2(), 0.0, Vector2(SCALE, SCALE))
	draw_texture(_icon, - _icon.get_size()/2)
