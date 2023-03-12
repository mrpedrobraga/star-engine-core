@tool
extends Node
class_name __Shell

## A helper class that handles quick commands for convenience.
##
## This class will soon be replaced when StarScript 2.0 releases.[br][br]
##
## This class can be extended for any game that uses the engine,
## and with it you can interpret commands to do whatever you want
## as you make it a singleton named "Shell".[br][br]
##
## The commands you send to the shell are written in [StarScript].[br][br]

# The environment variables for the shell.
@export var ENV := {}

## Emitted when a single command is finished
signal command_finished
## Emitted when all the commands queried in an [member execute_block] is finished.
signal sequence_finished

var current_line : Array[int] = []

##Executes a block of commands in [StarScript] dictionary format.
##It does accept a string, which will be parsed by [StarScriptParser].
func execute_block(commands):
	if current_line.size() >= 1: return
	
	if commands is String:
		commands = StarScriptParser.parse(commands).content
	if commands is Array:
		current_line.append(0)
		while current_line[-1] < commands.size():
			execute(commands[current_line[-1]])
			await command_finished
			current_line[-1] += 1
	sequence_finished.emit()
	current_line.pop_back()

## The return value of the last command.
var return_value = null
## The status of the last execute call.
var status = ERR_METHOD_NOT_FOUND

## Executes a single command in [StarScript] dictionary format.[br][br]
## It should be overriden. Unsure of how a command works?
## Just print it!
##
## To extend 'executing' in subclasses, do as follows:
##[codeblock]
##func _execute(command):
##  status = OK
##  match command.key:
##    [...]
##    _:
##      status = ERR_METHOD_NOT_FOUND
##      super(command)
##  await get_tree().process_frame
##  if status == OK:
##    command_finished.emit()[/codeblock]
func execute(command):
	await _execute(command)

func _execute(command):
	status = OK
	
	match command.key:
		"*":
			printx("* " + command.params)
			#speak(to_valid_speech(command.params))
			# Say something as a character
		"-":
			if not command.has("message"):
				printx("Invalid Dialog!")
				return
			printx("- " + command.message)
			speak(to_valid_speech(command.content))
		## Waits for a set amount of seconds.
		"wait":
			if command.params.is_valid_float():
				print('Waiting for ', command.params, ' seconds.')
				await get_tree().create_timer((command.params).to_float()).timeout
		# The print command prints the parameters to the output.
		"print":
			if command.params == null:
				print_err("SyntaxError", "No arguments supplied for 'print'.", {suggestion="Try writing something after 'print' so there is something to be printed."})
				return
			if command.has("data"):
				printx(command.params, command.data)
			else:
				printx(command.params)
			return_value = command.params
		"error":
			if command.has("data"):
				var type = "Error"
				var sugg = "Try something"
				if command.data.has("type"):
					type = command.data.type
				if command.data.has("suggestion"):
					type = command.data.suggestion
				print_err(type, command.params, {suggestion=sugg})
			else:
				print_err("Error", command.params, {suggestion="Try something else"})
		"sh":
			var params := StarScriptParser.split_params(command.params)
			var path = params.pop_front()
			var o := []
			var error := OS.execute(path, params, o)
			var output_message := ""
			
			for i in range(o.size()):
				output_message += o[i]
				if not i == o.size() - 1:
					output_message += "\n"
			
			if error:
				print_err("Shell Error", str(output_message))
			else:
				printx(str(output_message))
		"call":
			printx(command.params)
		"true":
			return_value = true
		"false":
			return_value = false
		"expr":
			var e = Expression.new()
			e.parse(command.params)
			return_value = e.execute()
			print(return_value)
		"if":
			var cond = make_command(command.params)
			
			await execute(cond)
			if return_value:
				execute_block(command.content)
		"unless":
			var params := StarScriptParser.split_params(command.params)
			var cond = {"key":params.pop_front(), "params":""}
			for i in params.size():
				if i > 0:
					cond.params += " "
				cond.params += params[i]
			
			await execute(cond)
			if return_value:
				pass
			else:
				execute_block(command.content)
		
		_:
			status = ERR_METHOD_NOT_FOUND
			print_err("Invalid Command Error", "The command '"+command.key+"' is not recognized by this shell.", {suggestion="Check the orthography."})
	
	await get_tree().process_frame
	if status == OK:
		command_finished.emit()

##Special print function that encapsulates special behaviour.
##Supports BBCode.
func printx(message, _options={}):
	print_rich(message)

##Speaks a message out loud via TTS
func speak(m : String):
#	OS.execute(
#		"spd-say",
#		[
#			m
#		]
#	)
#	print("[TTS] :: " + m)
	pass

func to_valid_speech(m : String) -> String:
	m = m.trim_prefix("* ")
	m = m.trim_prefix("- ")
	m = m.replace("§", " ")
	
	var r_bb := RegEx.create_from_string("\\[[\\s\\S]*?\\]")
	m = r_bb.sub(m, "", true)
	return m

func make_command(txt : String) -> Dictionary:
	var params := StarScriptParser.split_params(txt)
	var cmd = {"key":params.pop_front(), "params":""}
	for i in params.size():
		if i > 0:
			cmd.params += " "
		cmd.params += params[i]
	return cmd

##Prints an error to the (real and in-game) consoles.
##You can also pass options, such as 'suggestion'.
func print_err(error, message, _options={}):
	var text = "[color=#ff3333][b](!) "+error+":[/b] "+message
	if _options.has("suggestion"):
		text += '\n[center]' + _options.suggestion + '[/center]'
	text += "[color=white]"
	
	print_rich(text)
	return text
