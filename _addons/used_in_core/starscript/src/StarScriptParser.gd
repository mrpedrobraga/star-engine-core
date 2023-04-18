extends Node
class_name StarScriptParser

## The class that parses raw text
## into a [StarScript] resource.

const regex_identifier = "[\\w-]+"
const regex_command_template = "(\\w+|<\\w+>|<\\w+:\\w+>|\\[\\w+(?:\\|\\w+)+\\])"
const regex_assignment_expr = "(?<lval>%s)\\s*(?<op>\\+=|-=|\\*=|\\/=|\\/\\/=|%%=|=)\\s*(?<rval>.*)" % regex_identifier
const regex_dialog = "(?<prefix>[-*])\\s*(?:(?<name>[\\w-]+)(?<modifiers>(?:,[\\w\\s-]+)+)?\\s*:\\s*)?(?<content>.*)"
const regex_property = "\\s*(?<prop>\\w+)\\s*:\\s*(?<content>.+)?"
const regex_expr = "^\\s*{(?<content>.*)}"
const word_characters = "abcdefghijklmnop"
const CHAR_ESCAPE = "\\"
const GROUPING_BEGIN = "("
const GROUPING_END = ")"

enum ParsingContext {
	NORMAL,
	LINE_COMMENT,
	BLOCK_COMMENT,
	SECTION,
	LABEL,
	LINE,
	GROUPING,
}

class ParsingCandidate:
	var phrase : Array[String]
	var source_line : int = 0
	var indentation_level : int = 0
	
	static func create(phrase : Array[String], source_line : int, i : int) -> ParsingCandidate:
		var pc := ParsingCandidate.new()
		pc.phrase = phrase
		pc.source_line = source_line
		pc.indentation_level = i
		return pc
	
	func _to_string():
		return ('At line %s: %s %s') % [source_line + 1, indentation_level, phrase]

# Parses a star script text and returns a star script object.
static func parse(source : String, target_shell = null) -> StarScript:
	var root_scope := StarScript.new()
	root_scope.source_code = source
	
	var indentation_stack := [0]
	var parsing_candidates := get_tokens(source, target_shell)
	var scope_stack : Array = []
	scope_stack.push_back(root_scope)
	var last_instruction : StarScriptBlock = null
	
	for p in parsing_candidates:
		#print(p)
		match p.phrase[0]:
			"INDENT":
				if last_instruction:
					scope_stack.push_back(last_instruction)
					#print("{", scope_stack, "}")
					pass
			"DEDENT":
				scope_stack.pop_back()
				#print("{", scope_stack, "}")
				pass
			"SECTION":
				var s := StarScriptSection.new()
				print(s)
				root_scope.sections[p.phrase[1]] = (s)
				scope_stack = [root_scope]
				last_instruction = s
			"LINE":
				var line = parse_line(p.phrase.slice(1), target_shell)
				
				match line.type:
					"command":
						var cmd = line.content
						last_instruction = cmd
						scope_stack[-1].commands.push_back(cmd)
					"property":
						# TODO: Create a dedicated [StarScriptProperty] class.
						var cmd = StarScriptCommand.create(&"prop", [line.content])
						last_instruction = cmd
						scope_stack[-1].properties[line.name] = (cmd)
					"expr":
						scope_stack[-1].commands.push_back(
							StarScriptCommand.create(&"eval", [line.content])
						)
		pass
	
	root_scope.compact()
	return root_scope

