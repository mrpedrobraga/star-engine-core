extends __GameplayCoreBase
class_name DataCore
@icon("res://_engine/scripts/icons/icon_core_data.png")

### Game SAVE and LOAD ###

signal on_saved(file)
signal on_loaded(file)

var data : GameSaveData

## Creates a new save data with basic information.
func create_save_data (game_name : String) -> GameSaveData:
	var m = GameSaveData.new()
	
	m.game_name = game_name
	m.facts = FactBase.new()
	
	data = m
	return m

## Saves the current game data to a file.
func save_game(file: String = "save") -> int:
	ResourceSaver.save(data, "user://saves/"+file+".tres")
	print(data)
	return OK

func load_game(file: String = "save") -> int:
	var path ="user://saves/"+file+".tres"
	if not FileAccess.file_exists(path):
		Shell.print_err(
			"Missing Save File",
			"No save file "+file+" at the save directiory.",
			{"suggestions":""}
		); return ERR_FILE_NOT_FOUND
	
	data = load(path)
	
	return OK
	

### Resource Management ###

# Dictionary that contains resource maps for the game, with resources inside.
# The resource maps in this dictionary are called "Resource Banks".

@export_category("Resources")

@export var _resource_banks : ResourceMap

func get_resource(path_string : String):
	var path = path_string.split("/")
	
	print("[Game::DataCore] Loading resource from " + str(path))
	
	return _resource_banks.Nget_resource(path)

func preload_resource(path_string : String):
	var path = path_string.split("/")
	
	print("[Game::DataCore] Preloading resource from " + str(path))
	
	return _resource_banks.Npreload_resource(path)
