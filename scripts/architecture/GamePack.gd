extends Resource
class_name GamePack

## Abstract class that holds details about a game module.
##
## Instead of distributing your game in one big folder,
## you might use modules. Modules allow you to isolate state,
## assets, and distribute your game through more than one file.[br][br]
## 
## This can also be a good way of adding community-served mods
## without ever releasing source code. Check [Bootloader] to see how it works.[br][br]
##
## Do not use this class directly to create your [code]pack.tres[/code],
## instead, extend this script and implement [method _boot].

@export_category("Game Pack")
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
## The version of this pack, for versioning reasons.
@export var version = "0.0.0"

@export_category("Game Setup")
@export var setup_save_data : GameSaveData

var _output : RichTextLabel

## Prints out a method to the standard output.
func printx(message):
	message = "[%s] "%bundle_id + message
	_output.text += str(message) + "\n"
	print_rich(message)

## A reference to the tree, so it can change rooms.
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
