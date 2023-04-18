@tool
@icon("res://_engine/scripts/icons/icon_pathwayevent_small.png")
extends __EventBase
class_name PathwayEvent

## Class that executes a [StarScript] when interacted with.

## TODO: Make this a ResourceBank Entry
@export var next_room : String

## The name of the target marker (where the party will be placed).
@export var target_marker : StringName

@export_category("Transition")

@export var transition_in  : String = "wipe"
@export var transition_out : String = "wipe"

## Extra Transition Context.
@export var extra_transition_context : Dictionary

func _init():
	color = Color(0, 0.6052577495575, 0.61373966932297)

func _trigger():
	# TODO: Finish
	var transition_context : Dictionary = {
		"is_first_room": false,
		"transition_in": transition_in,
		"transition_out": transition_out,
		"target_marker": target_marker
	}
	
	transition_context.merge(extra_transition_context)
	
	Game.change_room (
		Game.Data.get_resource("SCN/" + next_room),
		transition_context
	)

var _icon = preload("res://_engine/scripts/icons/icon_pathwayevent_small.png")

func _draw():
	super()
	if (not Engine.is_editor_hint()) and (not draw_on_game_also):
		return
	
	draw_set_transform(Vector2(size/2) + Vector2.UP * icon_offset, 0.0, Vector2(float(_SCALE), float(_SCALE)))
	draw_texture(_icon, 0.5 * (-_icon.get_size()))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
