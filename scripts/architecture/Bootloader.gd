extends Node

@onready var text = $RichTextLabel

func _ready():
	printx("Booting Star engine...")
	var exe_dir = OS.get_executable_path().get_base_dir()
	var d = DirAccess.open(exe_dir)
	
	var files = d.get_files()
	
	var packs = []
	var core_packs = []
	
	# Load any .pcks in the executable's neighbourhood.
	for file in files:
		if file.get_extension() == "pck":
			ProjectSettings.load_resource_pack(exe_dir + "/" + file, true)
	
	d = DirAccess.open("res://packs")
	
	#printx(get_dir_tree("res://packs", 2))
	#return
	
	printx("Checking out packs.")
	# Checkout all the newly loaded packs!
	for pack in d.get_directories():
		var pd = DirAccess.open("res://packs/"+pack)
		if not pd:
			print(pd.get_open_error())
		
		var gp = load_safe("res://packs/%s/pack.tres" % pack)
		if not gp:
			printx(" - No 'pack.tres' found for '%s'." % pack)
			continue
		
		gp._setup()
		printx(" - Found " + str(gp))
		packs.push_back ({
			"name": pack,
			"priority": gp.priority
		})
		if gp.is_core:
			core_packs.push_back(gp)
			gp._output = text
			gp._tree = get_tree()
			
		await get_tree().process_frame
	
	var pack_to_boot : GamePack
	
	# Select which pack to boot.
	if core_packs.size() == 0:
		printx("No game packs found to boot.")
		return
	if core_packs.size() == 1:
		pack_to_boot = core_packs[0]
	
	printx("Booting into " + str(pack_to_boot) + ".")
	
	await get_tree().process_frame
	pack_to_boot._boot()


func get_dir_tree(path, max_level = -1, level = 0):
	if level == max_level: return ''
	
	var dir : DirAccess = DirAccess.open(path)
	var text = ''
	
	text += "[indent]"
	
	for d in dir.get_directories():
		text += d + '\n'
		text += get_dir_tree(path + '/' + d, max_level, level + 1)
	for f in dir.get_files():
		text +=  f + "\n"
	
	text += "[/indent]"
	
	return text


func printx(message):
	text.text += str(message) + "\n"
	print_rich(message)

func load_safe(path : String):
	if not FileAccess.file_exists(path):
		var np = path + '.remap'
		if not FileAccess.file_exists(np):
			return null
		return load(get_path_of_remap(np))
	
	return load(path)

func get_path_of_remap(path : String):
	var remap = ConfigFile.new()
	var err = remap.load(path)
	if err != OK: return
	return remap.get_value('remap', 'path')

func _input(ev):
	if Input.is_action_just_pressed("ui_fullscreen"):
		var w := get_tree().root
		if w.mode == Window.MODE_FULLSCREEN:
			w.mode = Window.MODE_WINDOWED
		else:
			w.mode = Window.MODE_FULLSCREEN
