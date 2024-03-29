extends Resource
class_name ResourceProxy

## Class that allows keeping a reference to a resource without loading it.

@export_file var path : String = ""
@export_group("Runtime")
@export var resource : Resource:
	set(v):
		resource = v
var loaded = false

static func create(_path : String, _resource : Resource = null) -> ResourceProxy:
	var r = ResourceProxy.new() 
	r.path = _path
	r.resource = _resource
	
	return r

func get_resource():
	if resource == null:
		load_resource()
	return resource

func preload_resource():
	# TODO: Make this load it in steps instead of at once.
	resource = load(path)
	loaded = true

func load_resource():
	resource = load(path)
	loaded = true

func _to_string():
	return "[ResourceProxy, %s : %s]" % ['loaded' if loaded else 'unloaded', path.get_file()]

func get_formated_description():
	var s := ""
	var color = "#33ff33" if loaded else "#ff5555"
	
	s = "[color=%s]%s[/color]" % [color, path.get_file()]
	
	return s
