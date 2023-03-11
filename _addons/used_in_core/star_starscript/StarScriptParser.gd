#########################################
#										#
#		SSP  Utility Class 1.0.0		#
#			by Pedro Braga				#
#										#
#	Loads and parses .ssh files into 	#
#	usable Dictionaries.				#
#										#
#########################################

@tool
class_name StarScriptParser

# Some cool RegExs for parsing things
const regex_sobj_text = "(?mJ)^(?<colon>--)?(?<key>(?:\\w+|-|\\*)) *(?<colon>:)? *(?<params>.*)?(?<block>(?:\\n\\t.*)*)?"
const regex_dialog_text = "(?<speaker>[\\w_]+)(?:\\s*,\\s*(?<options>[\\w ,]*))*\\s*:\\s*(?<message>.*)"

# Loads 
static func load_sson(path):
	print_rich("[b]Loading from: [/b]" + path)
	var file = FileAccess.open(path, FileAccess.READ)
	var raw = file.get_as_text()
	
	return raw

# Parses an object according to the following specification
#
#	#key1
#		instruction1 params
#		instruction2
#		value1: 0
#		value2: 0
#
#	An SObject is generated with the KEY as the name,
#	space separated parameters (with " support) under "params",
#	a set of instructions (SObjects) under "content" and
#	arbitrary values under "data". See SObject below.
#
#	An SObject is a dictionary with this scheme:
#		{
#			"params": ["param1", "param2"],		# An array of parameters!
#			"content": [SObject1, SObject2],	# An array containing a sequence of SObjects.
#			"data1": {...}						# A dictionary containing arbitrary data (can be SObjects, but not necessarily!).
#		}
#

static func parse(raw, top_level=true):
	var regex_sobj   := RegEx.new()
	var regex_dialog := RegEx.new()
	regex_sobj.compile(regex_sobj_text)
	regex_dialog.compile(regex_dialog_text)

	# Match the entire raw file for SObject entries
	var results = {
		"content": [],
		"data": {}
	}
	
	raw = preformat(raw)
	
	for result in regex_sobj.search_all(raw):
		var r
		
		var names = result.get_names();
		
		if names.has("colon"):
			r = {}
			var is_dict = false
			if names.has("block"):
				var block = parse(remove_indentation(result.get_string("block")), false)
				if block.content:
					r["content"] = block.content; is_dict = true
				if block.data:
					r["data"] = block.data; is_dict = true
			elif not names.has("params"):
				print("(!) Data element without any parameters.")
				return ERR_PARSE_ERROR
			results.data[result.get_string("key")] = r if is_dict else result.get_string("params")
		else:
			r = {}
			r["key"] = result.get_string("key")
			
			if names.has("params"):
				if result.get_string("params"):
					r["params"] = result.get_string("params")
					
					# Check for the special case of dialogs
					if r.key == "-":
						var mm := regex_dialog.search(r.params)
						if mm == null:
							print("(!) DIALOG INVALID: ", r.params)
							continue
						r.speaker = mm.get_string("speaker")
						r.message = mm.get_string("message")
						if mm.names.has("options"):
							r.params  = mm.get_string("options").split(",")
							for i in range(r.params.size()): r.params[i] = r.params[i].strip_edges()
						else:
							r.params = []
						
			if names.has("block"):
				var block = parse(remove_indentation(result.get_string("block")), false)
				if block.content:
					r["content"] = block.content
				if block.data:
					r["data"]    = block.data
			results.content.push_back(r)
	#if top_level:
	#	print("RAW:\n", raw, "\n---------------------------\n\n")
	#	print(JSON.print(results, "\t"))
	return results

static func remove_indentation(string, indentation_character="\t"):
	var r = RegEx.new()
	r.compile("(?m)^"+indentation_character)
	return r.sub(string, "", true)

static func split_params(params) -> Array:
	if params == null:
		return []
	var r := RegEx.new()
	r.compile('[^\\s"\']+|"([^"]*)"|\'([^\']*)\'')
	var result = []
	for m in r.search_all(params):
		var mn = m.get_names()
		if mn.has('b'):
			result.push_back(m.get_string('b'))
		elif mn.has('a'):
			result.push_back(m.get_string('a'))
		else:
			result.push_back(m.get_string(0))
	return result

static func preformat(source:String):
	var r_multi_break = RegEx.new()
	r_multi_break.compile("\\n\\n+")
	
	var r_new_line = RegEx.new()
	r_new_line.compile("\\[newline\\]")
	
	
	source = r_multi_break.sub(source, "\n", true)
	source = r_new_line.sub(source, "\n", true)
	
	return source
