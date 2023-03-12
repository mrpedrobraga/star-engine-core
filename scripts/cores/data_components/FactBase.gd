extends Resource
class_name FactBase

## A class storing all the facts of the game,
##
## The facts are stored at paths, and can be easily
## retrieved from, say, a [StarScript].

@export var _data = {}

## Does an operation deep within a dictionary,
## by using a path to resolve which subitem to affect.
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
