shader_type canvas_item;

uniform bool night_light=false;
uniform vec3 reflection_color: source_color;

void fragment() {
	if(night_light){
		if (COLOR.rgb == vec3(1.0, 0.0, 0.0)){
			COLOR.rgb = reflection_color;
		}
	}

}
