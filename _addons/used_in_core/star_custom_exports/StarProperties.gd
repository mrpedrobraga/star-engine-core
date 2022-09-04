@tool
extends Node
class_name StarProperties

#	StarProperties
#
#		Class that houses special export properties
#		so you can have your main classes be tidy.

var _export_properties := {}

func clear():
	_export_properties.clear()
	_export_properties["_export_properties"] = {
		"name": "_export_properties",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_NO_EDITOR
	}

## Adds a category to the list.
## Subsequent properties will be created under the new category.
func category(_name : String):
	_export_properties["category_" + _name] = {
		"name" : _name,
		"type" : TYPE_NIL,
		"usage" : PROPERTY_USAGE_CATEGORY
	}

## Adds a property to the list.
func property(
			_name : String,
			group_path : String,
			type : int,
			usage : int = 0,
			hint  : int = 0,
			hint_string = null
		):
	var _n = _name if group_path == "" else group_path + "/" + _name
	var r = {
		"name" : _n,
		"type" : type,
		"usage" : usage | PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"visible" : true,
		"value" : null
	}
	if hint:
		r.hint = hint
	if hint_string:
		r.hint_string = hint_string
	_export_properties[_n] = r

func resource(_name : String, group_path : String, type : String, usage : int = 0):
	property(_name, group_path, TYPE_OBJECT, usage,
		PROPERTY_HINT_RESOURCE_TYPE,
		type)

## Sets the hint string of an already defined property at a given path.
func set_hint_string(path, value : String):
	var n = str(path)
	if not _export_properties.has(n):
		print("(!) No property '" + n + "' found.")
	_export_properties[n].hint_string = value

func _get_property_list():
	return _export_properties.values()

func has(property : StringName):
	return _export_properties.has(str(property))

func _set(property : StringName, value):
	if has(property):
		_export_properties[str(property)].value = value

func _get(property : StringName):
	if not property == "_export_properties" and has(property):
		return _export_properties[str(property)].value
