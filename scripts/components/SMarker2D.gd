@tool
extends Marker2D
class_name SMarker2D

@export_category("Marker")

const base_texture : Texture2D = preload("res://_engine/scripts/icons/icon_marker_base.res")
const balloon_texture : Texture2D = preload("res://_engine/scripts/icons/icon_marker_balloon.png")
@export_range(0, 64) var balloon_offset : int = 8:
	set(v):
		balloon_offset = v
		queue_redraw()
@export var icon : Texture2D:
	set(v):
		icon = v
		queue_redraw()

func _ready():
	if not is_in_group(&"S_Markers"):
		add_to_group(&"S_Markers", true)
	
	if not Engine.is_editor_hint():
		return

func _draw():
	draw_set_transform(Vector2(), 0, Vector2.ONE * 6)
	draw_texture(base_texture, Vector2(-12, -20))
	draw_texture(balloon_texture, Vector2(-6, -13 - balloon_offset))
	if icon:
		draw_texture(icon, Vector2(0-5, -7-5 - balloon_offset))
