extends Resource
class_name StatusEffect

## Class that handles Status Effects in Star.

@export_category("Info")

@export var display_name : String = "Unknown"

signal should_be_removed

## Virtual; Called when the a battle starts.
func _battle_start(battle_instance : BattleInstance):
	pass

## Virtual; Called when a battle ends.
func _battle_end(battle_instance : BattleInstance):
	pass

## Virtual; Called when some character's turn starts.
func _character_turn_start(ch:Character, is_ally:bool):
	pass

## Virtual; Called when some character's turn ends.
func _character_turn_end(ch:Character, is_ally:bool):
	pass

## Virtual; Called before the allies' actions are executed, but after
## the player already chose them.
func _allies_turn_start():
	pass

## Virtual; Called when all allies' choices were executed.
func _allies_turn_end():
	pass

## Virtual; Called when the opponents' turn starts.
func _opponents_turn_start():
	pass

## Virtual; Called when all the opponents executed their actions.
func _opponents_turn_end():
	pass

## Virtual; Called when a round begins.
func _round_start():
	pass

## Virtual; Called when a round ends, and everyone's actions are executed.
func _round_end():
	pass

## Virtual; Called consistently if you want this to have an
## ongoing effect.
func _process(delta:float):
	pass

#####

## To be overriden;
## When a character receives a stat alteration,
## it passes it through all its status effects as filters.
func _intercept_stat_alteration(stat_alteration) -> CharacterStatsAlteration:
	return stat_alteration

## To be overriden;
## Called when the host of the status effect
## "falls down," i.o. gets KO'd or dies.
func _on_host_fall_down():
	should_be_removed.emit()
