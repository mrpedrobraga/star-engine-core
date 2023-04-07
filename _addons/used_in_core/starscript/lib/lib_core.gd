extends StarScriptLibrary

static func _install(shell : StarScriptShell):
	shell.register_command ( "print ...",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			var msg = await shell._eval_if_expr(command.params[0], context)
			shell.r_print(str(msg))
			return str(msg)
	)
	
	shell.register_command ( "wait <amt:number>",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			await float(command.params[0])
	)
	
	shell.register_command ( "eval ...",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			#shell.r_print(str(command.params[0]))
			return command.params[0]
	)
	
	shell.register_command ( "dialog ...",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			shell.r_print("Dialog by %s : %s" % [command.params[2], command.params[0]])
	)
	
	shell.register_command ( "cmp <a:number> <b:number>",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			var a = float(command.params[0])
			var b = float(command.params[1])
			
			if a > b:
				shell.r_print('GREATER')
				return 1
			elif a < b:
				shell.r_print('LESSER')
				return -1
			else:
				shell.r_print('EQUAL')
				return 0
	)
	
	shell.register_command ( "get <variable:string>",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			return shell._get_variable(command.params[0], context)
	)
	
	shell.register_command ( "expr <expr>",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			return command.params[0]
	)
	
	shell.register_command ( "set <variable:string> <mode:string> <value>",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			match command.params[1]:
				"=":
					return shell._set_variable(
						command.params[0],
						command.params[2],
						context
					)
				"+=":
					return shell._set_variable(
						command.params[0],
						shell._get_variable(command.params[0], context) + command.params[2],
						context
					)
				"-=":
					return shell._set_variable(
						command.params[0],
						shell._get_variable(command.params[0], context) - command.params[2],
						context
					)
				"*=":
					return shell._set_variable(
						command.params[0],
						shell._get_variable(command.params[0], context) * command.params[2],
						context
					)
				"^=":
					return shell._set_variable(
						command.params[0],
						pow(shell._get_variable(command.params[0], context), command.params[2]),
						context
					)
				"/=":
					return shell._set_variable(
						command.params[0],
						shell._get_variable(command.params[0], context) / command.params[2],
						context
					)
				"//=":
					return shell._set_variable(
						command.params[0],
						floor(shell._get_variable(command.params[0], context) / command.params[2]),
						context
					)
				"%=":
					return shell._set_variable(
						command.params[0],
						fposmod(shell._get_variable(command.params[0], context), command.params[2]),
						context
					)
	)
	
	shell.register_command ( "if ...",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			var condition = await shell._eval_if_expr(command.main_param, context)
			if condition:
				return await shell.x_block(command, context)
			return null
	)
	
	shell.register_command ( "unless ...",
		func (shell : StarScriptShell, command : StarScriptCommand, context):
			var condition = await shell._eval_if_expr(command.main_param, context)
			if not condition:
				return await shell.x_block(command, context)
			return null
	)
