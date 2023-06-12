extends Resource
class_name BattleInstance

##Class that contains an instance of a battle. Used by BattleCore.

##An array containing the ally Characters.
@export var allies : Array[Character] = []
##An array containing the opponent Characters.
@export var opponents : Array[Character] = []
##A master script, for battles where the team members don't have individual scripts.
@export var master_battle_script : Script
var master_battle_object : BattlerScript
##Useful array containing both the allies and opponents.
var battlers : Array[Character] = []
var battlers_dict : Dictionary = {}
##An array containing the current targets of the last executed action.
var current_targets := []

##The index of the turn the battle is currently at.
var turn_index := 0

##The actions chosen by the player to be executed.
var turn_ally_choices : Array = []

## Sets up the battle.
func setup():
	allies.clear()
	battlers.clear()
	battlers_dict = {}
	current_targets = []
	
	if allies.is_empty():
		allies = Game.get_party()
	
	# Create the master battle object.
	if master_battle_script:
		master_battle_object = master_battle_script.new()
		master_battle_object.battle = self
		Game.Battle.add_child(master_battle_object)
		Game.Battle.battle_dismissed.connect(master_battle_object.queue_free)
	
	for opp in opponents:
		opp.battler_object = null
		if opp.battler_script:
			opp.battler_object = opp.battler_script.new()
			opp.battler_object.owner_character = opp
			opp.battler_object.battle = self
			Game.Battle.add_child(opp.battler_object)
			Game.Battle.battle_dismissed.connect(opp.battler_object.queue_free)
	
	battlers.assign(allies + opponents)
	for battler in battlers:
		battlers_dict[battler.name] = battler

func _to_string():
	return "{" + str(allies) + " v.s. " + str(opponents) +  "}"
