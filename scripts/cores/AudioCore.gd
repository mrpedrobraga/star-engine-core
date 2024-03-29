@icon("res://_engine/scripts/icons/icon_core_audio.png")
extends __GameplayCoreBase
class_name AudioCore

## CORE class that handles audio.
##
## Assign this class to the 'Game' singleton for you to use it in the game.
## See: [GameInstance].[br][br]
##
## TODO : Make this load the audio files slowly
## in a background thread by default,
## then quickly load when [member bgm_resume] is called.[br][br]
##
## TODO : Add BGM stacking support.

@export var bgm_player : AudioStreamPlayer
var _bgm_back_buffer : AudioStream
var _bgm_stack : Array[AudioStream]

@export var battle_player : AudioStreamPlayer

@onready var sfx_battle_start : AudioStreamPlayer = $SFX_Battle_Start

func one_shot(stream : AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SoundFX"
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
	return player

func bgm_pause():
	bgm_player.stream_paused = true

func bgm_load_from_bank(bgm:String) -> void:
	Shell.r_print("[Game::AudioCore] Loading BGM from MUS/" + str(bgm))
	var r = Game.Data.get_resource("MUS/" + bgm)
	if (r is int) and r == ERR_DOES_NOT_EXIST:
		Shell.print_err("NullReference", "Audio Resource Does Not Exist: " + str(bgm))
		return
	_bgm_back_buffer = r

func bgm_preload_from_bank(bgm:String) -> void:
	Shell.r_print("[Game::AudioCore] Preloading BGM from MUS/" + str(bgm))
	Game.Data.preload_resource("MUS/" + bgm)

func bgm_resume(restart = false) -> void:
	bgm_player.stream = _bgm_back_buffer
	if restart or not bgm_player.playing:
		bgm_player.play()
	bgm_player.stream_paused = false

func battle_music_play() -> void:
	battle_player.play()

func battle_music_set(mus : AudioStream) -> void:
	battle_player.stream = mus

func battle_music_stop() -> void:
	battle_player.stop()

func battle_start() -> void:
	sfx_battle_start.play()
