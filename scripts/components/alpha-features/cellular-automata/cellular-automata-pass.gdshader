shader_type canvas_item;

/*
	CELL FORMAT
	
	x -> Horizontal Velocity
	y -> Vertical Velocity
	g -> (/)
	a -> Intensity
*/

void fragment () {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	vec4 col = texture(TEXTURE, UV);
	
	col = texture(TEXTURE, UV + vec2(- UV.x * ps.x, -ps.y));
	
	COLOR = col;
}