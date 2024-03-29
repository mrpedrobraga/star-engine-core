## Singleton that handles the many cores this engine profiles
## and the game state.
##
## This is class, provided for convenience,
## when creating you game you should probably not inherit
## this class; instead make your own taking this one as
## inspiration.
##
## For all of the Cores to work you need to provide them with a
## reference to this class by adding it as a singleton named
## 'Game'.
extends Node


#--------- SINGLETONS & SETUP ---------#

# These references are how you should trigger things in your game,
# calling Game.Audio.play_bgm or Game.Data.save_game, etc.

##The AudioCore for this game.
var Audio : AudioCore
##The DialogCutsceneCore for the game.
var DC : DialogCutsceneCore
##The DialogCutsceneCore for the game.
var Data : DataCore
##The DialogCutsceneCore for the game.
var Battle : BattleCore

const USER_INFO_PATH = "user://user_info.res"
##The persistent user information.
var user_info : UserInfo
##The initial [GameSetup]::[GameSaveData] used to set up this [Game].
var game_setup_save : GameSaveData

## Loads the [UserInfo] resource if it exists.
## If it doesn't (because it's the first time this game has loaded,
## or someone deleted it) it saves a new one there.
func load_user_info():
	if FileAccess.file_exists(USER_INFO_PATH):
		user_info = ResourceLoader.load(USER_INFO_PATH)
	else:
		user_info = UserInfo.new()
		save_user_info()

## Saves the user info to a file so it can be loaded afterwards.
func save_user_info():
	ResourceSaver.save(user_info, "user://user_info.res")

## Loads the save data from user_info.
## This is for games who don't implement a save select screen.
func load_last_save_data(game_name = ""):
	var save_file = user_info.save_file
	
	# Listen carefully, the save file is not stored in user_info,
	# it's a string with the name of the save file.
	# It then calls [member Data] to load the save file from the name.
	
	# [DEBUG]
	print("[Game] Overriding Save File Loading.")
	if FileAccess.file_exists("user://saves/%s.tres" % save_file) and false:
		Game.Data.load_game(save_file)
	else:
		# If a save file with that name doesn't exist,
		# it creates a brand new one.
		Game.Data.default_save_data = game_setup_save
		Game.Data.data = Game.Data.create_save_data(game_name)
		# Set the player character
		Game.Data.data.character.world_node = Game.Data.data.character_vessel_scene.instantiate()
		Game.Data.data.character.world_node.character = Game.Data.data.character
		Game.DC.camera_target = Game.Data.data.character.world_node
		Game.set_player_vessel(Game.Data.data.character)
		
		# [DEBUG]
		print("[Game] Created New Save File:\n\n" + str(Game.Data.data))
		Game.Data.save_game(user_info.save_file)

#--------- STATES ---------#

##A dictionary with all the current game states (__GameplayStateBase).
##Those are supposed to be Nodes, so they can be set to process or not.
var States := {
	&"Overworld" 	: null,
	&"Battle" 		: null,
	&"Minigame" 	: null,
}

##A dictionary with string references to all the characters in the map.
var Characters := {
	
}

## The current room loaded in the game.
var current_room : Room

##Emitted when the game state changes.
##@param state The state to which the Game changed.
signal state_changed(state)
var _current_state : StringName = &"Overworld"

##Sets the current game state.
func set_state( state : StringName ) -> void:
	if not States.has(state):
		Shell.print_err.call_deferred("NullReference", "State " + str(state) + " does not exist.")
	_current_state = state
	emit_signal("state_changed", state)

##Returns the current game state.
func get_state() -> StringName:
	return _current_state

##Processes custom function that runs for the current state.
func process_states() -> void:
	(States[_current_state] as __GameplayStateBase)._update()


#--------- Convenient Functions ---------#

## Changes the current room
func change_room(room_scene : PackedScene, transition_context : Dictionary = {}):
	var room_node = room_scene.instantiate().duplicate()
	if not room_node is Room:
		Shell.print_err.call_deferred("TypeError", "The given scene is not of type 'Room': " + str(room_scene))
		return
	else:
		for i in get_party():
			if i.world_node.is_inside_tree():
				i.world_node.get_parent().remove_child(i.world_node)
		
		Characters.clear()
		
		# TODO: transitions
		var old_room = States[&"Overworld"].get_node_or_null("../current_room")
		if old_room:
			old_room.name = "old_room"
			old_room.visible = false
			old_room.queue_free.call_deferred()
		# New room is now the current one.
		current_room = room_node
		current_room.visible = true
		current_room.name = "current_room"
		States[&"Overworld"].add_sibling(current_room)
		
		## Add the party characters in the scene.
		for i in get_party():
			var n = i.world_node
			current_room.spawn(n)
			
			if transition_context.has("target_marker"):
				var marker = current_room.get_marker(transition_context.target_marker)
				if marker:
					n.global_position = marker.global_position
			## TODO: Move this to [Room], perhaps?
			elif current_room.resume_hotspot:
				n.global_position = floor(current_room.resume_hotspot.global_position)
			await get_tree().process_frame
		
		DC.camera_focus_on_target()
		
		current_room.initialize(
			transition_context
		)

##Returns the player's controlled character
func get_player_vessel() -> Character:
	return Data.data.current_vessel

##Returns the player's controlled character's node
func get_player_vessel_node() -> CharacterVessel2D:
	return Data.data.current_vessel.world_node

##Sets the player's controlled character
func set_player_vessel(character : Character) -> void:
	Data.data.current_vessel = character
	add_to_party(character)

##Sets the player's control of their vessel on or off.
func set_player_vessel_enabled(enabled : bool) -> void:
	Data.data.current_vessel.world_node.set_enabled(enabled)

##Returns the current party as specified in your GameSaveData
func get_party() -> Array[Character]:
	return Data.data.party

##Adds a character to the party
func add_to_party(character : Character) -> void:
	if not Data.data.party.has(character):
		Data.data.party.append(character)

##Removes a character to the party
func remove_from_party(character : Character) -> void:
	Data.data.party.erase(character)

##Clears the entire party.
func clear_party() -> void:
	Data.data.party.clear()


#--------- CUTE UNICODE ART ---------#

#░░░░░░░▀▄░░░░▄▀░░░░░░░░
#░░░░░░▄█▀████▀█▄░░░░░░░
#░░░░░█▀████████▀█░░░░░░
#░░░░░█░█▀▀▀▀▀▀█░█░░░░░░
#░░░░░░░░▀▀░░▀▀░░░░░░░░░
