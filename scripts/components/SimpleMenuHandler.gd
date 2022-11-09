extends RichTextLabel

@export var menu : Node
var menu_is_current := false
var menu_was_current_last_frame := false

const highlight_color := Color(0.7761344909668, 1, 0.34240281581879)

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
		modulate = Color.WHITE

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
		modulate = Color.WHITE
		menu_is_current = false
		menu_was_current_last_frame = false
	if Input.is_action_just_pressed("CANCEL"):
		menu.back()
		if menu.parent:
			menu_is_current = false
			menu_was_current_last_frame = false
		modulate = Color.WHITE

func update():
	text = (menu.get_selected_label())
	Shell.speak(menu.get_selected_label())
	modulate = highlight_color
	menu_is_current = true
	await get_tree().process_frame
	menu_was_current_last_frame = true
