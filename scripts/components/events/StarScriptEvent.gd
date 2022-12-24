@tool
extends __EventBase
class_name StarScriptEvent
@icon("res://_engine/scripts/icons/icon_dialogevent_small.png")

@export var event_pool : StarScript
@export var event_key : String = ""

func _init():
	color = Color(0.87171185016632, 0.21420693397522, 0.2486332654953)

func _trigger():
	if Game.DC.is_in_cutscene:
		return
	await get_tree().process_frame
	
	Game.DC.enter_cutscene()
	
	if not event_pool.data.has(event_key):
		Shell.print_err(
			"MissingKey", "The key " + str(event_key) +\
			" wasn't found in the pool " + str(event_pool) + "."
			)
	
	await Shell.execute_block(event_pool.data[event_key].content)
	Game.DC.exit_cutscene()

var _icon = preload("res://_engine/scripts/icons/icon_dialogevent_small.png")

func _draw():
	super()
	
	draw_set_transform(Vector2(), 0.0, Vector2(SCALE, SCALE))
	draw_texture(_icon, - _icon.get_size()/2)
