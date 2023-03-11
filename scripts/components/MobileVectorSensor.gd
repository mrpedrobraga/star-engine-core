extends Control

var mouse_over : bool = false
var mouse_down : bool = false

var last_pos := Vector2(0.0,0.0)

func _input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_LEFT:
			mouse_down = ev.pressed
			
			if not ev.pressed:
				last_pos = Vector2()
				queue_redraw()
				push_input(false)
	if ev is InputEventMouseMotion:
		if mouse_down:
			if has_focus():
				last_pos = Vector2(
					remap(
						ev.position.x,
						global_position.x,
						global_position.x + size.x,
						-1,
						1
					),
					remap(
						ev.position.y,
						global_position.y,
						global_position.y + size.y,
						-1,
						1
					)
				)
				
				last_pos = last_pos.limit_length(1.0)
				queue_redraw()
				
				push_input()

@export var input_action_LEFT : StringName = &"move_left"
@export var input_action_RIGHT : StringName = &"move_right"
@export var input_action_UP : StringName = &"move_up"
@export var input_action_DOWN : StringName = &"move_down"

func push_input(pressed=true):
	var ev_left = InputEventAction.new()
	ev_left.action = input_action_LEFT
	ev_left.strength = -min(last_pos.x, 0)
	ev_left.pressed = pressed
	
	var ev_right = InputEventAction.new()
	ev_right.action = input_action_RIGHT
	ev_right.strength = max(last_pos.x, 0)
	ev_right.pressed = pressed
	
	var ev_up = InputEventAction.new()
	ev_up.action = input_action_UP
	ev_up.strength = -min(last_pos.y, 0)
	ev_up.pressed = pressed
	
	var ev_down = InputEventAction.new()
	ev_down.action = input_action_DOWN
	ev_down.strength = max(last_pos.y, 0)
	ev_down.pressed = pressed
	
	Input.parse_input_event(ev_left)
	Input.parse_input_event(ev_right)
	Input.parse_input_event(ev_up)
	Input.parse_input_event(ev_down)

func _notification(what):
	match what:
		NOTIFICATION_FOCUS_ENTER, NOTIFICATION_FOCUS_EXIT:
			queue_redraw()

func _draw():
	return
#	if has_focus():
#		draw_arc(size/2,size.x/2,0,TAU,32,Color.DARK_GRAY,6.0)
#
#	var point := (last_pos + Vector2.ONE) * size * 0.5
#
#	draw_line(size/2, point, Color.GRAY, 8.0, true)
#
#	draw_circle(point, (last_pos).length_squared() * 24 + 8, Color.WHITE)

