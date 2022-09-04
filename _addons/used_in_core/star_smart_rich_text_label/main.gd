@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"SmartRichTextLabel",
		"RichTextLabel",
		preload("SmartRichTextLabel.gd"),
		preload("addonicon_smart_rich_text_label.png")
	)

func _exit_tree():
	remove_custom_type("SmartRichTextLabel")
