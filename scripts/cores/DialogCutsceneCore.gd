##CORE class that handles matters related to dialogs and cutscenes.
extends __GameplayCoreBase
class_name DialogCutsceneCore
@icon("res://_engine/scripts/icons/icon_core_dc.png")

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

## A reference to the overworld (scene) camera
@export var camera : Camera2D
## A reference to the camera rack
@export var camera_rack : OffsetStackRack2D

## The current zoom level for the scene camera
signal camera_zoom_changed(new_zoom)
var camera_zoom : float = 1.0:
	set(v):
		camera_zoom = v
		camera_zoom_changed.emit(v)
var camera_target : CanvasItem

##NODE; The dialog box that will execute any dialog.
@export var _dialog_box: SmartRichTextLabel

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

################################

func _physics_process(delta):
	if camera_target:
		var off := Vector2.ZERO
		if camera_target is CharacterVessel2D:
			off += camera_target.camera_offset
		camera_rack.set_offset_at(0, camera_target.global_position + off)
