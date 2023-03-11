@tool
extends Resource
class_name CharacterStats

##Resource that stores the stats for a Character.
##
##This is an abstract class, implement your own character stats by
##extending this class.

## Emitted when a stat is altered through
## a [StatAlteration] resource.
signal stat_altered(stat, amt, type)

## All the status effects applied to this character
@export var status_effects : Array[StatusEffect]

## Applies an alteration to a stat.
## It also emits [signal stat_altered] in case
## you'd like to do some animations.
func _apply_alteration(s : CharacterStatsAlteration):
	
	## IMPLEMENT!
	
	stat_altered.emit(s.stat, s.amt, s.type)

## Applies a status effect.
func _apply_status_effect(stfx : StatusEffect):
	status_effects.push_back(stfx)
	stfx.should_be_removed.connect(_remove_status_effect.bind(stfx))

## Removes a status effect;
## This function is also called automatically by the status
## effect when it feels like vanishing.
func _remove_status_effect(stfx : StatusEffect):
	status_effects.erase(stfx)
