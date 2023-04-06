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

func _to_string():
	var repr := ""
	
	if properties:
		for prop in properties.keys():
			repr += "%s: %s\n" % [prop, properties[prop]]
		repr += "\n"
	for cmd in commands:
		repr += str(cmd) + "\n"
	
	return repr
