##A Label that supports BBCode and simple prosody typewriting.

@tool
@icon("icon_smart_rich_text_label.png")
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
var _text_delay_scale := 1.0
var wait_for_text_delay:bool = true
@export var text_ok_action = ""
@export var text_cancel_action = ""

@export var disable_cancel = false

@export var text_action_prompt_node : CanvasItem

@export var tts_enabled : bool = false

func _ready():
	cancel_pressed.connect(cancel_write)

func _input(event):
	if text_ok_action:
		if Input.is_action_just_pressed(text_ok_action):
			emit_signal("ok_pressed")
	if text_cancel_action and not disable_cancel:
		if Input.is_action_just_pressed(text_cancel_action):
			emit_signal("cancel_pressed")
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					ok_pressed.emit()
				MOUSE_BUTTON_RIGHT:
					cancel_pressed.emit()

func write(_text):
	is_typing = true
	is_emitting_physical_sound = true
	clear()
	visible = true
	var with_bb_code = special_format(_text)
	parse_bbcode(with_bb_code)
	visible_characters = 0
	
	var old_text = get_parsed_text()
	
	for i in FormatCharacters.values():
		with_bb_code = with_bb_code.replace(i, "")
	parse_bbcode(with_bb_code)
	
	#if tts_enabled: DisplayServer.tts_speak(get_parsed_text(), "")
	
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
			" ":
				visible_characters += 1
			"	":
				visible_characters += 1
			FormatCharacters.GENERIC:
				
				var evt = special_buffer.pop_front()
				
				match evt.type:
					"speed":
						_text_delay_scale = 1. / evt.params.to_int()
					"no_tw":
						wait_for_text_delay = false
					"tw":
						wait_for_text_delay = true
					"skip":
						print('skipping')
						clear()
						resumed.emit()
						completed.emit()
						is_emitting_physical_sound = false
						show_input_request(false)
						return
					"input":
						paused.emit()
						is_emitting_physical_sound = false
						is_typing = false
						show_input_request(true)
						await self.ok_pressed
						show_input_request(false)
						is_emitting_physical_sound = true
						resumed.emit()
						is_typing = true
					"pause":
						await get_tree().create_timer(_text_delay_scale * text_delay * 4.0 * evt.params.to_int()).timeout
			_:
				beep()
				char_written.emit()
				if wait_for_text_delay:
					await get_tree().create_timer(_text_delay_scale * text_delay).timeout
				visible_characters += 1
		char_tick.emit()
		queue_redraw()
	paused.emit()
	is_typing = false
	is_emitting_physical_sound = false
	show_input_request(true)
	await ok_pressed
	show_input_request(false)
	clear()
	resumed.emit()
	completed.emit()

func beep():
	if has_node("beep"):
		get_node(^"beep").play()

func show_input_request(value):
	if text_action_prompt_node == null:
		return
	text_action_prompt_node.visible = value
	if value and text_action_prompt_node.has_node("anim"):
		text_action_prompt_node.get_node("anim").play("bounce")

func cancel_write():
	if is_typing:
		is_typing = false
		visible_ratio = 0.99999

const FormatCharacters : Dictionary = {
	GENERIC = "§"
}

var _last_processed_string : String = ""

var special_buffer : Array = [
	
]

@export var tw_tags := [
	"pause", "speed", "skip", "no_tw", "tw", "portrait", "input"
]

func special_format(input : String):
	special_buffer.clear()
	
	input = input.replace("\\n", "\n")
	input = input.replace("[br]", "\n")
	
	var r_expr = RegEx.new()
	r_expr.compile("\\[(?<key>\\w+)(?<params> .*?)?\\]")
	var m_expr : Array[RegExMatch] = r_expr.search_all(input)
	for mm in m_expr:
		if mm.get_string(1) in tw_tags:
			input = input.replace(mm.get_string(), FormatCharacters.GENERIC)
			special_buffer.append(
				{
					"type": mm.get_string(1),
					"params": mm.get_string(2).trim_prefix(" ")
				}
			)
	_last_processed_string = input
	return input

#* Hey.[input] You're so cool!
#* pot[pause 3]pourri
#* I have [expr 3 + 3] items.
