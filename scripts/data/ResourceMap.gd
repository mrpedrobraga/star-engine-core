extends Resource
class_name ResourceMap

signal resource_loaded(name)

@export var _data := {}

# TODO : Change instances of load() with a threaded, slow, but non-blocking ResourceLoader.

func add_entry(name : String, path : String) -> void:
	_data[name] = ResourceProxy.create(path)

func remove_entry(name : String) -> void:
	if not _data.has(name): return
	_data.erase(name)

func new_dir(name : String) -> ResourceMap:
	var d = ResourceMap.new()
	_data[name] = d
	return d

func install_dir(name : String, rmap : ResourceMap) -> bool:
	_data[name] = rmap
	return true

func remove_dir(name : String) -> void:
	if not _data.has(name): return
	_data.erase(name)

func clear_entries() -> void:
	_data.clear()

func get_available_resources() -> Array[String]:
	return _data.keys()

func is_resource_loaded(name : String) -> bool:
	if not _data.has(name): return false
	return _data[name].loaded

func get_resource(name : String) -> Resource:
	# If there is no entry with the name, return null.
	if not _data.has(name): return null
	# If it is already loaded, simply return it.
	if _data[name].loaded:
		return _data[name].resource
	# If not, load and then retrieve it.
	return load(_data[name].path)

## Gets a resource from the resource map tree.
## Accepts nested paths (an array path).
func Nget_resource(name : PackedStringArray):
	# If there is no entry with the name, return null.
	if not _data.has(name[0]): return ERR_DOES_NOT_EXIST

	# If it is already loaded, simply return it.
	var sub = _data[name[0]]
	
	# If the return value is a resource map, continue Ngetting from it.
	if sub is ResourceMap:
		name.remove_at(0)
		return sub.Nget_resource(name)
	if sub is ResourceProxy:
		return sub.get_resource()
	
	# If not, return the resource.
	return sub

func preload_batch(names : Array[String]) -> void:
	for name in names : load_resource(name)

func preload_resource(name : String) -> void:
	if not _data.has(name): return
	
	if not _data[name].loaded:
		load_resource(name)

func Npreload_resource(name : PackedStringArray) -> void:
	var sub
	
	if not _data.has(name[0]): return
	
	if not _data[name[0]].loaded:
		if name.size() > 1:
			load_resource(name[0])
			name.remove_at(0)
			_data[name[0]].Npreload_resource(name)
		else:
			preload_resource(name[0])

func load_resource(name):
	_data[name].load_resource()
	resource_loaded.emit(name)

func _to_string():
	var s := ""
	for k in _data.keys():
		var v = _data[k]
		s += str(k) + ":\t\t" + str(v)
	return s

func get_formated_description() -> String:
	var s := ""
	
	var keys = _data.keys()
	keys.sort_custom(
		func(a, b):
			var nameorder = a.naturalnocasecmp_to(b) < 0
			var typeorder = (_data[a] is ResourceMap) and not (_data[b] is ResourceMap)
			return typeorder# or nameorder
	)
	
	for k in keys:
		var v = _data[k]
		s += "\"%s\":\n[indent]%s[/indent]\n---\n" % [str(k), v.get_formated_description()]
	
	return s
