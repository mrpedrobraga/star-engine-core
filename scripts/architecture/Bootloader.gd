extends Node
class_name Bootloader

## Loads the game from modules.
##
## Bootloader will look for and import .pck files in the same folder
## and then look for [GamePack]s under [code]res://packs[/code].

@onready var _output_label = $RichTextLabel

func _input(ev):
	if Input.is_action_just_pressed("ui_fullscreen"):
		var w := get_tree().root
		if w.mode == Window.MODE_FULLSCREEN:
			w.mode = Window.MODE_WINDOWED
		else:
			w.mode = Window.MODE_FULLSCREEN

## Check this implementation of _ready to see what happens
## when the game is loaded.
func _ready():
	r_print("Booting Star engine...")
	
	# Gets all the files on the same directory.
	var exe_dir = OS.get_executable_path().get_base_dir()
	var d = DirAccess.open(exe_dir)
	var files = d.get_files()
	
	# Will keep all the GamePacks we find on the loaded game modules.
	var packs = []
	# Will keep all the runnable game modules (packs that aren't asset or data-based).
	var core_packs = []
	
	# Load any .pcks in the executable's neighbourhood.
	r_print("Looking for resource packs to load.")
	for file in files:
		if file.get_extension() == "pck":
			r_print(" - Loading " + file + ".")
			ProjectSettings.load_resource_pack(exe_dir.path_join(file), true)
	
	# Now focus on the packs folder inside the game's file system.
	# It'll contain the packs loaded in the previous step,
	# as well as things bundled with the executable.
	r_print("Checking out loaded packs.")
	d = DirAccess.open("res://packs")
	
	# Look for GamePacks inside each subfolder of res://packs.
	for pack in d.get_directories():
		var pd = DirAccess.open("res://packs/"+pack)
		if not pd:
			print(DirAccess.get_open_error())
		
		# Loads the GamePack, saved as pack.tres
		var game_pack = load_safe("res://packs/%s/pack.tres" % pack)
		
		# If there's no pack.tres, the game pack will be ignored.
		# Its files are still very much loaded.
		if not game_pack:
			#r_print(" - No 'pack.tres' found for '%s'." % pack)
			continue

		r_print(" - Found " + str(game_pack))		
		# Calls _setup on the game pack.
		game_pack._setup()
		packs.push_back ({
			"name": pack,
			"priority": game_pack.priority
		})
		if game_pack.is_core:
			core_packs.push_back(game_pack)
			# Give game_pack references to the output
			# and the tree, so it can interact with the game.
			game_pack._output = _output_label
			game_pack._tree = get_tree()
			
		await get_tree().process_frame
	
	# Sorts the packs in order of priority.
	packs.sort_custom(func (a, b): return a.priority < b.priority)
	core_packs.sort_custom(func (a, b): return a.priority < b.priority)
	
	# The pack the game will boot onto.=
	var pack_to_boot : GamePack
	
	# Select which pack to boot.
	match core_packs.size():
		0:
			r_print("No game packs found to boot.")
			return
		1:
			pack_to_boot = core_packs[0]
		_:
			# TODO: selection for which core pack to boot.
			# This is for two core packs that use the same data,
			# but a different loading mechanism and UI:
			# say, a game and its level editor.
			pack_to_boot = core_packs[0]
	
	r_print("Booting into " + str(pack_to_boot) + ".")
	
	await get_tree().process_frame
	
	# Call boot on the pack to boot.
	# The duty of loading is passed to it.
	pack_to_boot._boot()


## Returns a BBCode-formatted string containing all the files
## in a directory. View with print_rich, or in a RichTextLabel.
func get_dir_tree(path, max_level = -1, level = 0):
	if level == max_level: return ''
	var dir : DirAccess = DirAccess.open(path)
	var t = ''
	t += "[indent]"
	for d in dir.get_directories():
		t += d + '\n'
		t += get_dir_tree(path + '/' + d, max_level, level + 1)
	for f in dir.get_files():
		t +=  f + "\n"
	t += "[/indent]"
	return t

## Prints a message to the standard output, and to the screen.
func r_print(message):
	_output_label.text += str(message) + "\n"
	print_rich(message)

## Loads a path safely, by checking if it has been remapped.
func load_safe(path : String):
	if not FileAccess.file_exists(path):
		var path2 = path + '.remap'
		if not FileAccess.file_exists(path2):
			return null
		return load(get_path_of_remap(path2))
	
	return load(path)

## Gets the path inside a .remap file.
func get_path_of_remap(path : String):
	var remapper = ConfigFile.new()
	var err = remapper.load(path)
	if err != OK: return
	return remapper.get_value('remap', 'path')

