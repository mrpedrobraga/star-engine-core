##CORE class that handles turn-based battles!
@icon("res://_engine/scripts/icons/icon_core_battle.png")
extends __GameplayCoreBase
class_name BattleCore

signal battle_requested
signal battle_engaged
signal battle_dismiss_request
signal battle_dismissed

##The current battle being played out!
var battle_instance : BattleInstance
##READ; Returns true if currently in [b]battle[/b].
var is_in_battle : bool = false

@export_category("Battle UI")

@export var ally_choices_menu_handler : _MenuHandlerBase

##The battle loop, where the battle routine plays out.
func battle_loop():
	#TODO: Animate characters into their formation.
	
	while is_in_battle:
		await _do_ally_turns()
		Shell.printx ("-------------------")
		
		# Break if the ally choices resulted in battle dismissal.
		if not is_in_battle: break
		
		await _do_opponent_turns()
		Shell.printx ("-------------------")
		
		# Break if the opponent's choices resulted in battle dismissal.
		if not is_in_battle: break

	Shell.printx("-------------------", " BATTLE END!!! ")
	#TODO: Put characters back on the overworld.

##VIRTUAL FUNCTION for the ally turns.
func _do_ally_turns():
	await get_tree().process_frame
##VIRTUAL FUNCTION for the opponent's turns.
func _do_opponent_turns():
	await get_tree().process_frame

##A class that holds a single player choice for the what an ally will do in a battle.
class AllyBattleChoice:
	##A string containing the choice's type, is it an attack or an item use?
	var type : String = "unknown"
	##The selected choice (the attack, item or skill)
	var val
	###An array with all the targets of this choice
	var targets : Array[Character] = []

var ally_choices : Dictionary

## Engages a battle!
func engage_battle(battle : BattleInstance, transition_duration = 0.0):
	if is_in_battle: return
	
	is_in_battle = true
	battle_instance = battle
	
	battle_instance.setup()
	
	Shell.printx("-------------------" + " BATTLE START!!! ")
	Shell.printx(str(battle))
	Shell.printx("-------------------\n")
	
	# Animate the battle transition!
	Game.Audio.bgm_pause()
	Game.Audio.battle_start()
	Game.set_state(&"Battle")
	
	await get_tree().create_timer(transition_duration).timeout
	
	battle_loop()
