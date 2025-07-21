extends Node

## color-coding is applied before fights and replaces the flat RGBs for team-corresponding colors
## all functions of this sort will be in this script
## (unless it ends up becoming massive?)
const fighter_sprite_darkening = .35

func color_code_player(character:FighterBase)->void:
	var scheme:Array = Index.color_schemes[Entities.player.color_scheme_index];	
	var base_color:Color = scheme[0]
	var off_color:Color = scheme[1];
	
	var dict:={
		Color.GREEN: base_color,
		Color.BLUE: base_color.darkened(.5),
		Color.YELLOW: off_color,
		Color.RED: off_color.darkened(.5)
	}
	character.texture = color_code_texture(character.texture, dict)

var weapon_texture_cache:Dictionary[int, Texture]
func color_code_weapon(weapon:Sprite2D, scheme_index:int)->void:
	if not scheme_index in weapon_texture_cache:
		var base_color:Color = Index.color_schemes[scheme_index][1];
		var dict:= {
			Color.GREEN:base_color,
			Color.BLUE:base_color.darkened(.5)
		}
		
		weapon_texture_cache[scheme_index] = color_code_texture(weapon.texture, dict);
	weapon.texture = weapon_texture_cache[scheme_index]

var fighter_base_texture_cache:Dictionary[int, Dictionary]
func cache_fighter_base_texture(texture:Texture, scheme_index:int, base_name:String)->void:
	## because this cache is hit by 2 different methods
	if not scheme_index in fighter_base_texture_cache:
		fighter_base_texture_cache[scheme_index] = {};

	
	var scheme:Array = Index.color_schemes[scheme_index]
	var base_color:Color = scheme[0];
	var off_color:Color = scheme[1]

	var dict:Dictionary = {
		Color.GREEN:base_color,
		Color.BLUE: base_color.darkened(fighter_sprite_darkening),
		Color.YELLOW:off_color,
		Color.RED:off_color.darkened(fighter_sprite_darkening)
	}
	var new_texture:Texture = color_code_texture(texture, dict);
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

var vehicle_texture_cache:Dictionary[String, Texture];
func color_code_vehicle(vehicle:Vehicle, leader:Leader)->void:
		if not leader.name in vehicle_texture_cache:
			var target_color:Color = Index.color_schemes[leader.color_scheme_index][1];
			var from_player:bool=false
			

			var dict:= {
				Color.RED: Index.day_reflection_color,
				Color.BLUE: target_color.darkened(.5),
				Color.GREEN: target_color
			}
			vehicle_texture_cache[leader.name] = color_code_texture(vehicle.texture, dict);
		## cacheing the player's vehicle even though it's only needed once?
		vehicle.texture = vehicle_texture_cache[leader.name]


var settlement_texture_cache:Dictionary[String, Texture];
var settlement_outline_color_cache:Dictionary[String, Color]
func color_code_settlement(settlement:Settlement)->void:
	
	var sprite:Sprite2D = settlement.get_node("sprite");
	if not settlement.settlement_type_name in settlement_texture_cache:
		var target_color:Color;

		if settlement is Factory:
			target_color = Index.resource_colors["scrap"]
		elif settlement is Farm:
			target_color = Index.resource_colors["food"].darkened(.25);
		elif settlement is Scrapyard:
			target_color = Index.resource_colors["fuel"].darkened(.2)
		elif settlement is Stadium:
			target_color = Color.GOLD;


		var dict:Dictionary = {
			Color.GREEN: target_color,
			Color.BLUE: target_color.darkened(.5),
			Color.RED: target_color.lightened(.15)
		}

		settlement_texture_cache[settlement.settlement_type_name] = color_code_texture(sprite.texture, dict);
		settlement_outline_color_cache[settlement.settlement_type_name] = target_color
	sprite.texture = settlement_texture_cache[settlement.settlement_type_name];
	
	var box:Control = settlement.get_node("hover_box");
	var outline_color:Color = settlement_outline_color_cache[settlement.settlement_type_name];
	box.mouse_entered.connect(sprite.material.set_shader_parameter.bind("color", outline_color));
	box.mouse_exited.connect(sprite.material.set_shader_parameter.bind("color", Color(0,0,0,0)));

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
	
