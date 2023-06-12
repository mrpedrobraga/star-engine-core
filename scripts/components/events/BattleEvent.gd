@tool
@icon("res://_engine/scripts/icons/icon_battleevent.png")
extends __EventBase
class_name BattleEvent

## Class that executes a [StarScript] when interacted with.

@export var battle_instance : BattleInstance

@export_category("Opponents")

@export var character_resources : Array[Character]
@export var world_nodes : Array[NodePath]

func _init():
	color = Color(0.99999982118607, 0.36941140890121, 0.13345029950142)

func _ready():
	await get_tree().process_frame
	super()
	if not Engine.is_editor_hint():
		Game.current_room.register_object(StringName("battle_" + name), self)

func _trigger():
	var tbkp = trigger
	trigger = TriggerCondition.NEVER
	var bi_dupl = battle_instance.duplicate()
	bi_dupl.allies.assign([])
	bi_dupl.opponents.assign([])
	for i in character_resources.size():
		var ch := character_resources[i]
		
		ch.world_node = get_node(world_nodes[i])
		bi_dupl.opponents.append(ch)
	Game.Battle.engage_battle(bi_dupl)
	
	await Game.Battle.battle_dismissed
	# Await timeout after touching the battle event.
	await get_tree().create_timer(2.0).timeout
	trigger = tbkp

var _icon = preload("res://_engine/scripts/icons/icon_battleevent.png")

func _draw():
	super()
	if (not Engine.is_editor_hint()) and (not draw_on_game_also):
		return
	
	draw_set_transform(Vector2(size/2) + Vector2.UP * icon_offset, 0.0, Vector2(float(_SCALE), float(_SCALE)))
	draw_texture(_icon, 0.5 * (-_icon.get_size()))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
