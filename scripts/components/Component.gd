##Generic class for components.

@icon("res://_engine/scripts/icons/icon_component.png")
extends Node
class_name Component

@export_category("Debug")
@export var UPDATE_PROPERTIES : bool = false:
	set(v): _update_props()
@export_category("")

func _update_props():
	pass

######################## SNIPPETS ########################

var extra_props : Dictionary
func CATEGORY(cat : String):
	extra_props[cat] = {
		"name": cat,
		"usage": PROPERTY_USAGE_CATEGORY
	}
func PROPERTY(prop : String, target: StringName, type : int, hint : int = PROPERTY_HINT_NONE, hint_string : String = "", group_toggle : bool = false):
	extra_props[prop] = {
		"name": prop,
		"target": target,
		"type": type,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": hint,
		"hint_string": hint_string,
		"active": true,
		"group_toggle": group_toggle
	}

func _set_prop_active(prop : String, value : bool):
	if extra_props.has(prop):
		extra_props[prop].active = value

func _set(prop, value):
	if prop in extra_props:
		set(extra_props[prop].target, value)
		if extra_props[prop].target:
			notify_property_list_changed()
	
func _get(prop):
	if prop in extra_props:
		return get(extra_props[prop].target)

func _get_property_list():
	if has_method(&"_update_active_props"):
		call(&"_update_active_props")
	return extra_props.values().filter((func (prop): return prop.active))

func join_commas(a : Array) -> String:
	if a.size() == 0: return ""
	var result = ""
	result += a[0]
	
	for i in a.size() - 1:
		result += "," + str(a[i+1])
	
	return result
