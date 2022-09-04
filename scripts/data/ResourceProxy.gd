extends Resource
class_name ResourceProxy

@export_file var path : String = ""
@export var resource : Resource:
	set(v):
		resource = v
		loaded = (v == null)
var loaded = false

static func create(_path : String, _resource : Resource = null):
	var r = ResourceProxy.new() 
	r.path = _path
	r.resource = _resource
	
	return r

func get_resource():
	if resource == null:
		load_resource()
	return resource

func preload_resource():
	resource = load(path)

func load_resource():
	resource = load(path)

func _to_string():
	return "[ResourceProxy, %s : %s]" % ['loaded' if loaded else 'unloaded', path]
