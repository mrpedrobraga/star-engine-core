@tool
@icon("res://_engine/scripts/icons/icon_component_movement.png")
extends Node
class_name GridMovement2D

## Component class that handles movement in a two-dimensional  grid.
##
## TODO: Better document this class (and implement more movement modes).

@export var enabled : bool = false
@export var required_state : StringName

@export var listening_to_input := false

@export_category("Motion")

@export var motion_acceleration := 12288
@export var motion_maximum_speed := 768

@export_category("Input")

@export var input_action_up := "move_up"
@export var input_action_left := "move_left"
@export var input_action_down := "move_down"
@export var input_action_right := "move_right"
@export var input_action_jump := "move_jump"
@export var input_action_special := "OK"
@export var input_action_OK := ""
@export var input_transform := Transform2D.IDENTITY

################################## CODE ###################################

var parent : CharacterBody2D = get_parent()
var input_vector : Vector2

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		parent = get_parent()

func _physics_process(delta):
	if Engine.is_editor_hint():return
	if not Game.get_state() == required_state:return
	if not parent: return
	if not enabled: return

	# Get the input vector
	if listening_to_input:
		if Input.is_action_pressed(input_action_left):
			input_vector = Vector2.LEFT
		if Input.is_action_pressed(input_action_right):
			input_vector = Vector2.RIGHT
		if Input.is_action_pressed(input_action_up):
			input_vector = Vector2.UP
		if Input.is_action_pressed(input_action_down):
			input_vector = Vector2.DOWN
	
	move_discrete(delta)

func move_discrete(delta : float) -> void:
	parent.velocity = input_vector * motion_maximum_speed
