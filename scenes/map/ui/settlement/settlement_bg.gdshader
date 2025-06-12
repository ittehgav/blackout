shader_type canvas_item;

uniform vec4 prop_light:source_color;
uniform vec4 prop_dark:source_color;
uniform vec4 ground_light:source_color;
uniform vec4 ground_dark:source_color;

void fragment() {
	if (COLOR.a>0.0){
		if (COLOR.rgb == vec3(1, 1, 0)){
			COLOR = prop_light;
		}else if (COLOR.rgb == vec3(1, 0, 0)){
			COLOR = prop_dark;
		}else if (COLOR.rgb == vec3(0, 0, 1)){
			COLOR = ground_dark;
		}else if(COLOR.rgb == vec3(0, 1, 0)){
			COLOR = ground_light;
		}
	}

}