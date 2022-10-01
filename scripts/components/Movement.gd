@tool
extends Component
class_name Movement2D
@icon("res://_engine/scripts/icons/icon_component_movement.png")

enum MovementMode {
	FREE, DISCRETE
}

@export_category("Movement")

@export_group("Controls")
@export var input_action_up := "move_up"
@export var input_action_left := "move_left"
@export var input_action_down := "move_down"
@export var input_action_right := "move_right"
@export var input_action_jump := "move_jump"
@export var input_action_special := "OK"
@export var input_scale := Vector2.ONE

@export_group("Parameters")
@export var motion_mode : MovementMode
@export var motion_maximum_speed := 768
@export var motion_acceleration := 12288
@export var motion_gravity_active := false
@export var motion_gravity_direction := Vector2.DOWN
@export var motion_gravity_magnitude := 2018
@export var motion_jump_active := false
@export var motion_jump_strength := 0.5
@export var motion_sidescroller := false

@export_group("Animation")
@export var animation_visual_sprite : CanvasItem
@export var animation_active := false
@export var animation_squash_and_stretch_active := false
@export var animation_squash_and_stretch_target_scale := Vector2.ONE

var position_z := 0.0
var vz := 0.0
var input_vector := Vector2.ZERO
var facing_vector := Vector2.DOWN

signal direction_changed(direction)

################################## CODE ###################################

var parent : CharacterBody2D = get_parent()

func _ready():
	property_list_changed.emit()

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		parent = get_parent()

func _physics_process(delta):
	if Engine.is_editor_hint():
		return

	# Get the input vector
	input_vector = Input.get_vector(
		input_action_left,
		input_action_right,
		input_action_up,
		input_action_down
	)

	if input_vector:
		var a = facing_vector
		facing_vector = input_vector.normalized()
		if facing_vector != a:
			direction_changed.emit(facing_vector)

	# Move!
	match motion_mode:
		MovementMode.FREE:
			move_free(delta)

	# Juicy Effects
	if animation_squash_and_stretch_active:
		if not animation_visual_sprite:
			printerr("Movement2D has no visual sprite associated and can't animate.")
			return
		var target_scale = animation_squash_and_stretch_target_scale
		if Input.is_action_just_pressed(input_action_left) or Input.is_action_just_pressed(input_action_right):
			animation_visual_sprite.scale.x = target_scale.x * 2.0
			animation_visual_sprite.scale.y = target_scale.y * 0.5
		if Input.is_action_just_pressed(input_action_up) or Input.is_action_just_pressed(input_action_down):
			animation_visual_sprite.scale.x = target_scale.x * 0.5
			animation_visual_sprite.scale.y = target_scale.y * 2.0
		animation_visual_sprite.scale = animation_visual_sprite.scale.move_toward(
			target_scale,
			delta * 10.0 * target_scale.x
		)

func move_free(delta):
	# If gravity is active, move horizontally and fall
	if motion_gravity_active:
		parent.velocity.x = move_toward(parent.velocity.x, input_vector.x * motion_maximum_speed, motion_acceleration * delta)
		parent.velocity += motion_gravity_direction * motion_gravity_magnitude * delta
		parent.move_and_slide()
		if parent.is_on_floor() and Input.is_action_pressed(input_action_up) and motion_jump_active:
			parent.velocity.y = - motion_gravity_magnitude * motion_jump_strength
	else:
		parent.velocity = parent.velocity.move_toward(
			input_vector *\
			input_scale *\
			motion_maximum_speed,
			motion_acceleration * delta
		)
		parent.move_and_slide()
		position_z += vz * delta
		animation_visual_sprite.position.y = min(- position_z, 0)
		var target_scale = animation_squash_and_stretch_target_scale

		if position_z > 0.0:
			vz -= motion_gravity_magnitude * delta * 2
		if position_z < 0.0:
			position_z = 0.0
			vz = 0.0
			if animation_squash_and_stretch_active:
				animation_visual_sprite.scale.x = target_scale.x * 2.0
				animation_visual_sprite.scale.y = target_scale.y * 0.5
		if position_z == 0 and Input.is_action_pressed(input_action_jump) and motion_jump_active:
			vz = motion_gravity_magnitude * motion_jump_strength
			if animation_squash_and_stretch_active:
				animation_visual_sprite.scale.x = target_scale.x * 0.5
				animation_visual_sprite.scale.y = target_scale.y * 2.0
	pass

######################### EDITOR CONFIGURATION #########################

func _get_configuration_warning():
	if not get_parent() is CharacterBody2D:
		return "Parent must be of type CharacterBody2D"
	return ""
