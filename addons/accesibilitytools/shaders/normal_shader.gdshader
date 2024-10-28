shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
render_mode unshaded;
uniform int type : hint_range(0, 4, 1) = 0;

vec3 rgbtosrgb(vec3 c) {
	c.r = c.r <= 0.04045 ? c.r / 12.92 : pow((c.r + 0.055) / 1.055, 2.4);
	c.g = c.g <= 0.04045 ? c.g / 12.92 : pow((c.g + 0.055) / 1.055, 2.4);
	c.b = c.b <= 0.04045 ? c.b / 12.92 : pow((c.b + 0.055) / 1.055, 2.4);
	return c;
}

vec3 srgbtorgb(vec3 c) {
	c.r = c.r <= 0.0031308 ? c.r * 12.92 : (pow(1.055 * c.r, 0.41666) - 0.055);
	c.g = c.g <= 0.0031308 ? c.g * 12.92 : (pow(1.055 * c.g, 0.41666) - 0.055);
	c.b = c.b <= 0.0031308 ? c.b * 12.92 : (pow(1.055 * c.b, 0.41666) - 0.055);
	return c;
}

vec3 srgbtolms(vec3 c) {
	mat3 m = mat3(
		vec3(0.31399022, 0.15537241, 0.01775239),
		vec3(0.63951294, 0.75789446, 0.10944209),
		vec3(0.04649755, 0.08670142, 0.87256922)
	);
	return m * c;
}

vec3 lmstosrgb(vec3 c) {
	mat3 m = mat3(
		vec3( 5.47221206, -1.1252419,   0.02980165),
		vec3(-4.6419601,   2.29317094, -0.19318073),
		vec3( 0.16963708, -0.1678952,   1.16364789)
	);
	return m * c;
}

void fragment() {
	vec3 originalColor = textureLod(screen_texture, SCREEN_UV,0.0).rgb;
	originalColor = rgbtosrgb(originalColor);
	originalColor = srgbtolms(originalColor);
	vec3 outputColor = originalColor;
	outputColor = lmstosrgb(outputColor);
	outputColor = srgbtorgb(outputColor);
	COLOR.rgb = outputColor;
}
 
