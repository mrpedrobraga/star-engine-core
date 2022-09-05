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
##The action that triggers this event if trigger_condition is [code]ON_INTERACT[/code].
@export var interaction_action : String = "OK"
##The game state in which this event can be triggered.
@export var required_game_state : StringName = &"Overworld"

func _ready():
	area_entered.connect(_on_area_enter)
	area_exited.connect(_on_area_exit)

var _areas : Array[EventProber] = []

func _on_area_enter(area):
	if area is EventProber:
		_areas.push_back(area)
		
		if trigger_condition == TriggerCondition.ON_TOUCH:
			if Game.get_state() == required_game_state:
				_trigger()

func _input(ev):
	if not trigger_condition == TriggerCondition.ON_INTERACT:
		return
	if Input.is_action_just_pressed(interaction_action) and _areas.size() > 0:
		if Game.get_state() == required_game_state:
			_trigger()

func _on_area_exit(area):
	if area is EventProber:
		_areas.erase(area)

##Virtual function to be overriden by subclasses -- it's where the magic happens.
func _trigger():
	pass
