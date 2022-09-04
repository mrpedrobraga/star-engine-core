##A Label that supports BBCode and simple prosody typewriting.

@tool
extends RichTextLabel
class_name SmartRichTextLabel

##################################################################
#
#	Chroma RPG SmartRichTextLabel 
#
#	A Label that supports BBCode and simple prosody typewriting.
#	Version Inner Voices 1.0
#
##################################################################

# Triggered when a character is written.
signal char_written
# Triggered when a character is processed (there are non written characters).
signal char_tick
# Triggered when the writing is paused midtext AND when the text ends.
signal paused
# Triggered when the writing is resumed after being paused, or after finishing.
signal resumed
# The text completed writing and is ready to move on to the next.
# Use this to control the flow of dialog in your dialog sequence.
signal completed

signal ok_pressed
signal cancel_pressed

# Whether this label is currently writing.
var is_typing := false
var is_emitting_physical_sound := false

@export var text_delay:float = 0.05
@export var text_ok_action = ""
@export var text_cancel_action = ""

@export var text_action_prompt_node_path : NodePath

@export var tts_enabled : bool = false

func _ready():
	cancel_pressed.connect(cancel_write)

func _input(event):
	if text_ok_action:
		if Input.is_action_just_pressed(text_ok_action):
			emit_signal("ok_pressed")
	if text_cancel_action:
		if Input.is_action_just_pressed(text_cancel_action):
			emit_signal("cancel_pressed")
func _gui_input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("ok_pressed")
			MOUSE_BUTTON_RIGHT:
				emit_signal("cancel_pressed")

func write(_text):
	is_typing = true
	is_emitting_physical_sound = true
	clear()
	visible = true
	parse_bbcode(special_format(_text))
	visible_characters = 0
	
	var old_text = get_parsed_text()
	
	for i in FormatCharacters.values():
		text = text.replace(i, "")
	
	var parsed_text = get_parsed_text()
	DisplayServer.tts_speak(parsed_text, "")
	
	resumed.emit()
	
	for character in old_text:
		if not is_typing:
			break
		match character:
			",":
				visible_characters += 1
				await get_tree().create_timer(0.1).timeout
				char_written.emit()
			";":
				visible_characters += 1
				await get_tree().create_timer(0.1).timeout
				char_written.emit()
			":":
				visible_characters += 1
				await get_tree().create_timer(0.1).timeout
				char_written.emit()
			".":
				visible_characters += 1
				beep()
				await get_tree().create_timer(0.1).timeout
				char_written.emit()
			FormatCharacters.WAIT:
				await get_tree().create_timer(text_delay * 4.0).timeout
			FormatCharacters.INPUT:
				paused.emit()
				is_emitting_physical_sound = false
				is_typing = false
				show_input_request(true)
				await self.ok_pressed
				show_input_request(false)
				is_emitting_physical_sound = true
				resumed.emit()
				is_typing = true
			" ":
				visible_characters += 1
			"	":
				visible_characters += 1
			FormatCharacters.SKIP:
				clear()
				resumed.emit()
				completed.emit()
				is_emitting_physical_sound = false
				show_input_request(false)
				return
			_:
				beep()
				char_written.emit()
				await get_tree().create_timer(text_delay).timeout
				visible_characters += 1
		char_tick.emit()
		update()
	paused.emit()
	is_typing = false
	is_emitting_physical_sound = false
	show_input_request(true)
	await ok_pressed
	show_input_request(false)
	clear()
	resumed.emit()
	completed.emit()
	print("DIALOG FINISHED")

func beep():
	if has_node("beep"):
		get_node(^"beep").play()

func show_input_request(value):
	if text_action_prompt_node_path == null:
		return
	var ir = get_node(text_action_prompt_node_path)
	ir.visible = value
	if value and ir.has_node("anim"):
		ir.get_node("anim").play("bounce")

func cancel_write():
	if is_typing:
		is_typing = false
		visible_ratio = 0.99999

const FormatCharacters : Dictionary = {
	SKIP = "¹",
	INPUT = "§",
	WAIT = "¢",
}

func special_format(input : String):
	input = input.replace("[skip]", FormatCharacters.SKIP)
	input = input.replace("[input]", FormatCharacters.INPUT)
	input = input.replace("\\n", "\n")
	input = input.replace("[br]", "\n")
	
	var r = RegEx.new()
	r.compile("\\[pause=(?<amt>\\d+)\\]")
	var m : Array[RegExMatch] = r.search_all(input)
	
	for mm in m :
		var n = (mm.strings[mm.names.amt])
		input = r.sub(input, FormatCharacters.WAIT.repeat(n.to_int()))
	
	return input
