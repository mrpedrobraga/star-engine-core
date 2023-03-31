extends Resource
class_name Inventory

## Class that holds [ItemStack]s.
##
## TODO: Implement it.

@export var items : Array[ItemStack]
var size := 18

func _to_string():
	var result = ""
	for i in items:
		result += "-" + i.resource_name
		result += "\n"
	return result
