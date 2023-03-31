@tool
@icon("res://_engine/scripts/icons/icon_room.png")
extends Node2D
class_name Room

## Class for Rooms -- scenes where characters can walk in.
##
## You should use these to build your levels,
## if your scene has a custom script it should extend [Room].
##
## Here you'll find things like save information and more.

@export_category("Room")

@export_group("Room Information")

## The display name of the room.
@export var room_name : String = "Unknown Room"
## Is this room is a valid resume area.
@export var is_valid_resume_area : bool = false
## The marker representing the position where the character will 
## appear when resuming from a previous session.
@export var resume_hotspot : Marker2D

@export_group("Tools")
## Sets up handy nodes for organization.
@export var setup_organization : bool = false:
	set(v):
		if Engine.is_editor_hint():
			ORGN("Objects")
			ORGN("Markers")
			ORGN("Events")
			ORGN("Sound Anchors")
			
			print("Organization nodes added.")

## Adds an (ORG)anization (N)ode if it doesn't exist already.
func ORGN(name_ : String):
	if has_node(name_):
		print("Already has node named %s." % name_)
		return
	var orgn := Node2D.new()
	orgn.name = name_
	add_child(orgn, true)
	orgn.owner = self

## Spawns an object at a position.
func spawn(ch : Node2D, pos : Vector2):
	add_child(ch)
	ch.global_position = pos

## Makes this the current room.
##
## [param first_scene] will be true if this is the 
## first room to be loaded after a game load.
func initialize(first_scene:bool=false):
	Shell.execute_block("zoom %s" % 0.8)
