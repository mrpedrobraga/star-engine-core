@tool
extends TextureRect
class_name SubViewportRect

## Renders all the children through a [SubViewport].

func _ready():
	if Engine.is_editor_hint():
		return
	setup()

func setup():
	var children := get_children().duplicate()
	var viewport := SubViewport.new()
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	viewport.transparent_bg = true
	viewport.size = size
	add_child(viewport, false, Node.INTERNAL_MODE_BACK)
	for child in children:
		remove_child(child)
		viewport.add_child(child)
	texture = viewport.get_texture()

func _draw():
	if Engine.is_editor_hint():
		draw_rect(Rect2(Vector2(), get_size()), Color.GOLDENROD, false, -1.0)
