extends Resource
class_name GameSaveData

##Class for saving your game's information easily.

# GAME PROPERTIES
@export var game_name := "Unnamed Game"
@export var game_version := "1.0"

# RESUME HOTSPOT
@export var resume_room = "__tests/scenes/_stest_battle_patterns.tscn"
@export var resume_anchor = "reload_point"

# Character PROPERTIES
var current_vessel = null
var current_vessel_scene : PackedScene
var party : Array[Character] = []

# SWITCHES / GAME PROGRESSION
@export var facts : FactBase

# OTHER GAME DATA
@export var inventories : Dictionary = {}

func _to_string():
	return str(game_name) + "\n" + "Version: " + str(game_version) + "\n\n" + JSON.stringify(facts._data, "\t")
