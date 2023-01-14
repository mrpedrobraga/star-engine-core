extends ScrollContainer
class_name RuntimeInspector

## Class to edit arbitrary node properties in run time.

var _container := GridContainer.new()

## The colour of section titles.
@export var accent_color : Color = Color.CHARTREUSE

func _init():
	follow_focus = true
	
	add_child(_container)
#	_container.anchor_left = 0.0
#	_container.anchor_top = 0.0 
#	_container.anchor_bottom = 1.0
#	_container.anchor_right = 1.0
	_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_container.size_flags_vertical = SIZE_EXPAND_FILL
	
	_container.columns = 2
	
	mouse_entered.connect(update)

var _editors : Array[LineEdit] = []

## Creates a separator with a coloured title to distinguish between sections of properties.
func register_category(text : String):
	var separator = Label.new()
	separator.text = text
	separator.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	separator.custom_minimum_size.y = 64
	separator.modulate = accent_color
	
	_container.add_child(separator)
	_container.add_child(Control.new())

## Registers a property to be edited.
func register_property(node : Node, property : StringName, type : StringName, display_as : String = str(property)):
	
	var label = Label.new()
	label.text = str(display_as)
	label.custom_minimum_size.x = 64
	
	var editor = LineEdit.new()
	editor.text = var_to_str(node.get(property))
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.caret_blink = true
	
	editor.set_meta(&"edited_node", node)
	editor.set_meta(&"edited_property", property)
	editor.set_meta(&"edited_property_type", type)
	
	editor.text_submitted.connect(
		func(text):
			_value_changed(editor, text, node, property, type)
	)
	
	_editors.push_back(editor)
	
	_container.add_child(label)
	_container.add_child(editor)

## Updates the values.
func update():
	for editor in _editors:
		var node = editor.get_meta(&"edited_node")
		var prop = editor.get_meta(&"edited_property")
		
		editor.text = var_to_str(node.get(prop))

func _value_changed(editor : LineEdit, new_value : String, node : Node, property : StringName, type : StringName):
	var value = _parse_var_str(new_value, node)
	
	if not value == null:
		node.set(property, value)
	editor.text = var_to_str(node.get(property))

func _parse_var_str(str : String, node : Node) -> Variant:
	var expr = Expression.new()
	if expr.parse(str) != OK: return null
	
	return expr.execute([], node, true)
