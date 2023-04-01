@tool
@icon("res://_engine/scripts/icons/icon_component_menu.png")
extends Component
class_name Menu

##Class for creating complex menus in code or in a tree.
##
##This class handles the internal workings of menus as well as submenus.

##If the menu is open (currently being interacted with OR waiting for a submenu to return).
@export var is_open := false
##If the menu is currently being interacted with.
@export var is_current := false
##When [code]false[/code], the menu presents a set of options to be chosen from.[br/]
##When [code]true[/code], the menu plays a set of submenus in order
##(allowing the user to change their mind and come back to previous
##submenus.
@export var is_iterator := false
##The available options to be chosen from.
##If one of the options is a Menu it will open it,
##pass the processing and await it to return.
@export var options : Array = ["First"]
@export var labels : Array[String] = []
@export var options_validity : Array[bool] = []
##The currently selected index.
@export var selected_index := 0
var _safe_selected_index : int:
	get:
		return posmod(selected_index, options.size())
##When [code]true[/code], when you get to the minimum/maximum
##of the menu, its index will either wrap around or be clamped.
@export var bind_selection := true
##When [code]true[/code], when you get to the minimum/maximum
##of the menu, its index will wrap around.
@export var wrap_selection := true
##If this menu allows cancelling as an answer.
@export var allows_cancel := false

##The path to the parent menu (if this menu is a submenu)
@export var parent: Node
var _level = 0

@export_group("Procedural")

## A menu can be marked to only generate its contents
## after it has been opened.[br][br]
##
## This is so in an iterator menu, previous choices
## can interfere on others.
@export var populate_on_open : bool = false
## The function used to populate the menu.
@export var populate_function : Callable

## The current [MenuHandler] handling this Menu.
@export var menu_handler : Node

##Emitted when the menu is opened
signal opened
##Emitted when the menu becomes current
signal became_current
##Emitted when the selection is changed.
signal selection_changed(index)
##Emitted when OK is pressed.
signal ok_pressed(index)
##Emitted when BACK is pressed.
signal back_pressed()
##Emitted when a choice is made -- either something was selected
##or the user canceled.
signal choice_made(type)
var _last_choice_type := CHOICE_OK

enum {CHOICE_OK, CHOICE_BACK}

func _ready():
	set_process(false)

##Selects the next option in the option list.
func select_next():
	var cache = selected_index
	selected_index += 1
	if bind_selection:
		if wrap_selection:
			selected_index = posmod(selected_index, options.size())
		else:
			selected_index = clamp(selected_index, 0, options.size() - 1)
	if cache != selected_index:
		emit_signal("selection_changed", selected_index)

##Selects the next option in the option list.
func select_previous():
	var cache = selected_index
	selected_index -= 1
	if bind_selection:
		if wrap_selection:
			selected_index = posmod(selected_index, options.size())
		else:
			selected_index = clamp(selected_index, 0, options.size() - 1)
	if cache != selected_index:
		emit_signal("selection_changed", selected_index)

##Returns the currently selected option.
func get_selected():
	return options[_safe_selected_index]

##Gets the text associated with the currently selected option.
func get_selected_label():
	if labels:
		if labels.size() >= options.size():
			return labels[_safe_selected_index]
	return str(get_selected())

## Returns whether the selected option is valid.
func is_option_valid(index : int):
	if options_validity:
		return options_validity[index]
	return true

##Opens the menu.
##@param: parent_ If this has a value, the current menu will be opened as a submenu.
func open(parent_=null, _level_=0):
	#if is_open:
	#	printerr("CyclicalReferenceWarning", "Cyclical/Redundant Menu Reference is discouraged.")
	is_open = true
	is_current = true
	became_current.emit()
	
	if populate_on_open:
		populate_function.call(self)
	if menu_handler:
		menu_handler.set_handling(self)
	
	opened.emit()
	if parent_:
		parent = parent_
	_level = _level_
	set_process(true)
	
	if is_iterator:
		iterate()
	
	if menu_handler:
		menu_handler.update()

##When [member is_iterator] is set to true, this function is called to iterate through all its submenus.
func iterate():
	var index = 0
	var indent = ""; for i in range(_level): indent += "\t"
	
	while index < options.size():
		var m = options[index]
#		print(indent, "- ", index, " : ", labels[index])
		if m is NodePath:
			m = get_node(m)
		if m is Menu:
			is_current = false
			m.open(self, _level+1)
			var s = await m.choice_made
			if m._last_choice_type == CHOICE_BACK:
				if index > 0:
					index -= 1
			else:
				index += 1
#	print(indent, 'Iterator Menu closed')
	is_current = true
	became_current.emit()
	_last_choice_type = CHOICE_OK
	choice_made.emit(CHOICE_OK)
	close()

##Closes the menu where it's at and doesn't return.
func close():
	is_open = false
	is_current = false
	set_process(false)
	
	if menu_handler:
		menu_handler.update()

##Closes the menu and returns (if this Menu is a submenu).
func back():
	var indent = ""; for i in range(_level): indent += "\t"
	
	if not allows_cancel:
		return
	if parent:
		close()
		_last_choice_type = CHOICE_BACK
#		print(indent, "<-")
		choice_made.emit(CHOICE_BACK)
		back_pressed.emit()
		parent.is_current = true
		parent.became_current.emit()
		if menu_handler:
			menu_handler.set_unhandling(self)

##Chooses the currently selected option and returns.
func choose():
	var m = get_selected()
	
	var indent = ""; for i in range(_level): indent += "\t"
#	print(indent, "- ", name, " : ", get_selected_label())
	
	if not is_option_valid(_safe_selected_index):
		# [DEBUG]
		print("[Menu] Invalid Option.")
		return
	
	if m is NodePath:
		m = get_node(m)
	if m is Menu:
		is_current = false
		m.open(self, _level+1)
		await m.choice_made
		match m._last_choice_type:
			CHOICE_OK:
				_last_choice_type = CHOICE_OK
				choice_made.emit(CHOICE_OK)
				ok_pressed.emit()
				return
			CHOICE_BACK:
				_last_choice_type = CHOICE_BACK
				choice_made.emit(CHOICE_BACK)
				back_pressed.emit()
				return
	
	if parent:
		close()
		_last_choice_type = CHOICE_OK
		choice_made.emit(CHOICE_OK)
		ok_pressed.emit()

## Returns the dictionary representation of this menu's tree.
func get_dict_repr() -> Dictionary:
	var r
	
	if is_iterator:
		r = {
			"is_iterator": true,
			"sub": []
		}
		for m in options:
			var mm = m
			if mm is Menu:
				mm = mm.get_dict_repr()
			r.sub.push_back(mm)
	else:
		r = {
			"is_iterator": false,
			"index": selected_index,
			"label": get_selected_label()
		}
		var m = get_selected()
		if m is Menu:
			r.sub = m.get_dict_repr()
		else:
			r.value = m
	
	return r

## Creates a new menu easily, by passing only options,
## or optionally some extra data.
static func create(
	_options : Array,
	_labels : Array = [],
	_allows_cancel = false,
	_menu_handler : Node = null
) -> Menu:
	var m = Menu.new()
	
	m.options = _options
	m.options_validity.assign([])
	m.options_validity.resize(m.options.size())
	m.options_validity.fill(true)
	m.labels.assign(_labels)
	m.allows_cancel = _allows_cancel
	if _menu_handler:
		m.menu_handler = _menu_handler
		_menu_handler.menu = m
	
	return m
