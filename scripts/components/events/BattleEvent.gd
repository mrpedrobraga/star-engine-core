@tool
@icon("res://_engine/scripts/icons/icon_battleevent.png")
extends __EventBase
class_name BattleEvent

## Class that executes a [StarScript] when interacted with.

@export var battle_instance : BattleInstance

func _init():
	color = Color(0.99999982118607, 0.36941140890121, 0.13345029950142)

func _trigger():
	print("ouchie!")

var _icon = preload("res://_engine/scripts/icons/icon_battleevent.png")

func _draw():
	super()
	if (not Engine.is_editor_hint()) and (not draw_on_game_also):
		return
	
	draw_set_transform(Vector2(size/2) + Vector2.UP * icon_offset, 0.0, Vector2(float(_SCALE), float(_SCALE)))
	draw_texture(_icon, 0.5 * (-_icon.get_size()))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
