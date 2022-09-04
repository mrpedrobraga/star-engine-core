extends Resource
class_name SpriteSheetPool

#####################################
#
#	Resource class for spritesheet
#	pools that can be used to bulk
#	sprite sheets as one resource.
#	
#####################################

@export var pool : Dictionary

var _tex : AtlasTexture

func get_sheet(sheet_name:StringName) -> SpriteSheet:
	return pool[sheet_name] as SpriteSheet

func get_frame(sheet_name:StringName, frame_coords:Vector2=Vector2(0, 0)) -> AtlasTexture:
	var s := (pool[sheet_name] as SpriteSheet)
	_tex.atlas = s.texture
	_tex.region = Rect2(frame_coords * s.frame_size, s.frame_size)
	return _tex
