extends Control
class_name JoypadTypingListener

## Class that listens to JoyType-like input.

@export var active = false

signal event(type)

#
#	Valid values are:
#
#		KEY_A - KEY_Z
#		BACKSPACE
#		QUIT
#
func emit(type : StringName):
	event.emit(type)
	print(type)

var keys = {
	0: {
		"LEFT": {
			"LEFT": &"KEY_A",
			"UP": &"KEY_E",
			"RIGHT": &"KEY_O",
			"DOWN": &"KEY_U"
		},
		"UP": {
			"LEFT": &"KEY_D",
			"UP": &"KEY_B",
			"RIGHT": &"KEY_G",
			"DOWN": &"KEY_W"
		},
		"RIGHT": {
			"LEFT": &"KEY_J",
			"UP": &"KEY_K",
			"RIGHT": &"KEY_T",
			"DOWN": &"KEY_X"
		},
		"DOWN": {
			"LEFT": &"KEY_F",
			"UP": &"KEY_V",
			"RIGHT": &"KEY_COMMA",
			"DOWN": &"KEY_SPACE"
		}
	},
	1: {
		"LEFT": {
			"LEFT": &"KEY_C",
			"UP": &"KEY_S",
			"RIGHT": &"KEY_Z",
			"DOWN": &"KEY_H"
		},
		"UP": {
			"LEFT": &"KEY_M",
			"UP": &"KEY_N",
			"RIGHT": &"KEY_P",
			"DOWN": &"KEY_Q"
		},
		"RIGHT": {
			"LEFT": &"KEY_I",
			"UP": &"KEY_Y",
			"RIGHT": &"KEY_L",
			"DOWN": &"KEY_R"
		},
		"DOWN": {
			"LEFT": &"KEY_L",
			"UP": &"KEY_R",
			"RIGHT": &"KEY_PERIOD",
			"DOWN": &"NEWLINE"
		}
	}
}

func _process(delta):
	if not active:
		return
	
	if Input.is_action_just_pressed("joypad_backspace"):
		emit(&"BACKSPACE")
		return
	
	var keygroup : String = "NONE"
	var key : String = "NONE"
	var L1_down := Input.is_action_pressed("joypad_LShoulder")
	
	# Select the key group
	if Input.is_action_pressed("joypad_left_left"): keygroup = "LEFT"
	if Input.is_action_pressed("joypad_left_up"): keygroup = "UP"
	if Input.is_action_pressed("joypad_left_right"): keygroup = "RIGHT"
	if Input.is_action_pressed("joypad_left_down"): keygroup = "DOWN"
	
	# Select the key within the group
	if Input.is_action_pressed("joypad_right_left"): key = "LEFT"
	if Input.is_action_pressed("joypad_right_up"): key = "UP"
	if Input.is_action_pressed("joypad_right_right"): key = "RIGHT"
	if Input.is_action_pressed("joypad_right_down"): key = "DOWN"

	# If anything is pressed on the right joystick,
	# emit a key.
	if (
		Input.is_action_just_pressed("joypad_right_left") or 
		Input.is_action_just_pressed("joypad_right_up") or 
		Input.is_action_just_pressed("joypad_right_right") or 
		Input.is_action_just_pressed("joypad_right_down")
	):
		if not keygroup == "NONE":
			if L1_down:
				emit(keys[1][keygroup][key])
			else:
				emit(keys[0][keygroup][key])
		else:
			emit(
				{
					"LEFT": &"MOVE_LEFT",
					"UP": &"MOVE_UP",
					"RIGHT": &"MOVE_RIGHT",
					"DOWN": &"MOVE_DOWN"
				}[key]
			)
