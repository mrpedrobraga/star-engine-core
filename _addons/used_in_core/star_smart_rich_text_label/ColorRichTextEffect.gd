@tool
extends RichTextEffect
class_name ColorRichTextEffect

@export var bbcode = "colour"
@export var color := Color.RED

func _process_custom_fx(char_fx:CharFXTransform):
	char_fx.color = color
