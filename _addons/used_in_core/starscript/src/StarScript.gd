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

## Similar to [method try_as_dictionary], but won't convert
## this object into one, instead, it will convert only the
## inner properties.[br]
## This method actually modifies the contents of this [StarScript].
func compact():
	for key in properties.keys():
		properties[key] = properties[key].try_as_dictionary()
		# If conversion fails:
		if not properties[key] is Dictionary:
			properties[key].compact()
	return self

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
