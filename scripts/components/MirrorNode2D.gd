extends StaticBody2D
class_name MirrorNode2D

##Simple class that mirrors the position of another Node2D across an axis.

@export var original : Node2D

@export var reflection_axis_origin : Vector2 = Vector2.ZERO
@export var reflection_axis_direction : Vector2 = Vector2.UP

func _process(_delta):
	position = Vector2()
	position -= reflection_axis_origin
	position = position.reflect(reflection_axis_direction)
	position += reflection_axis_origin
