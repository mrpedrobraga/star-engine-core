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

@export_group("Named objects")
var registered_objects : Dictionary

## Sets up handy nodes for organization.
var setup_organization : bool = false:
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
	add_child.call_deferred(orgn, true)
	orgn.owner = self

## Registers an object that can be retrieved by an id.
func register_object(obj_name : StringName, object):
	registered_objects[obj_name] = object

## Retrieves a previously registered object by its id.
func get_entity(obj_name : StringName):
	if registered_objects.has(obj_name):
		return registered_objects[obj_name]
	return null

## Retrieves a marker.
func get_marker(marker_name : String):
	# TODO: Implement a better way of getting the marker.
	return get_node("Markers/" + marker_name)

## Spawns an object at a position.
func spawn(ch : Node2D):
	add_child.call_deferred(ch)

## Makes this the current room.
##
## [param first_scene] will be true if this is the 
## first room to be loaded after a game load.
func initialize(transition_context : Dictionary = {}):
	return
