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
	
	printx("Checking out packs.")
	# Checkout all the newly loaded packs!
	for pack in d.get_directories():
		var pd = DirAccess.open("res://packs/"+pack)
		if not pd.file_exists('pack.tres'):
			continue
		var gp : GamePack = load("res://packs/%s/pack.tres" % pack)
		gp._setup()
		printx("\t - found " + str(gp))
		packs.push_back ({
			"name": pack,
			"priority": gp.priority
		})
		if gp.is_core:
			core_packs.push_back(gp)
	
	var pack_to_boot : GamePack
	
	# Select which pack to boot.
	if core_packs.size() == 0:
		printx("No game packs found to boot.")
		return
	if core_packs.size() == 1:
		pack_to_boot = core_packs[0]
	
	printx("Booting into " + str(pack_to_boot) + ".")
	pack_to_boot._boot()



func printx(message):
	text.text += str(message) + "\n"
	print_rich(message)



func _input(ev):
	if Input.is_action_just_pressed("ui_fullscreen"):
		var w := get_tree().root
		if w.mode == Window.MODE_FULLSCREEN:
			w.mode = Window.MODE_WINDOWED
		else:
			w.mode = Window.MODE_FULLSCREEN
