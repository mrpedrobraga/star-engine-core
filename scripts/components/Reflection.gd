extends StaticBody2D

##Simple class that mirrors the position of another Node2D across an axis.

@export var original : Node
@export var center : Vector2 = Vector2.ZERO

func _process(_delta):
	position = Vector2(center.x - original.position.x, original.position.y)
	scale = original.get_node("Texture2D").scale / 6