static func get_tokens(source : String, target_shell = null) -> Array[ParsingCandidate]:
	# This function will iterate through all the characters to get
	# parsing candidates, that [method parse] will build into
	# [StarScriptBlock]s.
	
	# Constants
	const ESCAPE_CHARACTER = "\\"
	const LINE_COMMENT_OPENER = "#"
	const BLOCK_COMMENT_OPENER = "###"
	const BLOCK_COMMENT_CLOSER = "###"
	const SECTION_DECLARATION_OPENER = "--"
	const SECTION_CALL_OPENER = "--"
	
	# Counters for the current line.
	var cursor_y := 0
	var cursor_x := 0
	
	# The line and column of the instructions being built.
	var phrase_begin_x_stack := [0]
	var phrase_begin_y_stack := [0]
	
	# The indentation stack, used to
	# create INDENT and DEDENT recognition.
	var indentation_stack := [0]
	var previous_indentation_stack := [0]
	const INDENT_STRING := "\t"
	
	# The index of the iteration, as a safety measure.
	var iter_index := 0
	# The index of the current character, used to sample from [param source].
	var character_index := 0
	# The instruction buffer, where characters will be
	# clumped together to create tokens.
	var instruction_buffer : String
	# The stack of lists of recent tokens, which will be used to create phrases.
	var token_buffer_stack : Array[Array] = [[]]
	# The list of created phrases, which will be passed onto
	# the next stage of parsing.
	var phrases : Array[ParsingCandidate]
	
	# An array of parsing contexts.
	# Append a new value to create a temporary context
	# Then pop the array to return to the previous one.
	#
	# Access the curent context using c_stack[-1]
	var context_stack : Array[ParsingContext] = [ParsingContext.NORMAL]
	# If currently on the beggining whitespace of a block.
	var beggining_of_line := true
	
	# Iterate through all the characters
	while iter_index < source.length():
		# Detect end of file.
		if character_index >= source.length():
			break
		
		# The current character
		var cur_char = source[character_index]
		# The current context
		var cur_context := context_stack[-1]
		
		# Whether the cursor has already been advanced
		# in this iteration.
		var advanced_cursor := false
		# Whether this is an "empty line",
		# i.e., has no characters other than a single '\n'.
		var empty_line := true
		
		# ParsingContext specifices how the characters are
		# analyzed to create tokens.
		
		#print([cur_char])
		
		match cur_context:
			# The normal context looks for patterns to
			# create new parsing subcontexts.
			ParsingContext.NORMAL:
				# If on the beggining of line, look for indentaiton
				if beggining_of_line:
					# If finding an indentation character,
					# increment the current indentation
					if cur_char == INDENT_STRING:
						indentation_stack[-1] += 1
					# If this isn't an indentation character,
					# the indent part of your line finished, 
					# and your command is about to start.
					else:
						beggining_of_line = false
						# Assign the current column and line of this instruction
						# to their respective stacks.
						phrase_begin_x_stack.push_back(cursor_x)
						phrase_begin_y_stack.push_back(cursor_y)
						# Clear the instruction buffer in preparation to read the
						# next command.
						instruction_buffer = ""
						if not cur_char in [
							"\n", " ", BLOCK_COMMENT_OPENER[0], LINE_COMMENT_OPENER
						]:
							empty_line = false
						if not empty_line:
							if indentation_stack[-1] > previous_indentation_stack[-1]:
								#print("-> ", cursor_y+1, indentation_stack, previous_indentation_stack)
								var indent := ParsingCandidate.create(
									["INDENT"],
									cursor_y,
									indentation_stack[-1]
								)
								phrases.push_back(indent)
								indentation_stack.push_back(indentation_stack[-1])
								previous_indentation_stack.push_back(indentation_stack[-1])
							elif indentation_stack[-1] < previous_indentation_stack[-1]:
								var dedent_counter = 0
								# If the current indentation is lower than the previous,
								# add dedents until you match the indentation of the previous scope.
								while indentation_stack[-1] < previous_indentation_stack[-1]:
									#print("<- ", cursor_y+1, indentation_stack, previous_indentation_stack)
									var dedent := ParsingCandidate.create(
										["DEDENT"],
										cursor_y,
										indentation_stack[-1]
									)
									phrases.push_back(dedent)
									previous_indentation_stack.pop_back()
									dedent_counter += 1
								# The current indentation needs to be updated last,
								# when the indentation matches the previous scopes' indentation.
								for i in dedent_counter:
									indentation_stack.pop_back()
					
				# If finding a block comment starting string,
				# it creates a block comment context.
				if source.substr(character_index, BLOCK_COMMENT_OPENER.length()) == BLOCK_COMMENT_OPENER:
					# Push the new context
					#print('NEW CONTEXT: BLOCK_COMMENT')
					context_stack.push_back(ParsingContext.BLOCK_COMMENT)
					phrase_begin_x_stack.push_back(cursor_x)
					phrase_begin_y_stack.push_back(cursor_y)
					# ADVANCE THE CURSOR MANUALLY
					cursor_x += BLOCK_COMMENT_OPENER.length()
					character_index += BLOCK_COMMENT_OPENER.length()
					iter_index += 1
					advanced_cursor = true
				# If finding a line comment starting character,
				# it creates a line comment context.
				elif cur_char == LINE_COMMENT_OPENER: # '#'
					# Push the new context.
					#print('NEW CONTEXT: LINE_COMMENT')
					context_stack.push_back(ParsingContext.LINE_COMMENT)
					phrase_begin_x_stack.push_back(cursor_x)
					phrase_begin_y_stack.push_back(cursor_y)
					# Clear the instruction buffer.
					instruction_buffer = ""
				
				# If finding a section declaration starting string,
				# it creates a section declaration context.
				elif source.substr(character_index, SECTION_DECLARATION_OPENER.length()) == SECTION_DECLARATION_OPENER:
					# Push the new context
					#print('NEW CONTEXT: SECTION')
					context_stack.push_back(ParsingContext.SECTION)
					phrase_begin_x_stack.push_back(cursor_x)
					phrase_begin_y_stack.push_back(cursor_y)
					# ADVANCE THE CURSOR MANUALLY
					cursor_x += SECTION_DECLARATION_OPENER.length()
					character_index += SECTION_DECLARATION_OPENER.length()
					iter_index += 1
					advanced_cursor = true
				elif cur_char in ['\t', '\n', ' ']:
					pass
				# If didn't match any of those:
				else:
					# Push the new context
					#print('NEW CONTEXT: LINE')
					instruction_buffer += cur_char
					context_stack.push_back(ParsingContext.LINE)
			
			# A line comment consumes all characters
			# until a \n is found.
			ParsingContext.LINE_COMMENT:
				if cur_char == "\n":
					if instruction_buffer.right(1) != ESCAPE_CHARACTER:
						phrases.push_back( ParsingCandidate.create(
							["COMMENT", "LINE", instruction_buffer],
							phrase_begin_y_stack[-1],
							indentation_stack[-1]
						))
						
						instruction_buffer = ""
						
						# Go back to the previous context,
						# clear the instruction buffer.
						context_stack.pop_back()
						phrase_begin_x_stack.pop_back()
						phrase_begin_y_stack.pop_back()
					else:
						instruction_buffer = instruction_buffer.left(instruction_buffer.length() - 1)
						instruction_buffer += " "
				else:
					instruction_buffer += cur_char
			
			# A block comment consumes all characters
			# until BLOCK_COMMENT_CLOSER.
			ParsingContext.BLOCK_COMMENT:
				if source.substr(character_index, BLOCK_COMMENT_CLOSER.length()) == BLOCK_COMMENT_CLOSER and\
					not source.substr(character_index+BLOCK_COMMENT_CLOSER.length()) == BLOCK_COMMENT_CLOSER.right(1):
					phrases.push_back( ParsingCandidate.create(
						["COMMENT", "BLOCK", instruction_buffer],
						phrase_begin_y_stack[-1],
						indentation_stack[-1]
					))
					
					instruction_buffer = ""
					
					# Go back to the previous context,
					# clear the instruction buffer.
					context_stack.pop_back()
					phrase_begin_x_stack.pop_back()
					phrase_begin_y_stack.pop_back()
					
					# ADVANCE THE CURSOR
					cursor_x += BLOCK_COMMENT_CLOSER.length()
					character_index += BLOCK_COMMENT_CLOSER.length()
					iter_index += 1
					advanced_cursor = true
				else:
					instruction_buffer += cur_char
			
			# A section declaration consumes all characters
			# until a \n is found.
			ParsingContext.SECTION:
				if cur_char == "\n":
					if instruction_buffer.right(1) != ESCAPE_CHARACTER:
						phrases.push_back( ParsingCandidate.create(
							["SECTION", instruction_buffer],
							cursor_y,
							indentation_stack[-1]
						))
						
						instruction_buffer = ""
						
						# Go back to the previous context,
						# clear the instruction buffer.
						context_stack.pop_back()
						phrase_begin_x_stack.pop_back()
						phrase_begin_y_stack.pop_back()
					else:
						instruction_buffer = instruction_buffer.left(instruction_buffer.length() - 1)
						instruction_buffer += " "
				else:
					instruction_buffer += cur_char
		
			# A line (unknown between a command, property or dialogue)
			# consumes all characters until an unescaped \n is found.
			ParsingContext.LINE:
				if cur_char == "\n":
					if instruction_buffer.right(1) != ESCAPE_CHARACTER:
						if instruction_buffer:
							phrases.push_back( ParsingCandidate.create(
								["LINE", instruction_buffer.strip_edges()],
								cursor_y,
								indentation_stack[-1]
							))
						
						instruction_buffer = ""
						
						# Go back to the previous context,
						# clear the instruction buffer.
						context_stack.pop_back()
						phrase_begin_x_stack.pop_back()
						phrase_begin_y_stack.pop_back()
					else:
						instruction_buffer = instruction_buffer.left(instruction_buffer.length() - 1)
						instruction_buffer += " "
				else:
					instruction_buffer += cur_char
		
		if not advanced_cursor:
			if cur_char == "\n":
				# When a line breaks,
				# the line increases and the column
				# is reset to 0.
				cursor_y += 1
				cursor_x = 0
				beggining_of_line = true
				if not empty_line:
					previous_indentation_stack[-1] = indentation_stack[-1]
				indentation_stack[-1] = 0
			else:
				# Otherwise, the column increases
				# steadily.
				cursor_x += 1
			
			# Remember to move the character cursor
			# forward
			character_index += 1
			iter_index += 1
			
			advanced_cursor = true
		continue
	
	# Return all the phrases,
	# which will be made into objects in the
	# next parsing stage.
	print("TOKENIZATION FINISHED")
	return phrases

