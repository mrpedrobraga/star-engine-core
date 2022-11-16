extends Control
class_name GameInstance
@icon("res://_engine/scripts/icons/icon_dialogevent.png")

## Class that encapsulates an instance of a game,.
##
## It loads Core nodes from the scene tree plus
## handle some things.
##
## Instead of instantiating this class, you should
## probably [i]write your own[/i].

@export_category("Cores")
@export var audio_core : Node
@export var dialog_cutscene_core : Node
@export var data_core : Node
@export var battle_core : Node

@export_category("Setup")
@export var first_room : PackedScene

func _ready():
	
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

func start():
	print ("Setting up game.")
	
	# Load the first game room (or the main menu)
	Game.change_room(first_room)

var _window_mode_before_fullscreen := Window.MODE_MINIMIZED
func _input(ev):
	if Input.is_action_just_pressed("ui_fullscreen"):
		var w := get_tree().root
		if w.mode == Window.MODE_FULLSCREEN:
			w.mode = _window_mode_before_fullscreen
		else:
			_window_mode_before_fullscreen = w.mode
			w.mode = Window.MODE_FULLSCREEN
