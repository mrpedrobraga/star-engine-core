extends Control
class_name _MenuHandlerBase

@export_category("MenuHandler")
@export var menu : Node
var menu_is_current := false
var menu_was_current_last_frame := false

func set_handling(m : Menu):
	if menu:
		if menu.became_current.is_connected(update):
			menu.became_current.disconnect(update)
	menu = m
	menu.became_current.connect(update)
	update()

func set_unhandling(m : Menu):
	if menu:
		if m == menu:
			if menu.became_current.is_connected(update):
				menu.became_current.disconnect(update)

func _ready():
	if menu:
		update()


func _input(ev):
	if not menu:
		return
	if not menu_was_current_last_frame or not menu.is_open:
		return
	if menu.is_iterator:
		return
	
	if Input.is_action_just_pressed("ui_right"):
		menu.select_next()
		update()
	if Input.is_action_just_pressed("ui_left"):
		menu.select_previous()
		update()
	if Input.is_action_just_pressed("OK"):
		menu.choose()
		menu_is_current = false
		menu_was_current_last_frame = false
	if Input.is_action_just_pressed("CANCEL"):
		menu.back()
		if menu.parent:
			menu_is_current = false
			menu_was_current_last_frame = false

func update():
	menu_is_current = true
	Shell.speak(menu.get_selected_label())
	await get_tree().process_frame
	menu_was_current_last_frame = true
