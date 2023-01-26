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
	
	float neighbour_count = 0.0;
	
	neighbour_count += texture(TEXTURE, UV + vec2(0, ps.y)).a;
	neighbour_count += texture(TEXTURE, UV + vec2(0, -ps.y)).a;
	neighbour_count += texture(TEXTURE, UV + vec2(ps.x, 0)).a;
	neighbour_count += texture(TEXTURE, UV + vec2(-ps.x, 0)).a;
	neighbour_count += texture(TEXTURE, UV + vec2(ps.x, ps.y)).a;
	neighbour_count += texture(TEXTURE, UV + vec2(ps.x, -ps.y)).a;
	neighbour_count += texture(TEXTURE, UV + vec2(-ps.x, ps.y)).a;
	neighbour_count += texture(TEXTURE, UV + vec2(-ps.x, -ps.y)).a;
	
	if (col.a > 0.0) {
		if (neighbour_count < 2.0 || neighbour_count > 3.0)
			col = vec4(0.0);
	} else {
		if (neighbour_count > 2.9 && neighbour_count < 3.1)
			col = vec4(1.0);
	}
	
	COLOR = col;
}