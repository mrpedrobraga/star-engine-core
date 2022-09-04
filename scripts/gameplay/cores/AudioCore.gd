extends __GameplayCoreBase
class_name AudioCore, "res://core/scripts/icons/icon_music.svg"

@onready var bgm_player : AudioStreamPlayer = $BGM
@onready var battle_player : AudioStreamPlayer = $BattlePlayer

@onready var sfx_battle_start : AudioStreamPlayer = $SFX_Battle_Start

func bgm_pause():
	bgm_player.stream_paused = true

func bgm_load_from_bank(bgm:String) -> void:
	Shell.printx("[Game::AudioCore] Loading BGM from MUS/" + str(bgm))
	bgm_player.stream = Game.Data.get_resource("MUS/" + bgm)

func bgm_resume() -> void:
	if not bgm_player.playing:
		bgm_player.play()
	bgm_player.stream_paused = false

func battle_music_play() -> void:
	battle_player.play()

func battle_music_stop() -> void:
	battle_player.stop()

func battle_start() -> void:
	sfx_battle_start.play()
