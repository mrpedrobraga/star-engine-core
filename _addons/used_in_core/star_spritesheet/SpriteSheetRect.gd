
@tool
extends TextureRect
class_name SpriteSheetRect

@export var sprite_sheet_pool : Resource:
	set(v):
		sprite_sheet_pool = v
		update_texture()
@export var current_sheet : String:
	set(v):
		current_sheet = v
		update_texture()
@export var current_frame_coords : Vector2 = Vector2(0,0):
	set(v):
		current_frame_coords = v
		frame_coords = current_frame_coords
		update_region()

var frame_coords := Vector2.ZERO
var hframes := 1
var vframes := 1

func _ready():
	texture = AtlasTexture.new()
	update_texture()

func update_texture():
	if sprite_sheet_pool == null:
		return
		
	var p : SpriteSheetPool = sprite_sheet_pool
	if not p.pool.keys().has(current_sheet):
		return
	
	if not p.pool[current_sheet] is SpriteSheet:
		Shell.print_err("ResourceTypeMismatch", "One of " + str(name) + "'s entries on its pool isn't of type SpriteSheet!")
		
	var sh := p.pool[current_sheet] as SpriteSheet
	texture.atlas = sh.texture
	hframes = texture.get_width()  / sh.frame_size.x
	vframes = texture.get_height() / sh.frame_size.y
	update_region()

func update_region():
	var p : SpriteSheetPool = sprite_sheet_pool
	var sh := p.pool[current_sheet] as SpriteSheet
	var t : AtlasTexture = texture
	
	t.atlas = sh.texture
	t.region = Rect2(current_frame_coords * sh.frame_size, sh.frame_size)
