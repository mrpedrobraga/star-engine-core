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
signal skip_typewriting_pressed

## Whether this label is currently writing.
var is_typing := false
var is_emitting_physical_sound := false
@export var tts_enabled : bool = false

## Whether [method write] will put delay in between each typewritten character.
var write_use_delay:bool = true
## The delay between each character in typewriting.
@export var typewriting_character_delay:float = 0.05
var _typewriting_character_delay_scale := 1.0
## The action listened for to confirm dialogues.
@export var text_ok_action = ""
## The action listened for to skip_typewriting dialogues.
@export var text_skip_typewriting_action = ""
## If skip_typewritingling typewriting allowed.
@export var disable_skip_typewriting = false

@export var typewriting_tag_whitelist := [
	"pause", "speed", "skip", "no_tw", "tw", "portrait", "input"
]

@export_category("Hookups")

@export var text_action_prompt_node : CanvasItem
@export var portrait_node : AnimatedSprite2D
@export var portrait_anim_player : AnimationPlayer

func _ready():
	skip_typewriting_pressed.connect(skip_typewriting_write)

func _input(event):
	if text_ok_action:
		if Input.is_action_just_pressed(text_ok_action):
			emit_signal("ok_pressed")
	if text_skip_typewriting_action and not disable_skip_typewriting:
		if Input.is_action_just_pressed(text_skip_typewriting_action):
			emit_signal("skip_typewriting_pressed")
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					ok_pressed.emit()
				MOUSE_BUTTON_RIGHT:
					skip_typewriting_pressed.emit()

var last_character_had_portrait : bool = false

func write(_text, speaker = null, default_portrait = "default"):
	## Handle voices & portraits:
	if speaker:
		if &"voices" in speaker:
			var voice : AudioStream #= default_voice
			if speaker.voices.has("default"):
				voice = speaker.voices.default
		if portrait_anim_player:
			if &"portraits" in speaker and portrait_node:
				if speaker.portraits:
					portrait_node.sprite_frames = speaker.portraits
					play_portrait(default_portrait, true)
					if not last_character_had_portrait:
						portrait_anim_player.play(&"appear")
						last_character_had_portrait = true
				else:
					if last_character_had_portrait:
						last_character_had_portrait = false
						portrait_anim_player.play_backwards(&"appear")
	else:
		if last_character_had_portrait:
			last_character_had_portrait = false
			portrait_anim_player.play_backwards(&"appear")
	
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
			",", ";", ":":
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
						_typewriting_character_delay_scale = 1. / evt.params.to_int()
					"no_tw":
						write_use_delay = false
					"tw":
						write_use_delay = true
					"skip":
						print('skipping')
						clear()
						resumed.emit()
						completed.emit()
						is_emitting_physical_sound = false
						show_input_request(false)
						return
					"portrait":
						default_portrait = evt.params
						play_portrait(default_portrait, true)
					"input":
						paused.emit()
						is_emitting_physical_sound = false
						is_typing = false
						show_input_request(true)
						play_portrait(default_portrait, false)
						await self.ok_pressed
						show_input_request(false)
						play_portrait(default_portrait, true)
						is_emitting_physical_sound = true
						resumed.emit()
						is_typing = true
					"pause":
						play_portrait(default_portrait, false)
						await get_tree().create_timer(_typewriting_character_delay_scale * typewriting_character_delay * 4.0 * evt.params.to_int()).timeout
						play_portrait(default_portrait, true)
			_:
				beep()
				char_written.emit()
				if write_use_delay:
					await get_tree().create_timer(_typewriting_character_delay_scale * typewriting_character_delay).timeout
				visible_characters += 1
		char_tick.emit()
		queue_redraw()
	paused.emit()
	is_typing = false
	is_emitting_physical_sound = false
	show_input_request(true)
	play_portrait(default_portrait, false)
	await ok_pressed
	show_input_request(false)
	clear()
	resumed.emit()
	completed.emit()

func play_portrait(p_name : String, talking : bool = false):
	if not portrait_anim_player:
		return
	if talking and portrait_node.sprite_frames.has_animation(p_name + "_t"):
		portrait_node.play(p_name + "_t")
		return
	if portrait_node.sprite_frames.has_animation(p_name):
		portrait_node.play(p_name)
	else:
		push_warning("No portrait named '%s' in %s." % [p_name, portrait_node.sprite_frames])

func end_session():
	if last_character_had_portrait:
		last_character_had_portrait = false
		portrait_anim_player.play_backwards(&"appear")

func beep():
	if has_node("beep"):
		get_node(^"beep").play()

func show_input_request(value):
	if text_action_prompt_node == null:
		return
	text_action_prompt_node.visible = value
	if value and text_action_prompt_node.has_node("anim"):
		text_action_prompt_node.get_node("anim").play("bounce")

func skip_typewriting_write():
	if is_typing:
		is_typing = false
		visible_ratio = 0.99999

const FormatCharacters : Dictionary = {
	GENERIC = "§"
}

var _last_processed_string : String = ""

var special_buffer : Array = [
	
]

func special_format(input : String):
	special_buffer.clear()
	
	input = input.replace("\\n", "\n")
	input = input.replace("[br]", "\n")
	
	var r_expr = RegEx.new()
	r_expr.compile("\\[(?<key>\\w+)(?<params> .*?)?\\]")
	var m_expr : Array[RegExMatch] = r_expr.search_all(input)
	for mm in m_expr:
		if mm.get_string(1) in typewriting_tag_whitelist:
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
