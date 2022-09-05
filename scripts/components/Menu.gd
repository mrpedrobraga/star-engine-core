@tool
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
@export var is_menu_array := false
##The available options to be chosen from.
##If one of the options is a Menu it will open it,
##pass the processing and await it to return.
@export var options : Array = ["First"]
##The currently selected index.
@export var selected_index := 0
##When [code]true[/code], when you get to the minimum/maximum
##of the menu, its index will wrap around.
@export var wrap_selection := true
##If this menu allows cancelling as an answer.
@export var allows_cancel := false

##The path to the parent menu (if this menu is a submenu)
@export var parent: Node
var level = 0

##Emitted when the selection is changed.
signal selection_changed(index)
##Emitted when OK is pressed.
signal ok_pressed(index)
##Emitted when BACK is pressed.
signal back_pressed()
##Emitted when a choice is made -- either something was selected
##or the user canceled.
signal choice_made(type)

enum {CHOICE_OK, CHOICE_BACK}

func _ready():
	set_process(false)

##Chooses the currently selected option and returns.
func choose():
	var m = get_selected()
	if m is NodePath:
		m = get_node(m)
	if m is Menu:
		is_current = false
		m.open(self, level+1)
		await m.choice_made
		choice_made.emit(CHOICE_OK)
		ok_pressed.emit()
		return
	
	var indent = ""; for i in range(level): indent += "\t"
	print(indent, "- ", name, " : ", m)
	
	if parent:
		close()
		choice_made.emit(CHOICE_OK)
		ok_pressed.emit()

##Selects the next option in the option list.
func select_next():
	var cache = selected_index
	selected_index += 1
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
	if wrap_selection:
		selected_index = posmod(selected_index, options.size())
	else:
		selected_index = clamp(selected_index, 0, options.size() - 1)
	if cache != selected_index:
		emit_signal("selection_changed", selected_index)

##Returns the currently selected option.
func get_selected():
	return options[selected_index]

##Opens the menu.
##@param: parent_ If this has a value, the current menu will be opened as a submenu.
func open(parent_=null, level_=0):
	if is_open:
		printerr("CyclicalReferenceWarning", "Cyclical/Redundant Menu Reference is discouraged.")
	is_open = true
	is_current = true
	if parent_:
		parent = parent_
	level = level_
	set_process(true)
	if is_menu_array:
		iterate()

##When [member is_menu_array] is set to true, this function is called to iterate through all its submenus.
func iterate():
	var index = 0
	while index < options.size():
		var m = options[index]
		var indent = ""; for i in range(level): indent += "\t"
		print(indent, "- ", index, " : ", m)
		if m is NodePath:
			m = get_node(m)
		if m is Menu:
			is_current = false
			m.open(self, level+1)
			var status = await m.choice_made
			if status == CHOICE_BACK:
				index -= 2
		index += 1
	close()
	choice_made.emit(CHOICE_OK)

##Closes the menu where it's at and doesn't return.
func close():
	is_open = false
	is_current=false
	set_process(false)

##Closes the menu and returns (if this Menu is a submenu).
func back():
	if parent:
		close()
		parent.is_current = true
		choice_made.emit(CHOICE_BACK)
		back_pressed.emit()
