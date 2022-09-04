extends __EventBase
class_name StarScriptEvent
@icon("res://addons/builtin/star_events/icon_dialogevent.png")

@export var event_pool : Resource
@export var event_key : String = ""

func _trigger():
	if Game.DC.is_in_cutscene:
		return
	await get_tree().process_frame
	
	Game.DC.enter_cutscene()
	await Shell.execute_block(event_pool.data[event_key].content)
	Game.DC.exit_cutscene()
