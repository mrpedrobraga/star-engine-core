@icon("res://_engine/scripts/icons/icon_core_dc.png")
extends __GameplayCoreBase
class_name DialogCutsceneCore

##CORE class that handles matters related to dialogs and cutscenes.
##
## Assign this class to the 'Game' singleton for you to use it in the game.
## See: [GameInstance].[br][br]
##

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
var camera_zoom : float = 1.0:
	set(v):
		camera_zoom = v
		camera_zoom_changed.emit(v)
## The current zoom level for the scene camera
signal camera_zoom_changed(new_zoom)
## The node this camera is followng
var camera_target : CanvasItem
var is_camera_following_target : bool = true

func set_camera_following_target(following : bool):
	is_camera_following_target = following

func set_camera_to(to : Vector2):
	camera_rack.set_offset_at(0, to)

func slide_camera_to(to : Vector2, duration : float):
	var t := create_tween()
	t.tween_method((func (v): camera_rack.set_offset_at(0, v)), camera_rack.get_offset_at(0), to, duration).\
		set_ease(Tween.EASE_IN_OUT).\
		set_trans(Tween.TRANS_QUAD)
	await t.finished

func slide_camera_to_target(duration : float):
	var tp = camera_target.position
	if camera_target is CharacterVessel2D:
		tp += camera_target.camera_offset
	await slide_camera_to(tp, duration)
	set_camera_following_target(true)

##NODE; The dialog box that will execute any dialog.
@warning_ignore("unused_private_class_variable")
@export var _dialog_box: SmartRichTextLabel

##Executes a [b]dialog[/b] given a [i]StarScript[/i] [b]pool[/b] and a [b]key[/b].
func dialog( pool : StarScript, key : String ) -> void:
	start_dialog_session()
	var pd = pool.sections
	if pd.has(key):
		await Shell.x_section(pd[key])
	else:
		Shell.r_err("Invalid Dialog Key", "The provided key \""+key+"\" does not exist within the given dialog pool.")
	end_dialog_session()

##Enters [b]cutscene[/b] mode.
func enter_cutscene():
	is_in_cutscene = true
	cutscene_started.emit()

##Leaves [b]cutscene[/b] mode.
func exit_cutscene():
	is_in_cutscene = false
	cutscene_finished.emit()

##Enters [b]dialog session[/b] mode.
func start_dialog_session():
	if not is_in_dialog:
		is_in_dialog = true
		dialog_requested.emit()

##Leaves [b]dialog session[/b] mode.
func end_dialog_session():
	if is_in_dialog:
		is_in_dialog = false
		_dialog_box.end_session()
		dialog_finished.emit()

################################
func _ready():
	camera_zoom_changed.connect((func(new_zoom):
		camera.zoom = Vector2(new_zoom, new_zoom)
	))

func _physics_process(delta):
	if Game.get_state() == &"Overworld":
		camera_focus_on_target()

func camera_focus_on_target():
	if is_camera_following_target and camera_target:
		var off := Vector2.ZERO
		if camera_target is CharacterVessel2D:
			off += camera_target.camera_offset
		if not camera_target.is_inside_tree():
			camera_rack.set_offset_at(0, Vector2() + off)
			return
		camera_rack.set_offset_at(0, camera_target.global_position + off)
