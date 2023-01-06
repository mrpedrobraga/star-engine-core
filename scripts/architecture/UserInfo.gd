extends Resource
class_name UserInfo

## Class that stores information about the game.
##
## This class stores modifications, settings, created by the user
## that persist in-between save files.

var version = "0.0.1"
var save_file : String = "save"

func _to_string():
	return "[UserInfo '%s'. Save at 'user://saves/%s.tres'.]" % [version, save_file]
