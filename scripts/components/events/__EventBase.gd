@tool
@icon("res://_engine/scripts/icons/icon_event_small.png")
extends Control
class_name __EventBase
##Abstract class that handles events caused by some trigger --
##i.e. EventProbers touching/interacting, the start of the scene,
##or every tick.

enum TriggerCondition {
	ON_TOUCH, ON_INTERACT, ON_SCENE_START, EVERY_TICK, NEVER
}

@export_category("Trigger")

##The trigger condition for the event.
@export var trigger := TriggerCondition.ON_TOUCH
var collision_layer : int = 0b10
@export var trigger_with_raycast : bool = false:
	set(v):
		trigger_with_raycast = v
		if(trigger_with_raycast):
			collision_layer = raycast_layer
			_area.collision_layer = raycast_layer 
			_area.collision_mask = raycast_layer
		else:
			collision_layer = 0b10
			_area.collision_layer = 0b10
			_area.collision_mask = 0b10
##The offset of the icon, in pixels.
@export_range(0.0, 64.0, 2.0) var icon_offset : float = 0.0:
	set(v):
		icon_offset = v
		queue_redraw()
##The colour of the event's rectangle in the scene.
@export var color = Color.WHITE:
	set(v):
		color = v
		queue_redraw()
##Also draw in the game (not only in the editor)?
@export var draw_on_game_also : bool = false
## The transform of the trigger area (the bounding box).
var trigger_xform : Transform2D:
	set(v):
		trigger_xform = v
		queue_redraw()

@export_group("Meta")
## The layer where the event will look for raycast [EventProber]s.
@export_flags_2d_physics var raycast_layer := 0b100

##The action that triggers this event if trigger_condition is [code]ON_INTERACT[/code].
@export var interaction_action : StringName = &"OK"
##The game state in which this event can be triggered.
@export var required_game_state : StringName = &"Overworld"

var _mouse_over := false
var _area := Area2D.new()
var _shape := CollisionShape2D.new()
var _col_rect := RectangleShape2D.new()

@warning_ignore("unused_variable")
var _SCALE := 1

func _init():
	layout_direction = Control.LAYOUT_DIRECTION_LTR

func _ready():
	use_parent_material = true
	if Engine.is_editor_hint():
		modulate = Color.WHITE
		return
	
	_area.area_entered.connect(_on_area_enter)
	_area.area_exited.connect(_on_area_exit)
	_area.collision_layer = collision_layer 
	_area.collision_mask = collision_layer
	mouse_entered.connect((func ():
		_mouse_over = true
	))
	mouse_exited.connect((func ():
		_mouse_over = false
	))
	
	_area.add_child(_shape)
	add_child(_area)
	_shape.shape = _col_rect
	_area.visible = false
	_area.position = size/2
	_col_rect.size = size
	queue_redraw()
	
	if trigger == TriggerCondition.ON_SCENE_START:
		_trigger()

func _physics_process(delta):
	if trigger == TriggerCondition.EVERY_TICK:
		_trigger()

func _notification(what):
	match what:
		NOTIFICATION_RESIZED:
			queue_redraw()
			pivot_offset = size/2
			_col_rect.size = size

var _areas : Array[EventProber] = []

func _on_area_enter(area):
	if area is EventProber:
		_areas.push_back(area)
		if trigger == TriggerCondition.ON_TOUCH:
			if Game.get_state() == required_game_state:
				_trigger()

var _activated := false

func _input(ev):
	if Engine.is_editor_hint():
		return
		
	if _activated:
		return
	
	if not trigger == TriggerCondition.ON_INTERACT:
		return
	if _areas.size() > 0:
		if Input.is_action_just_pressed(interaction_action):
			if Game.get_state() == required_game_state:
				_activated = true
				set_deferred("_activated", false)
				_trigger()

func _on_area_exit(area):
	if area is EventProber:
		_areas.erase(area)

##Virtual function to be overriden by subclasses -- it's where the magic happens.
func _trigger():
	pass

func _draw():
	if (not Engine.is_editor_hint()) and (not draw_on_game_also):
		return
	
	draw_rect(Rect2(Vector2(), size), Color(color, 0.2), true)
	draw_rect(Rect2(Vector2() + Vector2(0.5, 0.5), size - Vector2.ONE), color, false, _SCALE)
