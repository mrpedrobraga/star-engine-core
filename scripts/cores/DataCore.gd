@icon("res://_engine/scripts/icons/icon_core_data.png")
extends __GameplayCoreBase
class_name DataCore

## Core class that handles game data.
##
## Assign this class to the 'Game' singleton for you to use it in the game.
## See: [GameInstance].[br][br]
##
## Saving and Loading? Resources? It's this class.

#--------- Game SAVE and LOAD ---------#

## Emitted when saving. [param file] is not the file path, but the save identifier.
signal on_saved(file)
## Emitted when loaded. [param file] is not the file path, but the save identifier.
signal on_loaded(file)

## The current game save data.
var data : GameSaveData

@export_category("Save Data")
var default_save_data : GameSaveData

## Creates a new save data with basic information.
func create_save_data (game_name : String) -> GameSaveData:
#	var m = GameSaveData.new()
#	m.game_name = game_name
#	m.facts = FactBase.new()
#	data = m
#	return m
	return default_save_data.duplicate()

func _ready():
	var userdir := DirAccess.open("user://")
	if not userdir.dir_exists("saves"):
		userdir.make_dir("saves")

## Saves the current game data to a file.
## [param file] is not the file path, but the save identifier.
func save_game(file: String = "save") -> int:
	ResourceSaver.save(data, "user://saves/"+file+".tres")
	return OK

## Saves the current game data from a file.
## [param file] is not the file path, but the save identifier.
func load_game(file: String = "save") -> int:
	var path ="user://saves/"+file+".tres"
	if not FileAccess.file_exists(path):
		Shell.print_err(
			"Missing Save File",
			"No save file "+file+" at the save directiory.",
			{"suggestions":""}
		); return ERR_FILE_NOT_FOUND
	
	data = load(path)
	# [DEBUG]
	print("[Game.Data] Loaded save file from " + path + ".")
	
	return OK
	

### Resource Management ###

# Dictionary that contains resource maps for the game, with resources inside.
# The resource maps in this dictionary are called "Resource Banks".

@export_category("Resources")

## The loaded resource banks.
## Resource banks are bases of similar resources.
## You can have a bank for music, one for dialogues,
## and one for rooms, etc.
@export var _resource_banks : ResourceMap

## Gets a resource given a path.
func get_resource(path_string : String):
	var path = path_string.simplify_path().split("/")
	
	print("[Game::DataCore] Loading resource from " + str(path))
	
	return _resource_banks.Nget_resource(path)

## Preloads the resource at a path.
func preload_resource(path_string : String):
	var path = path_string.simplify_path().split("/")
	
	print("[Game::DataCore] Preloading resource from " + str(path))
	
	_resource_banks.Npreload_resource(path)
