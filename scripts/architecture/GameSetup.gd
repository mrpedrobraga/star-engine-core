extends Resource
class_name GameSetup

## Class that holds data for how the same is set up when it launches.

@export_category("Architecture")
@export var root_scene : PackedScene

@export_category("State")
@export var initial_game_state : StringName = &"Overworld"

@export_category("Scene")
@export var first_room : PackedScene

@export_category("Character")
@export var character : Resource
@export var character_vessel_scene : PackedScene
