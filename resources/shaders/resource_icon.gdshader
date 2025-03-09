shader_type canvas_item;

uniform vec4 base_color:source_color;

uniform vec4 shadow_color:source_color;
uniform vec4 light_color:source_color;


void fragment() {
		if (COLOR == light_color){
			COLOR = base_color;
		}else if (COLOR == shadow_color){
			COLOR.rgb = base_color.rgb * .25;
		}
		
	
}
