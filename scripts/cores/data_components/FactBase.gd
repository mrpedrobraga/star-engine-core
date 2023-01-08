extends Resource
class_name FactBase

@export var _data = {}

func dict_op(dictionary : Dictionary, path : NodePath, function : Callable):
	var max_index = path.get_name_count() - 1
	var dict = dictionary
	
	for i in path.get_name_count():
		var n := path.get_name(i)
		
		if i == max_index:
			return function.call(dict, n)
		else:
			if dict.has(n):
				dict = dict[n]
			else:
				var next_dict = {}
				dict[n] = next_dict
				dict = next_dict

## Sets a fact to hold a value.
func set_fact(fact : NodePath, value=false):
	dict_op(_data, fact, (func(d, n): d[n] = value))

## Returns the value of a fact.
func get_fact(fact : NodePath):
	return dict_op(_data, fact, (func(d, n): return d[n]))

## Checks whether a certain fact exists.
func is_fact(fact : NodePath):
	return dict_op(_data, fact, (func(d, n): return d.has(n)))
