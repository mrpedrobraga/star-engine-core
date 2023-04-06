extends Resource
class_name StarScriptExpression

const operators : Array[Array] = [
	["\\.", ","],
	["\\*\\*"],
	["\\*", "/", "//", "%"],
	["\\+", "-"],
	[">", "<", ">=", "<=", "==", "!=", "≃"],
	["is", "xis"],
	["not", "bnot"],
	["and", "nand", "band", "bnand"],
	["or", "xor", "nor", "xnor", "bor", "bxor", "bnor", "bxnor"],
]

const operators_unescaped : Array[Array] = [
	[".", ","],
	["**"],
	["*", "/", "//", "%"],
	["+", "-"],
	[">", "<", ">=", "<=", "==", "!=", "≃"],
	["is", "xis"],
	["not", "bnot"],
	["and", "nand", "band", "bnand"],
	["or", "xor", "nor", "xnor", "bor", "bxor", "bnor", "bxnor"],
]

const operators_prefix := [
	"+", "-", "/", "not", "bnot"
]

const operators_postfix := [
	
]

@export var expression : Dictionary

func _to_string():
	return "[E] " + str(expression)

static func parse(raw : String):
	var expr = null
	var tokens : Array = []
	tokens.append_array(get_tokens(raw))
	
	var group_result = group_tokens(tokens)
	
	if not group_result == OK:
		return null
	
	if tokens.size() == 1:
		expr = tokens[0]
	
	var ss_expr := StarScriptExpression.new()
	ss_expr.expression = expr
	return ss_expr
	print(JSON.stringify(expr, '\t', false, true))

static func group_tokens(tokens):
	var opening_position := find_tok(tokens, Token.create(&"("))
	var closing_position := find_closing_tok(tokens, Token.create(&")"), Token.create(&"("))
	while(opening_position != -1):
		if closing_position == -1:
			push_error("Opening '(' has no closing counterpart.")
			return ERR_PARSE_ERROR
		if closing_position < opening_position:
			push_error("Closing ')' has no opening counterpart.")
			return ERR_PARSE_ERROR
		
		var branch := pinch_fold(
			tokens,
			opening_position,
			closing_position - opening_position + 1,
			func (result : Array):
				result.pop_front()
				result.pop_back()
				group_tokens(result)
				return {
					"type": &"grouping",
					"content": result
				}
		)
		
		opening_position = find_tok(tokens, Token.create(&"("))
		closing_position = find_closing_tok(tokens, Token.create(&")"), Token.create(&"("))
	
	
	# Pinch all operators in place...
	for operator in merge_entries(operators_unescaped):
		var pos := find_tok(tokens, Token.create(&"op", operator))
		while pos != -1:
			var branch := pinch_fold(
				tokens, pos - 1, 3,
				func (result : Array):
					return {
						"type": &"op",
						"op": result[1],
						"left": result[0],
						"right": result[2]
					}
			)
			
			pos = find_tok(tokens, Token.create(&"op", "*"))
	
	return OK

static func find_tok(arr : Array, sample : Dictionary) -> int:
	for i in range(arr.size()):
		if not arr[i].has("meta"):
			continue
		if arr[i].type == sample.type and arr[i].value == sample.value:
			return i
	return -1

static func find_closing_tok(arr : Array, sample : Dictionary, open : Dictionary) -> int:
	var nesting := 0
	for i in range(arr.size()):
		if not arr[i].has("meta"):
			continue
		if arr[i].type == open.type and arr[i].value == open.value:
			nesting += 1
		if arr[i].type == sample.type and arr[i].value == sample.value:
			if nesting > 1:
				nesting -= 1
				continue
			return i
	return -1

class Token:
	static func create(type_:StringName, value_ = null) -> Dictionary:
		return {
			"meta": "token",
			"type": type_,
			"value": value_
		}

