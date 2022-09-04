#########################################
#										#
#		Gameplay Core Base 1.0.0		#
#			by Pedro Braga				#
#										#
#	Abstract class to be inherited  	#
#	by gameplay cores.					#
#										#
#########################################

extends Node
class_name __GameplayCoreBase

var identifier = ""

# Cores are self contained objects that can be called upon to do things.
# Cores can call each other, but should be safe if other cores are offline.
