@tool
extends __EventBase
class_name SignalEvent
##Simple event class that emits a signal when triggered.
##You can connect and use this signal to do whatever in your code.

##The signal emitted when this event is triggered.
signal triggered()

func _init():
	color = Color(0.93940514326096, 0.76372146606445, 0.10725440829992)

func _trigger():
	triggered.emit()

var _icon = preload("res://_engine/scripts/icons/icon_event_small.png")

func _draw():
	super()
	
	draw_set_transform(Vector2(size/2) + Vector2.UP * icon_offset, 0.0, Vector2(float(_SCALE), float(_SCALE)))
	draw_texture(_icon, 0.5 * (-_icon.get_size()))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
