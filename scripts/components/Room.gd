@tool
@icon("res://_engine/scripts/icons/icon_room.png")
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

@export_group("Tools")

@export var setup_organization : bool = false:
	set(v):
		if Engine.is_editor_hint():
			ORGN("Objects")
			ORGN("Markers")
			ORGN("Events")
			ORGN("Sound Anchors")
			
			print("Organization nodes added.")

func ORGN(name_ : String):
	if has_node(name_):
		print("Already has node named %s." % name_)
		return
	
	var orgn := Node2D.new()
	orgn.name = name_
	
	add_child(orgn, true)
	orgn.owner = self

func spawn(ch : Node2D, pos : Vector2):
	add_child(ch)
	ch.global_position = pos
