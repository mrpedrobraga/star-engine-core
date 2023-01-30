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

## Applies an alteration to a stat.
## It also emits [signal stat_altered] in case
## you'd like to do some animations.
func _apply_alteration(s : StatAlteration):
	match s.type:
		StatAlteration.Type.INCREASE:
			set(s.stat, get(s.stat) + s.amt)
		StatAlteration.Type.DECREASE:
			set(s.stat, get(s.stat) - s.amt)
	stat_altered.emit(s.stat, s.amt, s.type)
