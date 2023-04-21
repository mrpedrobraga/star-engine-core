extends Resource
class_name StarScriptBlock

## Holds the data for a single StarScript block.

var StarScriptCommand := preload("StarScriptCommand.gd")

@export_category("Content")

## The properties defined in this block.
@export var properties : Dictionary

## Same as the one above, but only stores properties,
## if all the properties were unnamed in the source code.
@export var properties_arr : Array

## The commands existings in this block
@export var commands : Array[StarScriptCommand]

## The labels defined in this block.
##
## The execution can be suddenly transferred to a label,
## even from a child block.
@export var labels : Dictionary



@export_category("Execution")

## The line of this block in the original source code.
@export var line : int = 0

## The parent of this StarScriptBlock.
## Leave it as null if it has no parent.
##
## This is the block this block will return
## execution to when it stops executing.
#@export var parent_block : StarScriptBlock = null

## The variables defined in this block.
## (They'll be defined on runtime).
@export var local_variables : Dictionary = {}

## If this block has no subcommands, but has properties,
## it returns a [Dictionary] version of this block. [br]
## Otherwise, it returns itself unchanged.
func try_as_dictionary():
	if commands.size() > 0:
		return self
	var result := {}
	
	for prop in properties.keys():
		if prop is StarScriptBlock:
			result[prop] = properties[prop].try_as_dictionary()
		else:
			result[prop] = properties[prop]
	
	return result

## Similar to [method try_as_dictionary], but won't convert
## this object into one, instead, it will convert only the
## inner properties.[br]
## This method actually modifies the contents of this [StarScriptBlock].
func compact():
	for key in properties.keys():
		if properties[key] is StarScriptBlock:
			properties[key] = properties[key].try_as_dictionary()
		# If conversion fails:
		if properties[key] is StarScriptBlock:
			properties[key].compact()
	return self

## Gets a property from [member properties].
## This method is safe because it considers any property might
## be a [StarScriptProperty] or a Variant.[br]
func get_property(property):
	if property is String:
		property = property.simplify_path().split("/")
	return _get_property(property, "")

func _get_property(path : Array, acc_path : String):
	if not properties.has(path[0]):
		# TODO: Ponder if this should be an error.
		push_warning("[StarScript] %s doesn't have an entry %s on path %s." % [
			resource_path, str(path[0]), acc_path
		])
		return null
	
	var current = properties[path[0]]
	
	if path.size() > 1:
		if current is StarScriptBlock:
			return current._get_property(path.slice(1), acc_path + "/" + str(path[0]) + "/")
		elif current is Dictionary:
			return _get_dictionary_entry(current, path.slice(1), acc_path + "/" + str(path[0]) + "/")
	return current

func _get_dictionary_entry(dict : Dictionary, path : Array, acc_path : String=""):
	if not dict.has(path[0]):
		push_warning("[StarScript] %s doesn't have an entry %s on path %s." % [
			resource_path, str(path[0]), acc_path
		])
		return null
	
	var current = dict[path[0]]
	
	if path.size() > 1:
		if current is StarScriptBlock:
			return current._get_property(path.slice(1), acc_path + "/" + str(path[0]) + "/")
		elif current is Dictionary:
			return _get_dictionary_entry(current, path.slice(1), acc_path + "/" + str(path[0]) + "/")
	return current


func _to_string():
	var repr := ""
	
	if properties:
		for prop in properties.keys():
			repr += "%s: %s\n" % [prop, properties[prop]]
		repr += "\n"
	for cmd in commands:
		repr += str(cmd) + "\n"
	
	return repr
