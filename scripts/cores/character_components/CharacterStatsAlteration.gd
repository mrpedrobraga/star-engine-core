@tool
extends Resource
class_name CharacterStatsAlteration
## Class for an Inner Voices Status Alteration,
## either stats or status effects

## The tags of the status alteration,
## used for special statuses a character might have.
#
## For example, a character might be specifically
## weak against physical attacks but strong against
## magical attacks.
@export var tags := [&"physical"]

@export_group("StatusEffect")

@export var status_effect : StatusEffect

@export_group("Stats")
## The stat to alter
@export var stat : StringName = &"HP"

@export_enum("Add", "Set") var alteration_mode := 0

## By how much the stat should be
## altered.
var alteration_expression : String = "1"


func _init(stat_:StringName = &"HP", alteration_expression_:String = "1", tags_:Array[StringName]=[&"physical"]):
	stat = stat_
	alteration_expression = alteration_expression_
	tags = tags_

## Applies this stat alteration to a character's stats.
func apply(stats : CharacterStats):
	stats._apply_alteration(self)

###
func _get_property_list():
	var props := []
	
	print('property')
	props.append({
		"name": "alteration_expression",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_EXPRESSION
	})
	
	return props

func _set(prop, value):
	match prop:
		"alteration_expression":
			alteration_expression = value

func _get(prop):
	match prop:
		"alteration_expression":
			return alteration_expression
