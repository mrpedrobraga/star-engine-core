extends Resource
class_name GameSetup

## Class that holds data for how the game is set up when it launches.
##
## It's what defines the state of the game if no save file is loaded.

@export_category("Architecture")
@export var root_scene : PackedScene

@export_category("State")
@export var initial_game_state : StringName = &"Overworld"

@export_category("Character")
@export var character : Resource
@export var character_vessel_scene : PackedScene
