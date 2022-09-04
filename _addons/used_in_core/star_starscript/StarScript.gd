#########################################
#										#
#		StarScript Resource 1.0.0 		#
#			by Pedro Braga				#
#										#
#	Holds information like a dictionary	#
#										#
#########################################

extends Resource
class_name StarScript

# content: the content of this object.
#	It's a dictionary containing sequences of SObjects.
#	
#	{
#		"key_1": [
#			SObject1, SObject2
#		]
#	}
#	
#	An SObject is a dictionary with this scheme:
#		{
#			"params": ["param1", "param2"],		# An array of parameters!
#			"content": [SObject1, SObject2],	# An array containing a sequence of SObjects.
#			"data1": {...}						# A dictionary containing arbitrary data (can be SObjects, but not necessarily!).
#		}
#

@export var data = {}
@export_multiline var source_code = ""

# Returns an entry from content
func get_entry(entry):
	return data[entry]
