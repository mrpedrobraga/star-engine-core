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

##################### SINGLETONS #####################

##The AudioCore for this game.
var Audio : AudioCore
##The DialogCutsceneCore for the game.
var DC : DialogCutsceneCore
##The DialogCutsceneCore for the game.
var Data : DataCore
##The DialogCutsceneCore for the game.
var Battle : BattleCore

##################### STATES #####################

##A dictionary with all the current game states (__GameplayStateBase).
var States := {
	&"Overworld" 	: null,
	&"Battle" 		: null,
	&"Minigame" 	: null,
}

##Emitted when the game state changes.
##@param state The state to which the Game changed.
signal state_changed(state)
var _current_state : StringName = &"Overworld"

##Sets the current game state.
func set_state( state : StringName ) -> void:
	_current_state = state
	emit_signal("state_changed", state)

##Returns the current game state.
func get_state() -> StringName:
	return _current_state

##Processes custom function that runs for the current state.
func process_states() -> void:
	(States[_current_state] as __GameplayStateBase)._update()

##################### MAIN FUNCTIONS #####################

func _input(ev) -> void:
	# Handle fullscreen in desktops!
	if ev is InputEventKey:
		if ev.pressed and (ev.keycode == KEY_F4 or ev.keycode == KEY_F11):
			pass
			#OS.window_fullscreen = not OS.window_fullscreen

##################### CONVENIENCE FUNCTIONS #####################

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

##################### CUTE UNICODE ART #####################

#░░░░░░░▀▄░░░▄▀░░░░░░░░
#░░░░░░▄█▀███▀█▄░░░░░░░
#░░░░░█▀███████▀█░░░░░░
#░░░░░█░█▀▀▀▀▀█░█░░░░░░
#░░░░░░░░▀▀░▀▀░░░░░░░░░
