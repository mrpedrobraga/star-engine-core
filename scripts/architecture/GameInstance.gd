@icon("res://_engine/scripts/icons/icon_core_game.png")
extends Control
class_name GameInstance

## Class that encapsulates an instance of a game,.
##
## It loads Core nodes from the scene tree plus
## handle some things.[br][br]
##
## Instead of instantiating this class, you should
## probably [i]write your own[/i]. It can extend this one,
## though.

@export_category("Cores")
## A reference to an audio core.
@export var audio_core : AudioCore
## A reference to an dialog/cutscene core.
@export var dialog_cutscene_core : DialogCutsceneCore
## A reference to an data core.
@export var data_core : DataCore
## A reference to an battle core.
@export var battle_core : BattleCore

## Assigns the cores to the Game singleton and calls start on the next frame.
func _ready():
	## Utility to run into a scene instead of into the default scene.
	if CustomRunner.is_custom_running():
		var scene := load(CustomRunner.get_variable("scene"))
		Game.game_setup_save.resume_room = scene
		# [DEBUG]
		print("[GameInstance] Starting game at %s." % scene.resource_path)
	
	# Set up the Cores in [Game]
	
	if audio_core:
		Game.Audio = (audio_core)
	if data_core:
		Game.Data = (data_core)
	if dialog_cutscene_core:
		Game.DC = (dialog_cutscene_core)
	if battle_core:
		Game.Battle = (battle_core)
	
	start.call_deferred()

## Loads the game world so you can play.
## TODO: instead of calling it automatically, perhaps, it should be called from a main menu.
func start():
	print ("Setting up game.")
	
	# Load the first game room (or the main menu)
	Game.change_room(
		Game.game_setup_save.resume_room,
		{
			"is_first_room": true,
			"target_marker": "Reload"
		}
	)


var _window_mode_before_fullscreen := Window.MODE_MINIMIZED
func _input(ev):
	if Input.is_action_just_pressed("ui_fullscreen"):
		var w : Window = get_tree().root
		if w.mode == Window.MODE_FULLSCREEN:
			w.mode = _window_mode_before_fullscreen
		else:
			_window_mode_before_fullscreen = w.mode
			w.mode = Window.MODE_FULLSCREEN
