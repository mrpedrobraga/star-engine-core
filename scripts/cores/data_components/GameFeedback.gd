extends Resource
class_name GameFeedback

@export_category("General Info")
@export var username := "Unknown"
@export var room := ""

@export_category("Computer Info")
@export var os := ""
@export var os_version := ""
@export var processor_name : String
@export var processor_count : int
@export var video_adapter_info : PackedStringArray

@export_category("Local Info")
@export var locale : String
@export var locale_language : String
@export var tts_voices : PackedStringArray

@export_category("Performance")
@export var memory_usage : String
@export var FPS_stack : PackedInt32Array = []

func get_average_FPS():
	if FPS_stack.is_empty(): return 60
	
	var f := 0
	for i in FPS_stack: f+=i
	@warning_ignore("integer_division")
	return f / FPS_stack.size()

func gather_data():
	os = OS.get_distribution_name()
	os_version = OS.get_version()
	username = OS.get_environment("USERNAME")
	if Game.current_room:
		room = Game.current_room.room_name
	
	processor_name = OS.get_processor_name()
	processor_count = OS.get_processor_count()
	video_adapter_info = OS.get_video_adapter_driver_info()
	
	memory_usage = str(float(OS.get_static_memory_usage())/1000000.0) + " Megabytes."
	locale = OS.get_locale()
	locale_language = OS.get_locale_language()
	
	if not tts_voices.is_empty():
		DisplayServer.tts_speak("Gathering Data.", tts_voices[0])
	tts_voices = DisplayServer.tts_get_voices_for_language(locale_language)

func export():
	var path := OS.get_executable_path().get_base_dir()
	#path = "res://feedback"
	path +=("/feedback_%s.tres" % Time.get_datetime_string_from_system())
	
	OS.alert("At %s."%path,"Exporting Feedback data.")
	ResourceSaver.save(self, path)
