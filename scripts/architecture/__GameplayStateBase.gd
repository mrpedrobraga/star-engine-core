#########################################
#										#
#		Gameplay State Base 1.0.0		#
#			by Pedro Braga				#
#										#
#	Abstract class to be inherited  	#
#	by gameplay states.					#
#										#
#########################################

extends Node
class_name __GameplayStateBase

var state_handler = Game

func _enter():
	pass

func _update():
	pass

func _exit():
	pass

#
#	DIAGRAM OF FINITE STATE MACHINES (Nice ASCII art)
#
#      ┌──────────────────────┐
#      │                      │
#      │ State 1              ├─────┐
#      │                      │     │
#      │  (Handles some cool  │   ┌─▼─────────────────────┐
#      │   gameplay things.)  │   │   State 2             │
#      │                      │   │                       │
#      │  Goto: State 2       │   │                       │
#      │                      ◄───┤  Does some more stuff │
#      └──────────────────────┘   │  and then goes to     │
#                                 │  State 1              │
#           ┌─────────────────┐   │                       │
#           │  State 3        │   │                       │
#           │                 │   └───────────▲───────────┘
#           │  Prints "Bob"   │               │
#           │  Goto State 2   ├───────────────┘
#           └─────────────────┘                       mHβr