static func get_tokens(raw : String) -> Array[Dictionary]:
	var tokens : Array[Dictionary] = []
	
	var r_scope_open = RegEx.create_from_string("^\\s*(?<char>\\()")
	var r_scope_close = RegEx.create_from_string("^\\s*(?<char>\\))")
	var r_hex_integer = RegEx.create_from_string("^\\s*(?<content>0x(?:[0-9a-fA-F][0-9a-fA-F_]*))")
	var r_binary_integer = RegEx.create_from_string("^\\s*(?<content>0b(?:[01][01_]*))")
	var r_floating_point = RegEx.create_from_string("^\\s*(?<content>[0-9][0-9_]*\\.(?:[0-9][0-9_]*)?|\\.[0-9][0-9_]*|[0-9][0-9_]*[f])")
	var r_decimal_integer = RegEx.create_from_string("^\\s*(?<content>[0-9][0-9_]*)")
	var r_boolean_true = RegEx.create_from_string("^\\s*(?<content>true|on|yes|sure|always|perhaps)")
	var r_boolean_false = RegEx.create_from_string("^\\s*(?<content>false|off|no|never)")
	var r_operators = RegEx.create_from_string("^\\s*(?<content>%s)" % join(merge_entries(operators)))
	var r_identifier = RegEx.create_from_string("^\\s*(?<content>[a-zA-Z_-][\\w_-]+)")
	
	var ch_index := 0
	var iter_index := 0
	while iter_index < raw.length():
		if ch_index >= raw.length():
			break
		
		var slice = raw.substr(ch_index)
		var mat_ : RegExMatch
		
		# match groupings
		mat_ = r_scope_open.search(slice)
		if mat_:
			tokens.push_back( Token.create(&"(") )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		mat_ = r_scope_close.search(slice)
		if mat_:
			tokens.push_back( Token.create(&")") )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		
		# match hexadecimal literals
		mat_ = r_hex_integer.search(slice)
		if mat_:
			var num : int = _get_num_from_hex(mat_.get_string("content"))
			tokens.push_back( Token.create(&"int", num) )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		
		# match binary literals
		mat_ = r_binary_integer.search(slice)
		if mat_:
			var num : int = _get_num_from_bin(mat_.get_string("content"))
			tokens.push_back( Token.create(&"int", num) )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		
		# match floating_point literals
		mat_ = r_floating_point.search(slice)
		if mat_:
			var num : float = _get_num_from_float(mat_.get_string("content"))
			tokens.push_back( Token.create(&"float", num) )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		
		# match decimal literals
		mat_ = r_decimal_integer.search(slice)
		if mat_:
			var num : int = _get_num_from_dec(mat_.get_string("content"))
			tokens.push_back( Token.create(&"int", num) )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		
		# match boolean literals
		mat_ = r_boolean_true.search(slice)
		if mat_:
			tokens.push_back( Token.create(&"bool", true) )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		mat_ = r_boolean_false.search(slice)
		if mat_:
			tokens.push_back( Token.create(&"bool", false) )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		
		# match operators
		mat_ = r_operators.search(slice)
		if mat_:
			tokens.push_back( Token.create(&"op", mat_.get_string("content")) )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		
		
		# match identifiers (last)
		mat_ = r_identifier.search(slice)
		if mat_:
			tokens.push_back( Token.create(&"identifier", mat_.get_string("content")) )
			ch_index += mat_.get_string().length()
			iter_index += 1; continue
		
		push_error("Unpexpected '%s'." % slice.left(1))
		break
	return tokens

static func merge_entries(array : Array[Array]) -> Array:
	var result := []
	for i in array:
		result.append_array(i)
	return result

static func join(alternatives : Array) -> String:
	var result = str(alternatives[0])
	for i in alternatives.slice(1):
		result += "|"
		result += str(i)
	return result

static func pinch_fold(arr : Array, start_index : int, length : int, formatter : Callable) -> Array:
	var result = arr.slice(start_index, start_index + length)
	for i in result:
		arr.remove_at(start_index)
	arr.insert(start_index, formatter.call(result))
	return result

static func _get_num_from_hex(hex : String) -> int:
	return hex.replacen("_", "").hex_to_int()

static func _get_num_from_bin(bin : String) -> int:
	return bin.replacen("_", "").bin_to_int()

static func _get_num_from_dec(dec : String) -> int:
	return dec.replacen("_", "").to_int()

static func _get_num_from_float(num : String) -> float:
	return num.replacen("_", "").to_float()
