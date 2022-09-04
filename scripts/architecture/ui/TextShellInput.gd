extends TextEdit

@export var output_path : NodePath
@onready var output : RichTextLabel = get_node(output_path)

func _init():
	Shell.input = self

func _ready():
	Shell.output = output
	create_syntax_highlighting()

func _input(ev):
	if ev is InputEventKey:
		if ev.pressed:
			if has_focus():
				# If pressing return but not shift
				if ev.keycode == KEY_ENTER and not Input.is_key_pressed(KEY_SHIFT):
					Shell.execute_block(text)
					await get_tree().process_frame
					text = ""
				# Leave the shell if you press ESCAPE
				if ev.keycode == KEY_ESCAPE or ev.keycode == KEY_F10:
					release_focus()
					output.get_parent().get_parent().get_parent().visible = false
					output.get_parent().get_parent().get_parent().release_focus()
			else:
				if ev.keycode == KEY_F10:
					visible = true
					output.get_parent().get_parent().get_parent().visible = true
					Game.DC.dialog_box.clear()
					grab_focus()

func _on_focus_exited():
	pass

#####################################################

func create_syntax_highlighting(target=self):
	var colour_keyword = Color(0.811765, 0.160784, 0.282353)
	var colour_string  = Color(0.871094, 0.66826, 0.129303)
	var keywords = [
		"await", "item", "give", "take", "list",
		"sfx", "bgm", "load", "resume", "restart", "pause", "stop",
		"with", "mvto", "-", "*", "quit", "menu", "choice",
		"sh", "call", "gdexec", "print", "speak", "clear", "cls",
		
		"save", "load", "quit", "*", "-",
		
		"say", "cutscene", "mvadd", "mvto", "face", "action", "wait",
		"help", "from", "to", "if", "elif", "else", "unless",
		"while", "repeat", "once", "every", "seconds", "frames",
		
		"battle", "request",
	]
	
	var codeh = CodeHighlighter.new()
	
	for keyword in keywords:
		codeh.add_keyword_color(keyword, colour_keyword)

	# Item keys
	codeh.add_color_region("--", "", colour_keyword, true)

	# Strings
	codeh.add_color_region("\"", "\"", colour_string, false)
	codeh.add_color_region("'", "'", colour_string, false)

	# Numbers, Functions, Symbols
	codeh.number_color = Color(0.18566161394119, 0.44732856750488, 1)
	codeh.function_color = Color(0.13934755325317, 0.77332562208176, 1)
	codeh.symbol_color = Color(0.51813143491745, 0.52326500415802, 0.52734375)
	
	target.syntax_highlighter = codeh
