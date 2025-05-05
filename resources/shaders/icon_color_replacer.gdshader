shader_type canvas_item;

uniform vec3 base_color:source_color;

uniform vec3 shadow_color:source_color = vec3(0, 0, 1);
uniform vec3 mid_color:source_color = vec3(1, 0, 0);
uniform vec3 light_color: source_color = vec3(0, 1, 0);

uniform float shadow_value:hint_range(0.0, 2.0)=.25;
uniform float light_value:hint_range(0.0, 2.0)=1.75;
uniform float neutral_value:hint_range(0.0, 2.0)=1.0;



void fragment() {
		if (COLOR.rgb == mid_color){
			COLOR.rgb = base_color.rgb * neutral_value;
		}else if (COLOR.rgb == shadow_color){
			COLOR.rgb = base_color.rgb * shadow_value;
		}else if (COLOR.rgb == light_color){
			COLOR.rgb = base_color.rgb * light_value;
		}
}
