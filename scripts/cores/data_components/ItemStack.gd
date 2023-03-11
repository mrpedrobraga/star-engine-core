@tool
extends Resource
class_name ItemStack

## Class that represents a group of items.
##
## It's used internally by Inventory to group like item entries.

@export var item : Item:
	set(v):
		item = v
		emit_changed()
@export_range(1, 1024) var amount : int = 1:
	set(v):
		amount = v
		emit_changed()
@export var metadata : Dictionary = {}:
	set(v):
		metadata = v
		emit_changed()

## The maximum [member amount] of items in an [ItemStack].
var stack_limit = 16

## Uses the item stored in [param item].
##
## If [code]item.lose_one_when_use[/code] is true,
## this stack will lose 1 item.
func use(character):
	item._use(character)
	if item.lose_one_when_used:
		amount -= 1
		delete_if_empty()

func delete_if_empty():
	if amount == 0:
		free()

## Checks if the contents in this [ItemStack] can be
## accumulated onto [param other].
func can_merge(other : ItemStack, amt_limit : int = stack_limit):
	return (
		can_partially_merge(other, amt_limit) and
		amount + other.amount <= stack_limit
	)

## Passes the contents of this ItemStack onto [param other]
## and deletes itself.
func merge(other : ItemStack, amt_limit : int = stack_limit):
	if can_merge(other):
		other.amount += amount
		amount = 0
		delete_if_empty()

## Checks if the contents in this [ItemStack] can be
## partially merged onto [param other].
func can_partially_merge(other : ItemStack, amt_limit : int = stack_limit):
	return (
		item == other.item and
		metadata == other.metadata
	)

## Partially merges the contents of this [ItemStack]
## onto [param other].[br]
## That is, [param other] will have the full [param amt_limit]
## and this [ItemStack] will have the leftover amount.
func partially_merge(other : ItemStack, amt_limit : int = stack_limit):
	if can_merge(other):
		var total = amount + other.amount
		other.amount = amt_limit
		amount = total - amt_limit
