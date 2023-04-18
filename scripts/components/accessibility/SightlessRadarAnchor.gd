##Marker that plays a sound (and visually pops) whenever a pulse is emitted by [SightlessRadarPulseEmitter]!
##
##Note that this class does not check for actual collisions with [SightlessRadarPulse],
##instead, it merely synchronizes itself calculating the delay.
extends AudioStreamPlayer2D
class_name SightlessRadarAnchor

##The action this 
@export var action : StringName = "sightless_pulse_radar_emit"

func _ready():
	$Sprite2D.modulate.a = 0

func _input(ev):
	if Input.is_action_just_pressed(action):
		
		var ear = to_local(get_viewport().get_camera_2d().global_position)
		
		pitch_scale = (exp(ear.y/512.0))
		await get_tree().create_timer(ear.length() / SightlessRadarPulse.GROWTH_RADIUS).timeout
		
		pop()
		play()

func pop ():
	$AnimationPlayer.play("pop")
