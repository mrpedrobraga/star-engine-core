extends StarScriptBlock
class_name StarScript

## Stores a script written in StarScript.

@export_category("Content")

## Dictionary of sections containing all the [StarScriptSection]s
## defined in this file.
@export var sections : Dictionary

@export_category("Extra")

@export_multiline var source_code : String
@export var compilation_version : String = "2.0"

func _to_string():
	#return "SSH"
	
	var repr := ""
	
	var b : String = super()
	if b:
		repr += b
	
	if sections:
		for key in sections.keys():
			repr += "--%s\n%s" % [key, str(sections[key]).indent('\t')]
	
	return repr
