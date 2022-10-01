##CORE class that handles turn-based battles!
extends __GameplayCoreBase
class_name BattleCore
@icon("res://core/scripts/icons/icon_event_pathway.svg")

signal battle_requested
signal battle_engaged
signal battle_dismiss_request
signal battle_dismissed

##The current battle being played out!
var battle_instance : BattleInstance
##READ; Returns true if currently in [b]battle[/b].
var is_in_battle : bool = false

##The battle loop, where the battle routine plays out.
func battle_loop():
	#TODO: Animate characters into their formation.
	
	while is_in_battle:
		print("[Game::BattleCore] Asking for ally choices!")
		await ask_ally_choices()
		
		print("[Game::BattleCore] Executing the allies' turns!")
		await do_ally_turns()
		
		# Break if the ally choices resulted in battle dismissal.
		if not is_in_battle: break
		
		print("[Game::BattleCore] Executing the opponents' turns!")
		await do_opponent_turns()

	print("[Game::BattleCore] Battle diffused!")
	
	#TODO: Put characters back on the overworld.

##A class that holds a single player choice for the what an ally will do in a battle.
class AllyBattleChoice:
	##A string containing the choice's type, is it an attack or an item use?
	var type : String = "unknown"
	##The selected choice (the attack, item or skill)
	var val
	###An array with all the targets of this choice
	var targets : Array[Character] = []

##Asks the player, one for one, what action the allies should execute.
func ask_ally_choices():
	await get_tree().process_frame

##Executes the aforementioned set of actions the allies were told to take.
func do_ally_turns():
	await get_tree().process_frame

##Executes the opponent actions -- attacks, acts and spares.
func do_opponent_turns():
	await get_tree().process_frame

##Requests a battle to start; engages the battle_loop.
func engage_battle(battle : BattleInstance):
	if is_in_battle: return
	
	is_in_battle = true
	battle_instance = battle
	
	battle_instance.allies = Game.Data.data.party
	
	Shell.printx("[Game::Battle] Engaging on a battle: " + str(battle))
	
	# Animate the battle transition!
	battle_requested.emit()
	Game.Audio.bgm_pause()
	Game.Audio.battle_start()
	Game.set_state(&"Battle")
	battle_engage_transition()
	
	await get_tree().create_timer(0.2).timeout
	
	Game.Audio.battle_music_play()
	battle_engaged.emit()

@onready var _ally_formation := %AllyFormations

func battle_engage_transition():
	var tween := create_tween()
	
	var counter := 0
	_ally_formation.battler_count = battle_instance.allies.size()
	_ally_formation.reorganize(false)
	
	for chh in battle_instance.allies:
		var ch : Node2D = chh.world_node
		
		var gp = ch.global_position
		
		ch.set_meta(&"world_parent", ch.get_parent())
		ch.set_meta(&"world_position", ch.global_position)
		
		ch.get_parent().remove_child(ch)
		var parent = _ally_formation.get_child(counter)
		parent.add_child(ch)
		
		ch.global_position = gp
		
		tween.parallel().tween_property(
			ch,
			"position",
			Vector2.ZERO,
			0.5
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		
		counter += 1
	tween.play()

##Dismisses the battle and breaks from the battle loop.
func dismiss_battle():
	if not is_in_battle: return
	
	# Animate the battle transition!
	battle_dismiss_request.emit()
	
	Game.Audio.battle_music_stop()
	
	battle_dismiss_transition()
	
	is_in_battle = false
	battle_instance = null
	
	await get_tree().create_timer(0.2).timeout
	
	Game.Audio.bgm_resume()
	Game.set_state(&"Overworld")
	battle_dismissed.emit()

func battle_dismiss_transition():
	for chh in battle_instance.allies:
		var tween := create_tween()
		var ch : Node2D = chh.world_node
		
		var original_parent = ch.get_meta(&"world_parent", ch.get_parent())
		var original_position = ch.get_meta(&"world_position", ch.position)
		
		tween.tween_property(
			ch,
			"global_position",
			original_position,
			0.5
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		
		tween.tween_callback(func():
			var gp = ch.global_position
		
			ch.get_parent().remove_child(ch)
			original_parent.add_child(ch)
			
			ch.global_position = gp
		)
		
		tween.play()
