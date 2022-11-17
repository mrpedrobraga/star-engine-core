extends __GameplayCoreBase
class_name AudioCore
@icon("res://_engine/scripts/icons/icon_music.svg")

## CORE class that handles audio.
##
## Assign this class to the 'Game' singleton for you to use it in the game.
## See: [GameInstance].
##
## TODO : Make this load the audio files slowly
## in a background thread by default,
##
## then quickly load when [member bgm_resume] is called.

@onready var bgm_player : AudioStreamPlayer = $BGM
var _bgm_back_buffer : AudioStream

@onready var battle_player : AudioStreamPlayer = $BattlePlayer

@onready var sfx_battle_start : AudioStreamPlayer = $SFX_Battle_Start

func bgm_pause():
	bgm_player.stream_paused = true

func bgm_load_from_bank(bgm:String) -> void:
	Shell.printx("[Game::AudioCore] Loading BGM from MUS/" + str(bgm))
	var r = Game.Data.get_resource("MUS/" + bgm)
	if (r is int) and r == ERR_DOES_NOT_EXIST:
		Shell.print_err("NullReference", "Audio Resource Does Not Exist: " + str(bgm))
		return
	_bgm_back_buffer = r

func bgm_preload_from_bank(bgm:String) -> void:
	Shell.printx("[Game::AudioCore] Preloading BGM from MUS/" + str(bgm))
	Game.Data.preload_resource("MUS/" + bgm)


func bgm_resume(restart = false) -> void:
	bgm_player.stream = _bgm_back_buffer
	if restart or not bgm_player.playing:
		bgm_player.play()
	bgm_player.stream_paused = false

func battle_music_play() -> void:
	battle_player.play()

func battle_music_stop() -> void:
	battle_player.stop()

func battle_start() -> void:
	sfx_battle_start.play()
