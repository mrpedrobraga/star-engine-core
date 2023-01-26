@tool
@icon("res://_engine/scripts/icons/icon_component_movement.png")
extends Component
class_name Movement3D

var listening_to_input := false

var input_action_x_pos := "move_right"
var input_action_x_neg := "move_left"
var input_action_y_pos := "move_up"
var input_action_y_neg := "move_down"
var input_action_z_pos := "move_forward"
var input_action_z_neg := "move_backward"
var input_action_jump := "move_jump"
var input_action_special := "OK"
var input_action_OK := ""
var input_transform := Transform3D.IDENTITY

const motion_modes = "Free,Sidescroller,Discrete"
const motion_directions = "Up,Down,Left,Right"
var motion_mode : int = 0
var motion_maximum_speed := 2
var motion_acceleration := 2
var motion_transform := Transform3D.IDENTITY
var motion_gravity_active := false
var motion_gravity_direction := Vector3.DOWN
var motion_gravity_magnitude := 10
var motion_jump_active := false
var motion_jump_strength := 0.5
var motion_jump_direction := "Up"

var animation_canvas_item 
var animation_squash_and_stretch_active := false
var animation_squash_and_stretch_target_scale := Vector3.ONE

var required_state = &"Overworld"

### INTERNALS
var position_z := 0.0
var vz := 0.0
var input_vector := Vector3.ZERO
var facing_vector := Vector3.DOWN

signal direction_changed(direction)

func _init():
	_update_props()

func _update_props():
	extra_props.clear()
	
	InputMap.load_from_project_settings()
	var actions : Array[String]
	actions.typed_assign(InputMap.get_actions())
	actions.sort()
	PROPERTY ("Listening To Inputs", &"listening_to_input", TYPE_BOOL, PROPERTY_HINT_NONE, "", true)
	PROPERTY ("Required State", &"required_state", TYPE_STRING_NAME)
	
	PROPERTY ("Input/X+", &"input_action_x_pos", TYPE_STRING, PROPERTY_HINT_ENUM_SUGGESTION, join_commas(actions))
	PROPERTY ("Input/X-", &"input_action_x_neg", TYPE_STRING, PROPERTY_HINT_ENUM_SUGGESTION, join_commas(actions))
	PROPERTY ("Input/Y+", &"input_action_y_pos", TYPE_STRING, PROPERTY_HINT_ENUM_SUGGESTION, join_commas(actions))
	PROPERTY ("Input/Y-", &"input_action_y_neg", TYPE_STRING, PROPERTY_HINT_ENUM_SUGGESTION, join_commas(actions))
	PROPERTY ("Input/Z+", &"input_action_z_pos", TYPE_STRING, PROPERTY_HINT_ENUM_SUGGESTION, join_commas(actions))
	PROPERTY ("Input/Z-", &"input_action_z_neg", TYPE_STRING, PROPERTY_HINT_ENUM_SUGGESTION, join_commas(actions))
	PROPERTY ("Input/JUMP", &"input_action_jump", TYPE_STRING, PROPERTY_HINT_ENUM_SUGGESTION, join_commas(actions))
	PROPERTY ("Input/SPECIAL", &"input_action_OK", TYPE_STRING, PROPERTY_HINT_ENUM_SUGGESTION, join_commas(actions))
	PROPERTY ("Input/Transform", &"input_transform", TYPE_TRANSFORM3D)
	
	PROPERTY ("Motion/Mode", &"motion_mode", TYPE_INT, PROPERTY_HINT_ENUM, motion_modes)
	PROPERTY ("Motion/Acceleration", &"motion_acceleration", TYPE_FLOAT)
	PROPERTY ("Motion/Maximum Speed", &"motion_maximum_speed", TYPE_FLOAT)
	PROPERTY ("Motion/Transform", &"motion_transform", TYPE_TRANSFORM3D)
	
	PROPERTY ("Motion/Gravity Active", &"motion_gravity_active", TYPE_BOOL, PROPERTY_HINT_NONE, "", true)
	PROPERTY ("Motion/Gravity/Direction", &"motion_gravity_direction", TYPE_VECTOR3)
	PROPERTY ("Motion/Gravity/Magnitude", &"motion_gravity_magnitude", TYPE_FLOAT)
	
	PROPERTY ("Motion/Jump Active", &"motion_jump_active", TYPE_BOOL, PROPERTY_HINT_NONE, "", true)
	PROPERTY ("Motion/Jump/Strength", &"motion_jump_strength", TYPE_FLOAT)
	PROPERTY ("Motion/Jump/Direction", &"motion_jump_direction", TYPE_STRING, PROPERTY_HINT_ENUM, motion_directions)
	
	PROPERTY ("Motion/Squash Stretch Active", &"animation_squash_and_stretch_active", TYPE_BOOL, PROPERTY_HINT_NONE, "", true)
	PROPERTY ("Motion/Squash Stretch/Target", &"animation_canvas_item", TYPE_NODE_PATH, PROPERTY_HINT_NODE_TYPE, "CanvasItem")
	PROPERTY ("Motion/Squash Stretch/Target Scale", &"animation_squash_and_stretch_target_scale", TYPE_VECTOR3)
	
	_update_active_props()
	notify_property_list_changed()

