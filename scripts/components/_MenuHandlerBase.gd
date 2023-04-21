extends Control
class_name _MenuHandlerBase

## The menu handler base class.
## 
## Implement your own drawing.
## TODO: Merge this class with menu icon functionality,
## and make [Chooser] extend this.

@export_category("Menu")
@export var menu : Menu:
	set(v):
		menu = v
		queue_redraw()
var menu_is_current := false
var menu_was_current_last_frame := false

@export_category("Input Setup")

@export var action_next : StringName = &"ui_right"
@export var action_previous : StringName = &"ui_left"

@export_group("Sound")
@export var stream_player_select : AudioStreamPlayer
@export var stream_player_OK : AudioStreamPlayer
@export var stream_player_cancel : AudioStreamPlayer

func set_handling(m : Menu):
	set_unhandling(menu)
	menu = m
	menu.became_current.connect(update)
	_became_current()
	#update()

func set_unhandling(m : Menu):
	if menu:
		if m == menu:
			if menu.became_current.is_connected(update):
				menu.became_current.disconnect(update)

func _ready():
	if Engine.is_editor_hint(): return
	if menu:
		update()

func _became_current():
	pass

func _input(ev):
	if Engine.is_editor_hint(): return
	
	if not menu:
		return
	if not menu_was_current_last_frame or not menu.is_open:
		return
	if menu.is_iterator:
		return
	
	if Input.is_action_just_pressed(action_next):
		menu.select_next()
		update()
		if stream_player_select:
			stream_player_select.play()
	if Input.is_action_just_pressed(action_previous):
		menu.select_previous()
		update()
		if stream_player_select:
			stream_player_select.play()
	if Input.is_action_just_pressed("OK"):
		queue_redraw()
		menu.choose()
		if menu.is_option_valid(menu._safe_selected_index):
			menu_is_current = false
			menu_was_current_last_frame = false
			if stream_player_OK:
				stream_player_OK.play()
		else:
			# TODO: Invalid option sound.
			pass
	if Input.is_action_just_pressed("CANCEL"):
		menu.back()
		if menu.allows_cancel:
			if menu.parent:
				menu_is_current = false
				menu_was_current_last_frame = false
			if stream_player_cancel:
				stream_player_cancel.play()

func update():
	if not is_inside_tree():
		return
	
	menu_is_current = true
	#Shell.speak(menu.get_selected_label())
	await get_tree().process_frame
	menu_was_current_last_frame = true
