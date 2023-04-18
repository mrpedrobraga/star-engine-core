@tool
@icon("res://_engine/scripts/icons/icon_bgmevent.png")
extends __EventBase
class_name BGMEvent

## Class that executes a [StarScript] when interacted with.

## Use ResourceBankEntry instead!
@export var bgm_name : String

func _init():
	color = Color(1, 0.45034790039062, 0.15234375)

func _trigger():
	Shell.x_command(StarScriptCommand.create(&"bgm", ["play", bgm_name]), {})

var _icon = preload("res://_engine/scripts/icons/icon_bgmevent.png")

func _draw():
	super()
	if (not Engine.is_editor_hint()) and (not draw_on_game_also):
		return
	
	draw_set_transform(Vector2(size/2) + Vector2.UP * icon_offset, 0.0, Vector2(float(_SCALE), float(_SCALE)))
	draw_texture(_icon, 0.5 * (-_icon.get_size()))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _get_configuration_warnings():
	var w = []
	
	if bgm_name in [null, ""]:
		w.append("This event has no assigned bgm.")
	
	return w