func _update_active_props():
	_set_prop_active("Input/LEFT", listening_to_input)
	_set_prop_active("Input/RIGHT", listening_to_input)
	_set_prop_active("Input/UP", listening_to_input)
	_set_prop_active("Input/DOWN", listening_to_input)
	_set_prop_active("Input/JUMP", listening_to_input)
	_set_prop_active("Input/SPECIAL", listening_to_input)
	_set_prop_active("Input/Transform", listening_to_input)
	
	_set_prop_active("Motion/Gravity/Direction", motion_gravity_active)
	_set_prop_active("Motion/Gravity/Magnitude", motion_gravity_active)
	
	_set_prop_active("Motion/Jump/Strength", motion_jump_active)
	_set_prop_active("Motion/Jump/Direction", motion_jump_active and (motion_mode == 1))
	
	_set_prop_active("Motion/Squash Stretch/Target", animation_squash_and_stretch_active)
	_set_prop_active("Motion/Squash Stretch/Target Scale", animation_squash_and_stretch_active)

################################## CODE ###################################

var parent : CharacterBody3D = get_parent()

func _ready():
	property_list_changed.emit()

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		parent = get_parent()

func _physics_process(delta):
	if Engine.is_editor_hint():return
	if not Game.get_state() == required_state:return
	if not parent: return

	# Get the input vector
	if listening_to_input:
		input_vector = Vector3(
			Input.get_axis(input_action_x_neg, input_action_x_pos),
			Input.get_axis(input_action_y_neg, input_action_y_pos),
			Input.get_axis(input_action_z_neg, input_action_z_pos)
		)
	
	match motion_mode:
		0:
			move_free(delta)
		1:
			move_sidescroller(delta)
		2:
			move_discrete(delta)

func move_free(delta):
	parent.velocity = parent.velocity.move_toward(
		motion_transform * input_transform * input_vector * motion_maximum_speed,
		motion_acceleration * delta
	)
	
	parent.move_and_slide()

func move_sidescroller(delta):
	pass
func move_discrete(delta):
	pass

######################### EDITOR CONFIGURATION #########################

func _get_configuration_warning():
	if not get_parent() is CharacterBody2D:
		return "Parent must be of type CharacterBody2D"
	return ""

#func _physics_process(delta):
#	if Engine.is_editor_hint():
#		return
#
#	if not Game.get_state() == required_state:
#		return
#
#	# Get the input vector
#	if listening_to_input:
#		input_vector = Input.get_vector(
#			input_action_left,
#			input_action_right,
#			input_action_up,
#			input_action_down
#		)
#
#	if input_vector:
#		var a = facing_vector
#		facing_vector = input_vector.normalized()
#		if facing_vector != a:
#			direction_changed.emit(facing_vector)
#
#	# Move!
#	match motion_mode:
#		MovementMode.FREE:
#			move_free(delta)
#
#	# Juicy Effects
#	if animation_squash_and_stretch_active and controllable:
#		if not animation_visual_sprite:
#			printerr("Movement2D has no visual sprite associated and can't animate.")
#			return
#		var target_scale = animation_squash_and_stretch_target_scale
#		if Input.is_action_just_pressed(input_action_left) or Input.is_action_just_pressed(input_action_right):
#			animation_visual_sprite.scale.x = target_scale.x * 2.0
#			animation_visual_sprite.scale.y = target_scale.y * 0.5
#		if Input.is_action_just_pressed(input_action_up) or Input.is_action_just_pressed(input_action_down):
#			animation_visual_sprite.scale.x = target_scale.x * 0.5
#			animation_visual_sprite.scale.y = target_scale.y * 2.0
#		animation_visual_sprite.scale = animation_visual_sprite.scale.move_toward(
#			target_scale,
#			delta * 10.0 * target_scale.x
#		)
#
#func move_free(delta):
#	# If gravity is active, move horizontally and fall
#	if motion_gravity_active:
#		parent.velocity.x = move_toward(parent.velocity.x, input_vector.x * motion_maximum_speed, motion_acceleration * delta)
#		parent.velocity += motion_gravity_direction * motion_gravity_magnitude * delta
#		parent.move_and_slide()
#		if controllable and parent.is_on_floor() and Input.is_action_pressed(input_action_up) and motion_jump_active:
#			parent.velocity.y = - motion_gravity_magnitude * motion_jump_strength
#	else:
#		parent.velocity = parent.velocity.move_toward(
#			input_vector *\
#			input_scale *\
#			motion_maximum_speed,
#			motion_acceleration * delta
#		)
#		parent.move_and_slide()
#		position_z += vz * delta
#		animation_visual_sprite.position.y = min(- position_z, 0)
#		var target_scale = animation_squash_and_stretch_target_scale
#
#		if position_z > 0.0:
#			vz -= motion_gravity_magnitude * delta * 2
#		if position_z < 0.0:
#			position_z = 0.0
#			vz = 0.0
#			if animation_squash_and_stretch_active:
#				animation_visual_sprite.scale.x = target_scale.x * 2.0
#				animation_visual_sprite.scale.y = target_scale.y * 0.5
#		if controllable and position_z == 0 and Input.is_action_pressed(input_action_jump) and motion_jump_active:
#			vz = motion_gravity_magnitude * motion_jump_strength
#			if animation_squash_and_stretch_active:
#				animation_visual_sprite.scale.x = target_scale.x * 0.5
#				animation_visual_sprite.scale.y = target_scale.y * 2.0
#	pass
