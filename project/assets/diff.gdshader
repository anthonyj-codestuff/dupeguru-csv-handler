shader_type canvas_item;

uniform sampler2D textureB;
uniform float delta = 0.1;
uniform bool active = true;

void fragment() {
	if(active) {
	    vec4 colorA = texture(TEXTURE, UV);
	    vec4 colorB = texture(textureB, UV);
	    
	    float difference = length(colorA - colorB);
	    if (difference <= delta) {
	        // Pixels are similar, darken the color to de-emphasize it
	        COLOR.rgb = COLOR.rgb/5.0;
	    }
	}
}