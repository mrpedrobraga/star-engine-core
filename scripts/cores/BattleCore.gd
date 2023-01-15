##CORE class that handles turn-based battles!
extends __GameplayCoreBase
class_name BattleCore
@icon("res://_engine/scripts/icons/icon_core_battle.png")

signal battle_requested
signal battle_engaged
signal battle_dismiss_request
signal battle_dismissed

##The current battle being played out!
var battle_instance : BattleInstance
##READ; Returns true if currently in [b]battle[/b].
var is_in_battle : bool = false

@export_category("Battle UI")

@export var ally_choices_menu_handler : Node

##The battle loop, where the battle routine plays out.
func battle_loop():
	#TODO: Animate characters into their formation.
	
	while is_in_battle:
		await do_ally_turns()
		
		# Break if the ally choices resulted in battle dismissal.
		if not is_in_battle: break
		
		await do_opponent_turns()
		
		# Break if the opponent's choices resulted in battle dismissal.
		if not is_in_battle: break
		
		Shell.printx ("-------------------")

	Shell.printx("-------------------", " BATTLE END!!! ")
	#TODO: Put characters back on the overworld.

##A class that holds a single player choice for the what an ally will do in a battle.
class AllyBattleChoice:
	##A string containing the choice's type, is it an attack or an item use?
	var type : String = "unknown"
	##The selected choice (the attack, item or skill)
	var val
	###An array with all the targets of this choice
	var targets : Array[Character] = []

enum {
	ATTACK, SKILL, ACT, ITEM
}

var ally_choices : Dictionary

##Executes the aforementioned set of actions the allies were told to take.
func do_ally_turns():
	await ask_ally_choices()
	await execute_ally_choices(ally_choices)
	await get_tree().create_timer(1.0).timeout

##Executes the opponent actions -- attacks, acts, items and spares.
func execute_ally_choices(d : Dictionary):
	# The dictrepr passed into this function must be written in a specific format.
	# The main level is an iterator menu, which contains an array (sub) for all the character's actions.
	var character_actions : Array = d.sub
	
	var ch_index = 0
	for cha in character_actions:
		# Each individual character action is encoded as such:
		# index, label, sub
		var ch_name = battle_instance.allies[ch_index].name
		
		### THIS IS ALL INCOMPLETE -- THERE'S NO NOTION OF TARGET!
		match cha.index:
			ATTACK:
				# cha.sub.value stores the attack id
				var attack = cha.sub.value
				Shell.printx(" :: " + ch_name + " used attack " + cha.sub.label)
			SKILL:
				# cha.sub.value stores the skill id
				var skill = cha.sub.value
				Shell.printx(" :: " + ch_name + " used skill " + cha.sub.label)
			ACT:
				# cha.sub.value stores the act id
				var act = cha.sub.value
				Shell.printx(" :: " + ch_name + " used act " + cha.sub.label)
			ITEM:
				# cha.sub.value stores the item stack object
				var item = cha.sub.value
				Shell.printx(" :: " + ch_name + " used item " + cha.sub.label)
		ch_index += 1
	await get_tree().process_frame

##Asks the player, one for one, what action the allies should execute.
func ask_ally_choices():
	### GENERATE THE MENU FOR THE PLAYER TO CHOOSE ##
	
	var _mh_parent = ally_choices_menu_handler.get_parent()
	var _mh_sub = _mh_parent.get_node("SubMenu")
	var _m_allies
	var all_ally_choices : Array[Menu] = []
	# For all the allies
	for battle in battle_instance.allies:
		# Create the menu for this ally.
		var m_ally_choice : Menu
		
		# Create all the submenus.
		
		var m_attack = Menu.create(
			["Firebolt", "Thunderstrike", "Waterhose"],
			[],
			true,
			_mh_sub
		);
		
		var m_skill = Menu.create(
			["bubbles", "memoria_clavem", "amnesia"],
			["Bubbles", "Memoria Clavem", "Amnesia"],
			true,
			_mh_sub
		);
		
		var m_act = Menu.create(
			battle_instance.get_ACTs_for(battle_instance.allies[0]).duplicate(),
			[],
			true,
			_mh_sub
		);
		
		var m_item = Menu.create(
			["pepperoni_pizza", "apple", "macaron"],
			["Pizza", "Apple", "Macaron"],
			true,
			_mh_sub
		);
		
		# Assign all the submenus to the choice menu
		m_ally_choice = Menu.create(
			[m_attack, m_skill, m_act, m_item],
			["ATTACK", "SKILL", "ACT", "ITEM"],
			true,
			ally_choices_menu_handler
		);
		
		all_ally_choices.push_back(m_ally_choice)
	
	_m_allies = Menu.create(
		all_ally_choices,
		['Claire'],
		false,
		null
	);
	_m_allies.is_iterator = true
	
	## OPEN THE MENU AND AWAIT FOR THE PLAYER TO COMMIT ##
	
	_m_allies.open()
	await _m_allies.choice_made
	
	ally_choices = (_m_allies.get_dict_repr())

##Executes the opponent actions -- attacks, acts and spares.
func do_opponent_turns():
	await get_tree().process_frame

##Requests a battle to start; engages the battle_loop.
func engage_battle(battle : BattleInstance):
	if is_in_battle: return
	
	is_in_battle = true
	battle_instance = battle
	
	battle_instance.setup()
	
	Shell.printx("-------------------" + " BATTLE START!!! ")
	Shell.printx(str(battle))
	Shell.printx("-------------------\n")
	
	# Animate the battle transition!
	battle_requested.emit()
	Game.Audio.bgm_pause()
	Game.Audio.battle_start()
	Game.set_state(&"Battle")
	battle_engage_transition()
	
	await get_tree().create_timer(0.2).timeout
	
	Game.Audio.battle_music_play()
	battle_engaged.emit()
	
	await get_tree().process_frame
	
	battle_loop()

@onready var _ally_formation := %AllyFormations

func battle_engage_transition():
	var tween := create_tween()
	
	var counter := 0
	_ally_formation.battler_count = battle_instance.allies.size()
	_ally_formation.reorganize(false)
	
	var b = battle_instance.allies
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
