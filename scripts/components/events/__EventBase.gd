@tool
##Abstract class that handles events caused by some trigger --
##i.e. EventProbers touching/interacting, the start of the scene,
##or every tick.
extends Area2D
class_name __EventBase
@icon("res://_engine/scripts/icons/icon_event_small.png")

enum TriggerCondition {
	ON_TOUCH, ON_INTERACT, ON_SCENE_START, EVERY_TICK
}

##The trigger condition for the event.
@export var trigger_condition : TriggerCondition

@export_group("Trigger")

@export var trigger_size : Vector2i = Vector2i(4, 2):
	set(v):
		trigger_size = v
		queue_redraw()
const SCALE := 6
const TILE_SIZE := 16
@export var color = Color.WHITE:
	set(v):
		color = v
		queue_redraw()
var trigger_xform : Transform2D:
	set(v):
		trigger_xform = v
		queue_redraw()

@export_group("")

##The action that triggers this event if trigger_condition is [code]ON_INTERACT[/code].
@export var interaction_action : String = "OK"
##The game state in which this event can be triggered.
@export var required_game_state : StringName = &"Overworld"

func _ready():
	if Engine.is_editor_hint():
		modulate = Color.WHITE
		return
	
	area_entered.connect(_on_area_enter)
	area_exited.connect(_on_area_exit)
	
	collision_layer = 0b10
	collision_mask = 0b10
	
	var a := CollisionShape2D.new()
	a.scale = Vector2(SCALE, SCALE)
	var s := RectangleShape2D.new()
	s.size = trigger_size * TILE_SIZE
	a.shape = s
	add_child(a)
	

var _areas : Array[EventProber] = []

func _on_area_enter(area):
	if area is EventProber:
		_areas.push_back(area)
		if trigger_condition == TriggerCondition.ON_TOUCH:
			if Game.get_state() == required_game_state:
				_trigger()

func _input(ev):
	if Engine.is_editor_hint():
		return
	
	if not trigger_condition == TriggerCondition.ON_INTERACT:
		return
	if _areas.size() > 0:
		if Input.is_action_just_pressed(interaction_action):
			if Game.get_state() == required_game_state:
				_trigger()

func _on_area_exit(area):
	if area is EventProber:
		_areas.erase(area)

##Virtual function to be overriden by subclasses -- it's where the magic happens.
func _trigger():
	pass

func _draw():
	if not Engine.is_editor_hint():
		return
	
	var b := Vector2(trigger_size) * SCALE * TILE_SIZE
	var a := -b/2
	
	draw_set_transform_matrix(trigger_xform)
	
	draw_rect(Rect2(a, b), Color(color, 0.5), true)
	draw_rect(Rect2(a, b), color, false, 1.0 * SCALE)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _get_configuration_warnings():
	return []
