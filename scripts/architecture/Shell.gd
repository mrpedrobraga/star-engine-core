@tool
extends Node
class_name __Shell, "res://core/scripts/icons/icon_console.svg"

#

# The environment variables for the shell.
@export var ENV := {}

var input : TextEdit
var output : RichTextLabel

##NODE; The dialog box this shell writes to.
@onready var dialog_box : SmartRichTextLabel

signal command_finished
signal sequence_finished

##Executes a block of commands in StarScript dictionary format.
##It does accept a string, which will be parsed by StarScriptParser.
func execute_block(commands):
	if commands is String:
		commands = StarScriptParser.parse(commands).content
	for command in commands:
		execute(command)
		await command_finished
	sequence_finished.emit()

##TODO: Change this class to a generic class!
# it will have an overridable execute function.
#
#func execute(command):
#	await get_tree().process_frame

##Executes a single command in StarScript dictionary format.
func execute(command):
	match command.key:
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
		"clear", "cls":
			output.text = ""
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
		# Save the game's state into a file
		"save":
			printx("(<<) File Saved to " + command.params + ".sav !")
			Game.Data.save_game(command.params)
		# Load the game's state from a file
		"load":
			printx("(>>) File Loaded from " + command.params + ".sav !")
			Game.Data.load_game(command.params)
		# Say something using the dialog box
		"say":
			dialog_box.write(command.params)
			if input: input.release_focus()
		# Say something as the narrator
		"*":
			dialog_box.write("* " + command.params)
			if input: input.release_focus()
			await dialog_box.completed
		# Say something as a character
		"-":
			if not command.has("content"):
				printx("Invalid Dialog!")
				return
			dialog_box.write("- " + command.content)
			if input: input.release_focus()
			await dialog_box.completed
		# Item management
		"item":
			var params := StarScriptParser.split_params(command.params)
			var to_whom: String = params[0]
			var what : String = params[1]
			var how_much : int = (params[2]).to_int()
			
			printx("[Shell] Giving %dx %s to %s" % [how_much, what, to_whom])
		"bgm":
			var params := StarScriptParser.split_params(command.params)
			
			match params.pop_front():
				"resume":
					printx("[Shell] Resuming music!")
					Game.Audio.bgm_resume()
				"pause":
					Game.Audio.bgm_pause()
				"load":
					if params.size() < 0:
						print_err("SyntaxError", "Missing the music name to load from!")
					else:
						Game.Audio.bgm_load_from_bank(params.pop_front())
		"sfx":
			pass
		"vfx":
			pass
		"exit":
			get_tree().quit()
		_:
			print_err("Invalid Command Error", "The command '"+command.key+"' is not recognized by this shell.", {suggestion="Check the orthography."})
	
	await get_tree().process_frame
	command_finished.emit()

##Special print function that encapsulates special behaviour.
##Supports BBCode.
func printx(message, _options={}):
	output.text += message + "\n"
	print_rich(message)

##Prints an error to the (real and in-game) consoles.
##You can also pass options, such as 'suggestion'.
func print_err(error, message, options={}):
	var text = "[color=red][b](!) "+error+":[/b] "+message
	if options.has("suggestion"):
		text += '\n[center]' + options.suggestion + '[/center]'
	text += "[color=white]"
	
	output.text += text + "\n"
	print_rich(text)
