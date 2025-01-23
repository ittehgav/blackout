shader_type canvas_item;

uniform vec4 target_color :source_color;
uniform float grad:hint_range(0.0, 1.0);


void fragment(){
	if(grad != 0.0 && COLOR.a != 0.0){
		COLOR = mix(COLOR, target_color, grad);
	}
}