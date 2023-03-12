extends Resource
class_name GameSaveData

##Class for saving your game's information easily.

#--------- GAME PROPERTIES ---------#

## The name of the game.
@export var game_name := "Unnamed Game"
## The version of the game.
@export var game_version := "1.0"
## The version of the save file.
## Save files should change version
## when they start to become backwards incompatible.[br][br]
## An older save file could still be opened in a new version of the game,
## but a newer just can't be opened in an older game.
@export var save_file_version := "1.0"

#--------- RESUME HOTSPOT ---------#

## The room to resume to when loading this save.
@export var resume_room = "__tests/scenes/_stest_battle_patterns.tscn"
## The anchor to resume to when loading this save.
@export var resume_anchor = "reload_point"

#--------- Character PROPERTIES ---------#

## The current little guy ([Character]) you are controlling.
var current_vessel = null
## The current vessel's scene.
var current_vessel_scene : PackedScene
## The characters in your party. Includes [param current_vessel].
var party : Array[Character] = []

#--------- SWITCHES / GAME PROGRESSION ---------#
@export var facts : FactBase

#--------- OTHER GAME DATA ---------#

# Nothing here yet.
# You can, of course, extend this class
# and add your own entries.

#--------- Inventories ---------#

@export var inventories : Dictionary = {}

func _to_string():
	return str(game_name) + "\n" + "Version: " + str(game_version) + "\n\n" + JSON.stringify(facts._data, "\t")
