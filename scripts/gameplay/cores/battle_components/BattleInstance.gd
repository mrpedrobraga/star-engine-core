extends Resource
class_name BattleInstance

##Class that contains an instance of a battle. Used by BattleCore.

##An array containing the ally Characters.
var allies : Array[Character] = []
##An array containing the opponent Characters.
@export var opponents := []
##An array containing the current targets of the last executed action.
var current_targets := []

##The index of the turn the battle is currently at.
var turn_index := 0

##The actions chosen by the player to be executed.
var turn_ally_choices : Array = []

func _to_string():
	return "{" + str(allies) + " v.s. " + str(opponents) +  "}"
