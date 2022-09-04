##CORE class that handles matters related to dialogs and cutscenes.
extends __GameplayCoreBase
class_name DialogCutsceneCore, "res://core/scripts/icons/icon_event_dialogue.svg"

##READ; True if the game is currently in a [b]cutscene[/b].
var is_in_cutscene := false
##Emitted whenever the game enters a [b]cutscene[/b].
signal cutscene_started
##Emitted whenever the game leaves a [b]cutscene[/b].
signal cutscene_finished

##READ; True if the game is currently executing [b]dialog[/b].
var is_in_dialog := false
##Emitted whenever the game leaves a [b]dialog[/b].
signal dialog_requested
##Emitted whenever the game leaves a [b]dialog[/b].
signal dialog_finished

##NODE; The path to the dialog box that will execute any dialog.
@export_node_path var dialog_box_path
##NODE; The dialog box that will execute any dialog.
@onready var _dialog_box: SmartRichTextLabel = get_node(dialog_box_path)

##Executes a [b]dialog[/b] given a [i]StarScript[/i] [b]pool[/b] and a [b]key[/b].
func dialog( pool : StarScript, key : String ) -> void:
	var pd = pool.data
	if pd.data.has(key):
		_dialog_from_SSON(pd.data[key])
	else:
		Shell.print_err("Invalid Dialog Key", "The provided key \""+key+"\" does not exist within the given dialog pool.")

##Executes a [b]dialog[/b] from an object in [i]StarScript[/i] dictionary format.
func _dialog_from_SSON( ssobj ):
	Shell.execute_block( ssobj.content )

##Enters [b]cutscene[/b] mode.
func enter_cutscene():
	is_in_cutscene = true
	cutscene_started.emit()

##Leaves [b]cutscene[/b] mode.
func exit_cutscene():
	is_in_cutscene = false
	cutscene_finished.emit()
