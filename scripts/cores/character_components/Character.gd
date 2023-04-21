extends Resource
class_name Character

##Resource that encapsulates a character.
##
##This class is used by just about every core,
##it represents a Character as well as some handy
##references it might have.
##
##In order to create a custom character for yourself,
##extend this script.

@export_category("Info")
##The character's display name.
@export var name = "Unknown"
##A reference to the character's stats ([CharacterStats]). 
@export var stats : CharacterStats
##A reference to the node associated with this character.
@export var world_node : Node2D

@export_category("Battle")
##A battler script for when this character engages in battle.
@export var battler_script : Script
var battler_object : BattlerScript

enum Direction {
	NORTH, NORTHEAST, EAST, SOUTHEAST,
	SOUTH, SOUTHWEST, WEST, NORTHWEST
}

func _to_string():
	return "[Character: "+str(name)+"]"
