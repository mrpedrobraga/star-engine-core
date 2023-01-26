extends Resource
class_name StatAlteration

## Class that holds an alteration to a stat,
## such as damage, healing, buff and whatnots.

@export var stat : StringName = &"HP"
@export var amt : int = 0
@export var type : Type = Type.INCREASE

enum Type {
	INCREASE, DECREASE
}

## Applies this stat alteration to a character's stats.
func apply(stats : CharacterStats):
	stats._apply_alteration(self)
