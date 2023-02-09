##An implementation of Sprite2D that takes a SpriteSheetPool as a source and draws a frame from one of its spritesheets.
@tool
extends Sprite2D
class_name SpriteSheetSprite2D

##The SpriteSheetPool resource.[br/][br/]
##
##It contains several named sprite sheets.
##This is done for convenience, you can use your own
##naming convention for your sheets and quickly swap
##different characters by swapping the pool.
@export var sprite_sheet_pool : SpriteSheetPool:
	set(v):
		sprite_sheet_pool = v
		update_texture()
##The name of the current used sheet.
@export var current_sheet : String:
	set(v):
		current_sheet = v
		update_texture()
##The current coordinates to draw from from the active spritesheet.
@export var current_frame_coords : Vector2 = Vector2(0,0):
	set(v):
		current_frame_coords = v
		frame_coords = clamp(current_frame_coords, Vector2.ZERO, Vector2(hframes-1, vframes-1))

##Updates the texture (re-gathers it from the sprite sheet pool).
func update_texture():
	if sprite_sheet_pool == null:
		return
	var p : SpriteSheetPool = sprite_sheet_pool
	if not p.pool.keys().has(current_sheet):
		return
	var sh := p.pool[current_sheet] as SpriteSheet
	
	texture = sh.texture
	hframes = texture.get_width()  / sh.frame_size.x
	vframes = texture.get_height() / sh.frame_size.y
