shader_type canvas_item;

uniform sampler2D textureB;
uniform float delta = 0.1;
uniform bool active = true;

float scaleNumber(float number){
	return pow(255.0*(number/255.0), 0.5);
}

void fragment() {
	if(active) {
	    vec4 colorA = texture(TEXTURE, UV);
	    vec4 colorB = texture(textureB, UV);
	    
	    float difference = length(colorA - colorB);
	    if (difference <= delta) {
	        // Pixels are similar, darken the color to de-emphasize it
	        COLOR.rgb = COLOR.rgb/5.0;
	    } else if (COLOR.r < 0.25 && COLOR.g < 0.25 && COLOR.b < 0.25) {
			// Diff is close to black, scale them up so that dark pixels are easier to notice
			COLOR.rbg = vec3(scaleNumber(COLOR.r), scaleNumber(COLOR.g), scaleNumber(COLOR.b));
		}
	}
}