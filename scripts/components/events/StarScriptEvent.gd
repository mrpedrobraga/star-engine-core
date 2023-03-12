@tool
@icon("res://_engine/scripts/icons/icon_dialogevent_small.png")
extends __EventBase
class_name StarScriptEvent

## Class that executes a [StarScript] when interacted with.

@export var event_pool : StarScript:
	set(v):
		event_pool = v
		if not v.data.has(event_key):
			event_key = v.data.keys()[0]
		notify_property_list_changed()
		update_configuration_warnings()
var event_key : String = ""

func _init():
	color = Color("#df1e5a")


func _trigger():
	
	if Game.DC.is_in_cutscene:
		return
	await get_tree().process_frame
	
	Game.DC.enter_cutscene()
	
	if not event_pool.data.has(event_key):
		Shell.print_err(
			"MissingKey", "The key " + str(event_key) +\
			" wasn't found in the pool " + str(event_pool.resource_path) + "."
			)
	else:
		await Shell.execute_block(event_pool.data[event_key].content)
	Game.DC.exit_cutscene()

var _icon = preload("res://_engine/scripts/icons/icon_dialogevent_small.png")

func _draw():
	super()
	
	draw_set_transform(Vector2(size/2) + Vector2.UP * icon_offset, 0.0, Vector2(float(_SCALE), float(_SCALE)))
	draw_texture(_icon, 0.5 * (-_icon.get_size()))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _get_property_list():
	var properties = []
	
	# Section Key
	var sections = ""
	if event_pool:
		var sections_array = event_pool.data.keys()
		if sections_array.size()>0:
			sections += sections_array[0]
		if sections_array.size()>1:
			for i in sections_array.size()-1:
				sections += "," + str(sections_array[i+1])
	else:
		sections = ""
	
	properties.append(
		{
			"name": "section_key",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": sections
		}
	)
	
	return properties

func _set(property, value):
	if property == "section_key":
		event_key = value
		name = "E_" + str(event_key) + "_"
		update_configuration_warnings()
func _get(property):
	if property == "section_key":
		return event_key

func _get_configuration_warnings():
	var w = []
	
	if not event_pool:
		w.append("This event has no assigned event pool.")
	if event_key == "":
		w.append("This event has no key.")
	
	return w
