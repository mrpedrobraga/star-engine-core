extends Resource
class_name GamePack

@export_category("GamePack")
## The bundle id of this pack.
@export var bundle_id = "unnamed_pack"
@export var name = "Unnamed Pack"
## Whether this is a core pack, or a subpack.
##
## Core packs appear on the bootloader so you can choose
## from one of them.
@export var is_core = true
## The priority with which this pack will be loaded.
## Smaller number means load first!
@export var priority = 0
@export var version = "0.0.0"

var _output : RichTextLabel
func printx(message):
	message = "[%s] "%bundle_id + message
	_output.text += str(message) + "\n"
	print_rich(message)
@warning_ignore("unused_variable")
var _tree : SceneTree

## Prepare whatever when this pack is loaded into the engine.
func _setup():
	pass

## Boots into this pack (if it's a core pack!) and loads the game.
func _boot():
	pass

func _to_string():
	return "['%s' for '%s'%s version %s]" % [name, bundle_id, " (core)" if is_core else "", version]
