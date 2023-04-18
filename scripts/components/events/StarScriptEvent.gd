@tool
@icon("res://_engine/scripts/icons/icon_dialogevent_small.png")
extends __EventBase
class_name StarScriptEvent

## Class that executes a [StarScript] when interacted with.

@export var event_pool : StarScript:
	set(v):
		event_pool = v
		if not v.sections.has(event_key):
			event_key = v.sections.keys()[0]
		notify_property_list_changed()
		update_configuration_warnings()
@export var event_key : String = "":
	set(v):
		event_key = v
		name = "E_" + str(event_key) + "_"
		update_configuration_warnings()

func _init():
	color = Color("#df1e5a")


func _trigger():
	if Game.DC.is_in_cutscene:
		return
	await get_tree().process_frame
	
	Game.DC.enter_cutscene()
	
	await Game.DC.dialog(event_pool, event_key)
	await get_tree().process_frame
	
	Game.DC.exit_cutscene()

var _icon = preload("res://_engine/scripts/icons/icon_dialogevent_small.png")

func _draw():
	super()
	if (not Engine.is_editor_hint()) and (not draw_on_game_also):
		return
	
	draw_set_transform(Vector2(size/2) + Vector2.UP * icon_offset, 0.0, Vector2(float(_SCALE), float(_SCALE)))
	draw_texture(_icon, 0.5 * (-_icon.get_size()))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _get_configuration_warnings():
	var w = []
	
	if not event_pool:
		w.append("This event has no assigned event pool.")
	if event_key == "":
		w.append("This event has no key.")
	
	return w
