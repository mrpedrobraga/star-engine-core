##Node that plays a sound (and visually pops) whenever a pulse is felt!
extends AudioStreamPlayer2D

@export var action : StringName = "sightless_pulse_radar_emit"

func _input(ev):
	if Input.is_action_just_pressed(action):
		
		var ear = get_viewport().get_camera_2d().global_position - global_position
		
		pitch_scale = (exp(ear.y/2048.0))
		await get_tree().create_timer(ear.length() / 512.0).timeout
		
		pop()
		play()

func pop ():
	$AnimationPlayer.play("pop")
