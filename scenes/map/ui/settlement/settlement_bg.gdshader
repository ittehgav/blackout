shader_type canvas_item;

uniform vec4 prop_reflective:source_color;
uniform vec4 prop_opaque:source_color;
uniform vec4 ground_reflective:source_color;
uniform vec4 ground_opaque:source_color;

void fragment() {
	if (COLOR.a>0.0){
		if (COLOR.rgb == vec3(1, 1, 0)){
			COLOR = prop_reflective;
		}else if (COLOR.rgb == vec3(1, 0, 0)){
			COLOR = prop_opaque;
		}else if (COLOR.rgb == vec3(0, 0, 1)){
			COLOR = ground_opaque;
		}else if(COLOR.rgb == vec3(0, 1, 0)){
			COLOR = ground_reflective;
		}
	}

}