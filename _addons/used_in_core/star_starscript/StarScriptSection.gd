@tool
extends Resource
class_name StarScriptSection

@export var pool : StarScript:
	set(v):
		pool = v
		if not v.data.has(key):
			key = v.data.keys()[0]
		notify_property_list_changed()
var key : String

func _init(_pool = null, _key = ""):
	if pool:
		pool = _pool
		key = _key

func _get_property_list():
	var properties = []
	
	# Section Key
	var sections = ""
	if pool:
		var sections_array = pool.data.keys()
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
		key = value
func _get(property):
	if property == "section_key":
		return key
