extends GameSetup
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
@export var resume_room : PackedScene
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

## Patches the content of an other [GameSaveData]
func patch_with(next_episode_setup : GameSaveData):
	var patch_properties = [
		&"game_version", &"save_file_version",
		&"resume_room", &"resume_anchor",
		&"current_vessel", &"current_vessel_scene",
		&"party"
	]
	
	for prop in patch_properties:
		if not next_episode_setup.get(prop) in [null, ""]:
			self.set(prop, next_episode_setup.get(prop))

func _to_string():
	var result := ""
	
	result += str(game_name) + "\n"
	result += "Version: " + str(game_version) + "\n\n"
	
	result += "FACTS\n"
	result += JSON.stringify(facts._data, "\t") + "\n\n"
	
	result += "ITEMS\n"
	for i in inventories.keys():
		result += str(i) + ":\n" + str(inventories[i])
	result += "\n"
	
	return result
