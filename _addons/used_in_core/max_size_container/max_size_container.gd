@tool
extends MarginContainer

# Enums
enum {LEFT, RIGHT, TOP, BOTTOM}
enum VERTICAL_ALIGN {TOP, CENTER, BOTTOM}
enum HORIZONTAL_ALIGN {LEFT, CENTER, RIGHT}

#var size = self.size:
#	set(v):
#		size = v
#		size = v
#	get:
#		return size

# Parameters
@export var max_size := Vector2(-1, -1):
	set(value):
		if value.x < 0:
			value.x = -1
		if value.y < 0:
			value.y = -1

		max_size = value

		#if is_initialized:
		#	_check_if_valid()
		#	_adapt_margins()
@export var valign: VERTICAL_ALIGN = VERTICAL_ALIGN.CENTER:
	set(value):
		valign = value

		#if is_initialized:
		#	_adapt_margins()
@export var halign: HORIZONTAL_ALIGN = HORIZONTAL_ALIGN.CENTER:
	set(value):
		halign = value

		#if is_initialized:
		#	_adapt_margins()

# child node of the container
var child : Node

# Intern var
var minimum_child_size : Vector2
var is_size_valid := {"x": false, "y": false}
var is_initialized := false

#
#func _ready() -> void:
#	return
#	# Reset custom margins if modified from the editor
#	_set_custom_margins(LEFT, 0)
#	_set_custom_margins(RIGHT, 0)
#	_set_custom_margins(TOP, 0)
#	_set_custom_margins(BOTTOM, 0)
#
#	# Sets up the Container
#	#resized.connect(_on_self_resized)
#
#	if get_child_count() > 0:
#		_initialize(get_child(0))
#
#
#func _initialize(p_child: Node) -> void:
#	# Sets the child node
#	child = p_child
#	minimum_child_size = child.get_combined_minimum_size()
#	child.connect(&"tree_exiting", _on_child_tree_exiting)
#	child.connect(&"minimum_size_changed", _on_child_minimum_size_changed)
#	if not child.tree_entered.is_connected(self._on_child_tree_entered):
#		child.connect(&"tree_entered", _on_child_tree_entered)
#
#	_check_if_valid()
#	_adapt_margins()
#
#	# Tells other parts that the child node is ready
#	# important to avoid early calculations that give wrong minimum child size
#	is_initialized = true
#
#
#func add_child(node : Node, legible_unique_name := false, position=0) -> void:
#	# Overloading add_child() to detect when a child node comes
#	super.add_child(node, legible_unique_name)
#
#	if get_child_count() == 1:
#		_initialize(node)
#	else:
#		push_warning(str("MaxSizeContainer can handle only one child. ", node.name,
#				" will be ignored, because ", child.name, " is the first child."))
#
#

func _check_if_valid() -> void:
	# This function checks if the child is smaller than max_size.
	# Otherwise there would be a risk of infinite margins
	if child == null:
		return

	if max_size.x < 0:
		is_size_valid.x = false
	elif minimum_child_size.x > max_size.x:
		is_size_valid.x = false
		push_warning(str("max_size ( ", max_size, " ) ignored on x axis: too small.",
				"The minimum possible size is: ", minimum_child_size))
	else:
		is_size_valid.x = true

	if max_size.y < 0:
		is_size_valid.y = false
	elif minimum_child_size.y > max_size.y:
		is_size_valid.y = false
		push_warning(str("max_size ( ", max_size, " ) ignored on y axis: too small.",
				"The minimum possible size is: ", minimum_child_size))
	else:
		is_size_valid.y = true


func _adapt_margins() -> void:
	# Adapats the margin to keep the child size below max_size

	# If the container size is smaller than the max size, no margins are necessary
	if size.x < max_size.x:
		_set_custom_margins(LEFT, 0)
		_set_custom_margins(RIGHT, 0)
	if size.y < max_size.y:
		_set_custom_margins(TOP, 0)
		_set_custom_margins(BOTTOM, 0)

	### x ###
	# If the max_size is smaller than the child's size: ignore it
	if not is_size_valid.x:
		_set_custom_margins(LEFT, 0)
		_set_custom_margins(RIGHT, 0)

	# Else, adds margins to keep the child's size below the max_size
	elif size.x >= max_size.x:
		var new_margin_left : int
		var new_margin_right : int

		match halign:
			HORIZONTAL_ALIGN.LEFT:
				new_margin_left = 0
				new_margin_right = size.x - max_size.x
			HORIZONTAL_ALIGN.CENTER:
				new_margin_left = (size.x - max_size.x) / 2
				new_margin_right = (size.x - max_size.x) / 2
			HORIZONTAL_ALIGN.RIGHT:
				new_margin_left = size.x - max_size.x
				new_margin_right = 0

		_set_custom_margins(LEFT, new_margin_left)
		_set_custom_margins(RIGHT, new_margin_right)

	### y ###
	# If the max_size is smaller than the child's size: ignore it
	if not is_size_valid.y:
		_set_custom_margins(TOP, 0)
		_set_custom_margins(BOTTOM, 0)

	# Else, adds margins to keep the child's size below the max_size
	elif size.y >= max_size.y:
		var new_margin_top : int
		var new_margin_bottom : int

		match valign:
			VERTICAL_ALIGN.TOP:
				new_margin_top = 0
				new_margin_bottom = size.y - max_size.y
			VERTICAL_ALIGN.CENTER:
				new_margin_top = (size.y - max_size.y) / 2
				new_margin_bottom = (size.y - max_size.y) / 2
			VERTICAL_ALIGN.BOTTOM:
				new_margin_top = size.y - max_size.y
				new_margin_bottom = 0

		_set_custom_margins(TOP, new_margin_top)
		_set_custom_margins(BOTTOM, new_margin_bottom)


func _set_custom_margins(side : int, value : int) -> void:
# This function makes custom constants modifications easier
	match side:
		LEFT:
			set("custom_constants/margin_left", value)
		RIGHT:
			set("custom_constants/margin_right", value)
		TOP:
			set("custom_constants/margin_top", value)
		BOTTOM:
			set("custom_constants/margin_bottom", value)


#func _get_configuration_warning() -> String:
#	# Warns the user that only 1 child node is possible
#	var warning := ""
#
#	if get_child_count() > 1:
#		warning = "This Container can handle only one (1) child"
#
#	return warning

#func _on_self_resized() -> void:
#	# To avoid errors in tool mode and setup, the container must be fully ready
#	if is_initialized:
#		_adapt_margins()
#
#
#func _on_child_tree_entered() -> void:
#	_initialize(child)
#
#
#func _on_child_tree_exiting() -> void:
#	# Stops margin calculations
#	is_initialized = false
#
#	# Disconnect signals
#	child.disconnect(&"tree_exiting", self._on_child_tree_exiting)
#	child.disconnect(&"minimum_size_changed", self._on_child_minimum_size_changed)
#
#	# Reset custom margins
#	_set_custom_margins(LEFT, 0)
#	_set_custom_margins(RIGHT, 0)
#	_set_custom_margins(TOP, 0)
#	_set_custom_margins(BOTTOM, 0)
#
#
#func _on_child_minimum_size_changed() -> void:
#	minimum_child_size = child.get_combined_minimum_size()
#	_check_if_valid()
#
#
