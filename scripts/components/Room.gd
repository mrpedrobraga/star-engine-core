extends Node2D
class_name Room

## Class for Rooms -- scenes where characters can walk in.
##
## You should use these to build your level,
## if your scene has a custom script it should extend [Room]
##
## Here you'll find things like save information and more.

@export_category("Room")

@export_group("Room Information")

@export var room_name : String = "Unknown Room"
@export var is_valid_resume_area : bool = false
@export var resume_hotspot : Marker2D

func spawn(ch : Node2D, pos : Vector2):
	add_child(ch)
	ch.global_position = pos
