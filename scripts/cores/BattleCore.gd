@icon("res://_engine/scripts/icons/icon_core_battle.png")
extends __GameplayCoreBase
class_name BattleCore

##CORE class that handles turn-based battles!
##
## Assign this class to the 'Game' singleton for you to use it in the game.
## See: [GameInstance].[br][br]
##

signal battle_requested
signal battle_engaged
signal battle_dismiss_request
signal battle_dismissed

##The current battle being played out!
var battle_instance : BattleInstance
##READ; Returns true if currently in [b]battle[/b].
var is_in_battle : bool = false

@export_category("UI")

@export var ally_choices_menu_handler : _MenuHandlerBase

##The battle loop, where the battle routine plays out.
func battle_loop():
	# Message the stfx that a round began.
	for ch in battle_instance.battlers:
		for stfx in ch.stats.status_effects:
			stfx._battle_start(battle_instance)
	
	var first_group_turn = _do_allies_turn
	var second_group_turn = _do_opponent_turns
	
	if battle_instance.opponents_have_advantage:
		first_group_turn = _do_opponent_turns
		second_group_turn = _do_allies_turn
	
	while is_in_battle:
		# Message the stfx that a round began.
		for ch in battle_instance.battlers:
			for stfx in ch.stats.status_effects:
				stfx._round_start()
		
		await first_group_turn.call()
		Shell.r_print ("-------------------")
		
		# Break if the first group's choices resulted in battle dismissal.
		if not is_in_battle: break
		
		await second_group_turn.call()
		Shell.r_print ("-------------------")
		
		# Break if the second groups's choices resulted in battle dismissal.
		if not is_in_battle: break
		
		# Message the stfx that a round ended.
		for ch in battle_instance.battlers:
			for stfx in ch.stats.status_effects:
				stfx._round_end()
		
		# Increase the turn index
		battle_instance.turn_index += 1

	# Message the stfx that a battle ended.
		for ch in battle_instance.battlers:
			for stfx in ch.stats.status_effects:
				stfx._battle_end(battle_instance)

	Shell.r_print("-------------------\nBATTLE END!!! ")
	#TODO: Put characters back on the overworld.

##VIRTUAL FUNCTION for the ally turns.
func _do_allies_turn():
	# Message the stfx that the it's the allies' turn.
	for ch in battle_instance.battlers:
		for stfx in ch.stats.status_effects:
			stfx._allies_turn_start()
	await get_tree().process_frame
	# Message the stfx that the allies' turn is over.
	for ch in battle_instance.battlers:
		for stfx in ch.stats.status_effects:
			stfx._allies_turn_end()
##VIRTUAL FUNCTION for the opponent's turns.
func _do_opponent_turns():
	# Message the stfx that it's the opponent's turn.
	for ch in battle_instance.allies + battle_instance.opponents:
		for stfx in ch.stats.status_effects:
			stfx._opponents_turn_start()
	await get_tree().process_frame
	# Message the stfx that the opponents' turn is over.
	for ch in battle_instance.allies + battle_instance.opponents:
		for stfx in ch.stats.status_effects:
			stfx._opponents_turn_end()

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
	battle_requested.emit()
	if is_in_battle: return
	
	is_in_battle = true
	battle_instance = battle
	
	battle_instance.setup()
	
	Shell.r_print("-------------------" + " BATTLE START!!! ")
	Shell.r_print(str(battle))
	Shell.r_print("-------------------\n")
	
	# Animate the battle transition!
	Game.Audio.bgm_pause()
	Game.Audio.battle_start()
	Game.set_state(&"Battle")
	
	await get_tree().create_timer(transition_duration).timeout
	
	battle_loop()

##Dismisses the battle and breaks from the battle loop.
func dismiss_battle():
	if not is_in_battle: return
	
	# Animate the battle transition!
	battle_dismiss_request.emit()
	
	Game.Audio.battle_music_stop()
	
	is_in_battle = false
	battle_instance = null
	
	await get_tree().create_timer(0.2).timeout
	
	Game.Audio.bgm_resume()
	Game.set_state(&"Overworld")
	battle_dismissed.emit()
