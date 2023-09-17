extends Resource
class_name UserInfo

## Class that stores information about the game.
##
## This class stores modifications, settings, created by the user
## that persist in-between save files.

## The last version of the game that was booted.
var version = "0.0.1"

## The last booted save file.
var save_file : String = "save"

# String representation of this object.
func _to_string():
	return "[UserInfo '%s'. Save at 'user://saves/%s.tres'.]" % [version, save_file]
