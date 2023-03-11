##Simple class that draws a growing pulse that visualizes how RadarAnchors are activated.
##
##Note that this class has merely a visual effect, and does not truly collide with [SightlessRadarAnchor],
##the anchor's behaviour is completely independent from this object.
@tool
extends Node2D
class_name SightlessRadarPulse

const color = Color("#46b6f7")

enum {
	GROWTH_RADIUS = 128 ##How fast the pulse's radius grows, in px/s.
}

func _process(delta):
	queue_redraw()
	
	var max_radius = 128.
	if radius < max_radius:
		radius += GROWTH_RADIUS * delta
		modulate.a = 1. - radius / max_radius
	else:
		queue_free()

##The initial radius of the pulse (it's a circle!).
@export_range(0, 256) var radius = 1.0

func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, color, 1)
