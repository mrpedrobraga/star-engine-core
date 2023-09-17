@tool
extends StarScriptShell
class_name ComponentShell

## Class that acts like a shell but acts on a specific instance of an object.
##
## It allows its executing code to be hotswapped;
## This can be used to do things such as cutscenes.

var step_block : StarScriptBlock
var step_block_context : Dictionary
var step_block_i_index : int

signal advance(exit : bool)

## Executes a whole code block but can be stopped.
func set_stepped_block(block : StarScriptBlock, parent_context : Dictionary):
	# Quit the current execution if it's running;
	advance.emit(true)
	
	var context := _create_subcontext(parent_context)
	step_block = block
	step_block_context = context
	step_block_i_index = 0
	var result
	
	# Pass in the block through the context.
	context.block = step_block
	
	while step_block_i_index < block.commands.size():
		step()
		
		var should_quit = await advance
		if should_quit:
			break
	
	# Free
	context.erase("local_variables") # Free locals.
	
	# Return
	return result

func step():
	step_block_context.i_index = step_block_i_index
	x_command(step_block.commands[step_block_i_index], step_block_context)
	step_block_context.erase("ephemerals")
	step_block_i_index += 1

## Executes a single [StarScriptCommand].
func x_command(command : StarScriptCommand, context : Dictionary):
	if not commands.has(command.key):
		push_error("Command '%s' not found: %s" % [command.key, command])
		return null
	
	var command_handler : Dictionary = commands[command.key]
	
	var match_ := match_syntax(command.params, command_handler)
	
	if match_.valid:
		await get_tree().process_frame
		var result = await command_handler[&"handler"].call(
			self,				# StarScriptShell
			command,			# The executed command (has params and all inside)
			context				# StarScriptExecutionContext
		)
		advance.emit(false)
		return result
	
	push_warning("Command invalid, skipping.")
