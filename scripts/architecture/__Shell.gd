@tool
extends Node
class_name __Shell
@icon("res://core/scripts/icons/icon_console.svg")

## A helper class that handles quick commands for convenience.
##
## This class can be extended for any game that uses the engine,
## and with it you can interpret commands to do whatever you want
## as you make it a singleton named "Shell".
##
## The commands you send to the shell are written in [StarScript].

# The environment variables for the shell.
@export var ENV := {}

## Emitted when a single command is finished
signal command_finished
## Emitted when all the commands queried in an [member execute_block] is finished.
signal sequence_finished

##Executes a block of commands in [StarScript] dictionary format.
##It does accept a string, which will be parsed by [StarScriptParser].
func execute_block(commands):
	if commands is String:
		commands = StarScriptParser.parse(commands).content
	for command in commands:
		execute(command)
		await command_finished
	sequence_finished.emit()

## Executes a single command in [StarScript] dictionary format.[br][br]
## It should be overriden. Unsure of how a command works?
## Just print it!
func execute(command):
	await get_tree().process_frame
