extends Node

## color-coding is applied before fights and replaces the flat RGBs for team-corresponding colors
## all functions of this sort will be in this script
## (unless it ends up becoming massive?)
const fighter_sprite_darkening = .35



var fighter_base_texture_cache:Dictionary[int, Dictionary]
func cache_fighter_base_texture(texture:Texture, scheme_index:int, base_name:String)->void:
	## because this cache is hit by 2 different methods
	## TODO hue-based color-coding more comprehensible
	if not scheme_index in fighter_base_texture_cache:
		fighter_base_texture_cache[scheme_index] = {};
	var hue_1:float = .2;
	var hue_2:float;
	match scheme_index:
		1:
			hue_2 = .37;
		2:
			hue_2 = 0
	
	var new_texture:Texture = hue_shift_texture(texture, hue_1, hue_2);
	fighter_base_texture_cache[scheme_index][base_name] = new_texture;

func color_code_fighter(base:FighterBase, scheme_index:int, sample:bool=false)->void:
	if not scheme_index in fighter_base_texture_cache or \
	not base.name in fighter_base_texture_cache[scheme_index]:
		cache_fighter_base_texture(base.texture, scheme_index,base.name)
	base.texture = fighter_base_texture_cache[scheme_index][base.name]
	
	if not sample:
		var outline_color:Color = Index.color_schemes[scheme_index][1].darkened(fighter_sprite_darkening)
		base.material.set_shader_parameter("color", outline_color)


func color_code_fighter_base_texture(base:FighterBase, scheme_index:int)->Texture:
	if not scheme_index in fighter_base_texture_cache or not\
	base.name in fighter_base_texture_cache[scheme_index]:
		cache_fighter_base_texture(base.texture, scheme_index, base.name);

	return fighter_base_texture_cache[scheme_index][base.name];


func hue_shift_texture(texture:Texture2D, main_hue:float = .5, secondary_hue:float = .2)->Texture:
	var img:Image = texture.get_image();
	
	var width:int = img.get_width();
	var height:int = img.get_height();
	for y in height:
		for x in width:
			var color:Color = img.get_pixel(x, y);
			if color.a:
				if color.h == 0:
					color.h = secondary_hue;
				else:
					color.h = main_hue
			img.set_pixel(x, y, color);
	var final_texture: = ImageTexture.create_from_image(img)
	return final_texture


var vehicle_texture_cache:Dictionary[String, Texture];
func color_code_vehicle(vehicle:Vehicle, leader:Leader)->void:
		if not leader.name in vehicle_texture_cache:
			var target_color:Color = Index.color_schemes[leader.color_scheme_index][1];

			var dict:= {
				Color.RED: Index.day_reflection_color,
				Color.BLUE: target_color.darkened(.5),
				Color.GREEN: target_color
			}
			vehicle_texture_cache[leader.name] = color_code_texture(vehicle.texture, dict);
		## cacheing the player's vehicle even though it's only needed once?
		vehicle.texture = vehicle_texture_cache[leader.name]



var prop_texture_cache:Dictionary[int, Texture]
var large_prop_texture_cache:Dictionary[int, Texture];
func color_code_prop(prop:Sprite2D, texture_index:int, large:bool=false)->void:
	var cache:Dictionary;
	if not large:
		cache = prop_texture_cache;
	else:
		cache = large_prop_texture_cache
	if not texture_index in cache:
		const dict = {
			Color.RED: Color(.5, .5, .5, .4),
			Color.BLUE: Color(.3, .3, .3),
			Color.GREEN: Color(.9, .9, .9)
		}
		cache[texture_index] = color_code_texture(prop.texture, dict);
	prop.texture = cache[texture_index];

var unit_texture_cache:Dictionary[String, Texture]
func color_code_unit(sprite:Sprite2D)->void:
	sprite.texture = hue_shift_texture(sprite.texture);
	

func color_code_texture(texture:Texture2D, pairs:Dictionary)->Texture:
	var img:Image = texture.get_image();
	
	var width:int = img.get_width();
	var height:int = img.get_height()
	
	## colors outside of the dictionary just come back as themselves
	var keys:Array = pairs.keys();
	
	for y in height:
		for x in width:
			var color:Color = img.get_pixel(x, y);
			if color.a and color in keys:
				var new_color:Color = pairs[color];
				img.set_pixel(x, y, new_color);
	var final_texture:Texture =  ImageTexture.create_from_image(img);
	return final_texture
	
