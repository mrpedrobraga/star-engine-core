extends Usable
class_name Item

## Class that represents a database entry for an item.
## 
## Inventories do not actually carry [Item]s. See [ItemStack] instead.

@export var lose_one_when_used := true
@export var can_be_thrown_away := true

@export var usage_sound : AudioStream
@export var usage_narration : StarScriptSection
