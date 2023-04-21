extends Component
class_name BattlerScript

## Class that contains the script for a single battler.

##If this battler is an ally.
@export var is_ally := false

##A reference to the currently active battle!
var battle : BattleInstance

## Some default icons
const icon_wait = preload("res://packs/invo_SHARED/_game_data/choices/icon_wait.tres")
const icon_talk = preload("res://packs/invo_SHARED/_game_data/choices/icon_talk.tres")
const icon_spare = preload("res://packs/invo_SHARED/_game_data/choices/icon_spare.tres")

signal turn_finished

######### FIGHTER ACTIONS

##Virtual; executes a turn for this battler.
func _do_turn(turn_index : int) -> void:
	# Inherit with the response for character's action in this turn.
	await get_tree().process_frame
	turn_finished.emit()

##Virtual; executes an attack from this battler.
func _attack(characters : Array[Character]):
	#BattleCore.battle_instance.current_targets = characters
	await get_tree().process_frame

func _dialog(pool : StarScript, key : StringName):
	Game.DC.enter_cutscene()
	await Game.DC.dialog(pool, key)
	Game.DC.exit_cutscene()

######### RESPONSES TO ALLY ACTIONS

##Virtual; responds to an Ally's attack.
func _handle_attacked(attacker : Character, attack, success : bool):
	await get_tree().process_frame

##Virtual; responds to an Ally's Action.
func _handle_ACT(character : Character, act_name : String) -> void:
	# Inherit with the result of the used ACT.
	await get_tree().process_frame

##Virtual; returns the list of available ACTs for the given character.
func _get_ACTs(character_name : String) -> Array[String]:
	# Inherit with the currently available ACTs
	# for the given character.
	return ['none']

##Virtual; returns the list of labels for the available ACTs for the given character.
func _get_ACT_labels(character_name : String) -> Array[String]:
	# Inherit with the currently available ACTs
	# for the given character.
	return ['None']

##Virtual; returns the list of icons for the available ACTs for the given character.
func _get_ACT_icons(character_name : String) -> Array[Texture2D]:
	# Inherit with the currently available ACTs
	# for the given character.
	return []
