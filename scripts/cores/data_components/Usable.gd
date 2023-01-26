extends Resource
class_name Usable

## Class that encapsulates a thing that can be *used* by a character.

@export var id : StringName = "unknown"
@export var display_name : String = "Unknown"
@export var icon : Texture2D

func _use(character):
	pass
