extends Node
class_name Screenshot, "res://core/scripts/icons/icon_console.svg"

# Screenshots without hiccups using threads.
# Attach the script to a Node, start your game and hit F11
# 
# Tested in Godot 3.2 beta 5, Linux
# By Filip Lundby, https://twitter.com/skooterkurt

var _root_directory = "user://"
var _screenshot_directory = "screenshots"
var _capture_tasks = []

@export var screenshot_action: String = "misc_screenshot"

func _ready():
	# Create directory
	var screenshot_directory = "%s/%s" % [_root_directory, _screenshot_directory]
	Directory.new().make_dir(screenshot_directory)

func _input(event):
	if Input.is_action_just_pressed(screenshot_action):
		_capture()
		print("Screenshot!")

func _capture():
	# Start thread for capturing images
	var task = Thread.new()
	task.start(_capture_thread)
	_capture_tasks.append(task)

func _capture_thread():
	# Capture the screenshot
	var size = get_tree().root.size
	var image = get_viewport().get_texture().get_data()
	
	# Setup path and screenshot filename
	var date = Time.get_date_dict_from_system()
	var path = "user://screenshots"
	var file_name = "screenshot-%d-%02d-%02dT%02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
	var dir = Directory.new()
	if not dir.dir_exists(path):
		dir.make_dir(path)
	# Find a filename that isn't taken
	var n = 1
	var file_path = path.plus_file(file_name) + ".png"
	while(true):
		if dir.file_exists(file_path):
			file_path = path.plus_file(file_name) + "-" + str(n) + ".png"
			n = n + 1
		else:
			break
	# Save the screenshot
	image.flip_y()
	image.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
	image.save_png(file_path)
	print(file_path)

func _exit_tree():
	for task in _capture_tasks:
		task.wait_to_finish()
