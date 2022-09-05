##Accessibility class that handles emission of RadarPulses for localizing RadarAnchors on your map.
##It should be used for sightless playing.
extends Node2D
class_name SightlessRadarPulseEmitter

@export var action : StringName = "sightless_pulse_radar_emit"

func _input(event):
	if Input.is_action_just_pressed(action):
		var ear = get_viewport().get_camera_2d().global_position - global_position
		var p = SightlessRadarPulse.new()
		add_child(p)
		p.global_position = get_viewport().get_camera_2d().global_position
