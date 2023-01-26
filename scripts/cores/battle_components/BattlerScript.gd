extends Component
class_name BattlerScript

## Class that contains the script for a single battler.

##If this battler is an ally.
@export var is_ally := false

##A reference to the currently active battle!
var battle : BattleInstance

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

######### RESPONSES TO ALLY ACTIONS

##Virtual; responds to an Ally's Action.
func _handle_ACT(character : Character, act_name : String) -> void:
	# Inherit with the result of the used ACT.
	await get_tree().process_frame

##Virtual; returns the list of available ACTs for the given character.
func _get_ACTs(character_name : String) -> Array[String]:
	# Inherit with the currently available ACTs
	# for the given character.
	return ['none']
