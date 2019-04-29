shader_type canvas_item;

float range_lerp(float value, float start1, float stop1, float start2, float stop2)
{
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
}

void fragment()
{
	vec2 uv = UV;
	COLOR = texture(TEXTURE, uv);
	vec2 center = vec2(0.5,0.5);
//	float threshold = 1.0 + 0.5 * (1.0 - abs(sin(TIME / 10.0)));
	float threshold = 1.0;
	COLOR.a = threshold - range_lerp(distance(uv, center), 0.0, 0.5, 0.0, 1.0);
}