static func parse_line(line : Array, target_shell = null):
	var raw : String = line[0]
	#print(raw)
	var result := {
		"type": "command",
		"content": StarScriptCommand.new()
	}
	
	var r_dialog := RegEx.create_from_string(regex_dialog)
	var r_property := RegEx.create_from_string(regex_property)
	var r_label := RegEx.create_from_string("::%s::")
	var r_expression := RegEx.create_from_string(regex_expr)
	var r_assignment := RegEx.create_from_string(
		"(?<lval>%s)\\s*(?<op>\\+=|-=|\\*=|\\/=|\\/\\/=|%%=|=)\\s*(?<rval>.*)" % regex_identifier
	)
	
	var match_ : RegExMatch
	
	# Match regex_expr!
	match_ = r_expression.search(raw)
	if match_:
		var groups = get_named_groups(match_)
		result.type = "expr"
		result.content = StarScriptExpression.parse(groups.content)
		return result
	
	# Match assignment expressions!
	match_ = r_assignment.search(raw)
	if match_:
		var groups = get_named_groups(match_)

		result.content.key = &"assign"
		result.content.params = [groups.op, groups.lval, parse_line([groups.rval], target_shell)]

		return result
	
	
	# Match r_dialog!
	match_ = r_dialog.search(raw)
	if match_:
		var groups = get_named_groups(match_)
		result.content.key = &"dialog"
		result.content.params = []
		result.content.params.append(groups.content)
		result.content.params.append(groups.prefix)
		result.content.params.append(groups["name"] if groups.has("name") else "")
		if groups.has("modifiers"):
			var r_identifier := RegEx.create_from_string(regex_identifier)
			var matches := r_identifier.search_all(groups.modifiers)
			for m in matches:
				result.content.params.append(m.get_string())
		return result
	
	# Match r_property!
	match_ = r_property.search(raw)
	if match_:
		var groups = get_named_groups(match_)
		result.type = "property"
		result.name = groups.prop
		if not groups.has('content'):
			groups.content = null
		result.content = groups.content
		return result
	
	var broken_params = line[0].split(" ")
	result.content.key = StringName(broken_params[0])
	result.content.params = broken_params.slice(1)
	return result
	
	# TODO: THROW ERROR OR SOMETHING!!!
	return null

static func get_named_groups(m : RegExMatch) -> Dictionary:
	var d := {}
	if not m: return d
	
	for name in m.names:
		d[name] = m.get_string(name)
	
	return d

static func throw_parse_error(
	source:String,
	line:int,
	column:int,
	error_name:String="Error",
	error_desc:String=""
):
	push_error("At line %s, column %s: %s" % [line, column, error_desc])
