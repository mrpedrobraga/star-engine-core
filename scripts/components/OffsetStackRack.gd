@tool
extends Node2D
class_name OffsetStackRack2D

##A packed array that contains the stack of [Vector2] offsets.
@export var offset_stack : PackedVector2Array = [Vector2.ZERO]:
	set(v):
		offset_stack = v
		update_position()

##Sets the offset at [param index] to be [param value].

func set_offset_at(index : int, value : Vector2):
	# If the index is too big, quickly add more spaces.
	while index >= offset_stack.size():
		offset_stack.push_back(Vector2.ZERO)
	
	offset_stack[index] = value
	update_position()

##Gets the offset at [param index].
func get_offset_at(index : int):
	return offset_stack[index]

##Updates its own position based on its set of offsets.
func update_position():
	position = Vector2.ZERO
	for off in offset_stack:
		position += off

func _to_string():
	return "[Offsets: %s]" % str(offset_stack)
