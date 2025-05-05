extends ColorRect

@export var settlement_ui:Control
@export var background:TextureRect;
@export var crowd:TextureRect;
@export_group("colors")
@export_subgroup("darkest")
@export var prop_darkest:Color;
@export var ground_darkest:Color;
@export_subgroup("sunrise")
@export var prop_sunrise:Color;
@export var ground_sunrise:Color;
@export_subgroup("bright")
@export var prop_bright:Color;
@export var ground_bright:Color;
@export_subgroup("brightest")
@export var prop_brightest:Color;
@export var ground_brightest:Color;
@export_subgroup("sunset")
@export var prop_sunset:Color;
@export var ground_sunset:Color;



func color_background(gradual=false, hour=Entities.world_map.current_hour)->void:
	var sky_color:Color = Entities.world_map.get_hour_sky_color();
	
	var time_key:String;
	if hour >= 21 or hour < 3:
		time_key = "darkest"
	elif hour >= 3 and hour < 6:
		time_key = "sunrise";
	elif hour >= 6 and hour < 9:
		time_key = "bright";
	elif hour >= 9 and hour < 15:
		time_key = "brightest"
	elif hour >= 15 and hour < 18:
		time_key = "bright";
	else:
		time_key = "sunset"
		
	var prop_color:Color = self["prop_" + time_key];
	var ground_color:Color = self["ground_" + time_key];
	
	
	
	var prop_dark_color:Color = prop_color.darkened(.5);
	var prop_light_color:Color = prop_color;
	
	var ground_dark_color:Color = ground_color.darkened(.5);
	var ground_light_color:Color = ground_color;
	if not gradual:
		color = sky_color;
		background.material.set_shader_parameter("prop_dark", prop_dark_color)
		background.material.set_shader_parameter("prop_light", prop_light_color)
		
		background.material.set_shader_parameter("ground_dark", ground_dark_color)
		background.material.set_shader_parameter("ground_light", ground_light_color)
	else:
		const fade_duration = .5;
		
		var tween = create_tween();
		tween.tween_property(self, "color", sky_color, fade_duration);
		tween.parallel().tween_property(background, "material:shader_parameter/prop_dark", prop_dark_color, fade_duration) 
		tween.parallel().tween_property(background, "material:shader_parameter/prop_light", prop_light_color, fade_duration) 
	
		tween.parallel().tween_property(background, "material:shader_parameter/ground_dark", ground_dark_color, fade_duration) 
		tween.parallel().tween_property(background, "material:shader_parameter/ground_light", ground_light_color, fade_duration) 



func switch_crowd()->void:
	var current_settlement:Settlement = settlement_ui.current_settlement;
	if crowd.texture == current_settlement.crowd_1:
		crowd.texture = current_settlement.crowd_2;
	else:
		crowd.texture = current_settlement.crowd_1;
