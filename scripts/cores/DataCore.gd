extends __GameplayCoreBase
class_name DataCore
@icon("res://core/scripts/icons/icon_event_pathway.svg")

### Game SAVE and LOAD ###

signal on_saved(file)
signal on_loaded(file)

var data : GameSaveData = GameSaveData.new()

func save_game(file: String) -> int:
	ResourceSaver.save(data, "res://"+file+".tres")
	print(data)
	return OK

func load_game(file: String) -> int:
	var path ="res://"+file+".tres"
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

@export var _resource_banks : Dictionary = {
	# Music.
	"MUS": null,
	# Sound effects.
	"SFX": null,
	# Visual effects.
	"VFX": null,
	# Sprites.
	"SPR": null,
	# Scenes / Rooms.
	"SCN": null,
	# Dialogues / Cutscenes.
	"DCS": null,
	# Items.
	"ITM": null,
	# Attacks.
	"ATK": null,
	# Skills.
	"SKL": null,
	# Opponent attacks.
	"OATK": null,
	# Battle Scripts.
	"BTS": null,
}

func get_resource(path_string : String):
	var path = path_string.split("/")
	
	print("[Game::DataCore] Loading resource from " + str(path))
	
	if not path[0] in _resource_banks:
		return ERR_DOES_NOT_EXIST
	
	var bank = _resource_banks[path[0]]
	path.remove_at(0)
	return bank.Nget_resource(path)

func preload_resource(path_string : String):
	var path = path_string.split("/")
	
	print("[Game::DataCore] Preloading resource from " + str(path))
	
	if not path[0] in _resource_banks:
		return ERR_DOES_NOT_EXIST
	
	var bank = _resource_banks[path[0]]
	path.remove_at(0)
	return bank.Npreload_resource(path)
