extends StarScriptLibrary

static func _install(shell : StarScriptShell):
	# Triggers a dialog on the target dialog box.
	# Also passes portraits and whatnots.
	shell.register_command ( "dialog ...",
		func lib_starscript_dialog (shell : StarScriptShell, command : StarScriptCommand, context):
			var dbox : SmartRichTextLabel = Game.DC._dialog_box
			await dbox.write(command.params[0])
	)
	
	shell.register_command ( "bgm play|pause|resume|load|stack|pop <name:String>",
		func lib_starscript_dialog (shell : StarScriptShell, command : StarScriptCommand, context):
			var ac : AudioCore = Game.Audio
			
			match command.params[0]:
				"play":
					ac.bgm_load_from_bank(command.params[1])
					ac.bgm_resume(true)
	)
	
	# Calls a method on the current room.
	shell.register_command ( "call <method> ...",
		func lib_starscript_call (shell : StarScriptShell, command : StarScriptCommand, context):
			var scene = Game.current_room
			
			var method : StringName = command.params.pop_front()
			
			if scene.has_method(method):
				scene.call(method, command.params)
			else:
				push_error("Method %s not found on %s." % [method, scene])
	)
