extends Resource
class_name GameSaveData

##Class for saving your game's information easily.

# GAME PROPERTIES
@export var game_name := "Unnamed Game"
@export var game_version := "1.0"

# RESUME HOTSPOT
@export var resume_hotspot_scene_path = "__tests/scenes/_stest_battle_patterns.tscn"
@export var resume_hotspot_anchor = "reload_point"

# Character PROPERTIES
var current_vessel := "unknown"
var party : Array[Character] = []

# SWITCHES / GAME PROGRESSION
@export var switches := {}

# OTHER GAME DATA
@export var inventories : Dictionary = {}

func _to_string():
	return str(game_name) + "\n" + "Version: " + str(game_version) + "\n\n"
