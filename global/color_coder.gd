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
	color_code_sprite(character, dict);


func color_code_weapon(weapon:Sprite2D, scheme:int)->void:
	var base_color:Color = Index.color_schemes[scheme][1];
	var dict:= {
		Color.GREEN:base_color,
		Color.BLUE:base_color.darkened(.5)
	}
	color_code_sprite(weapon, dict)



func color_code_fighter(fighter:FighterBase, scheme:int, sample:bool=false)->void:
	var base_color:Color = Index.color_schemes[scheme][0];
	var off_color:Color = Index.color_schemes[scheme][1];
	

	
	var dict:Dictionary = {
		Color.GREEN:base_color,
		Color.BLUE: base_color.darkened(fighter_sprite_darkening),
		Color.YELLOW:off_color,
		Color.RED:off_color.darkened(fighter_sprite_darkening)
	}
	color_code_sprite(fighter, dict)
	
	if not sample:
		var outline_color:Color = off_color.darkened(fighter_sprite_darkening);
		outline_color.a -=.5;
		fighter.material.set_shader_parameter("color", outline_color)

	

func color_code_vehicle(vehicle:Vehicle, leader:Leader)->void:
	var base_color:Color;
	
	base_color = Index.color_schemes[leader.color_scheme_index][1]

	match leader.name:
		"Thugs":
			base_color = Color.DARK_RED;
		"Travelling Trader":
			base_color = Color.LIGHT_GREEN;

	var dict:= {
		Color.BLUE:base_color.darkened(.5),
		Color.GREEN: base_color
	}
	color_code_sprite(vehicle, dict);

func color_code_settlement(settlement:Settlement, tile_color:Color)->void:
	var sprite:Sprite2D = settlement.get_node("sprite");
	var base_color:Color;

	if settlement is Factory:
		base_color = Index.resource_colors["chips"]
	elif settlement is Farm:
		base_color = Index.resource_colors["food"];
	elif settlement is Scrapyard:
		base_color = Index.resource_colors["fuel"].lightened(.3)
	elif settlement is Stadium:
		base_color = Color.GOLD;

	base_color = base_color.darkened(.5)
	var blend:Color = tile_color.darkened(.5)

	var dict:Dictionary = {
		Color.GREEN: base_color.blend(blend),
		Color.BLUE: (base_color.blend(blend)).darkened(.5),
		Color.RED: (base_color.blend(blend)).lightened(.15)
	}
	color_code_sprite(sprite, dict)
	
	var box:Control = settlement.get_node("hover_box");
	box.mouse_entered.connect(sprite.material.set_shader_parameter.bind("color", base_color.lightened(.6) - Color(0, 0, 0, .3)));
	box.mouse_exited.connect(sprite.material.set_shader_parameter.bind("color", Color(0,0,0,0)));


func color_code_sprite(sprite:Sprite2D, pairs:Dictionary)->void:
	sprite.texture = color_code_texture(sprite.texture, pairs);
	

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
	return ImageTexture.create_from_image(img);
	
func scheme_to_sprite_color_pairs(leader:Leader)->Dictionary[Color, Color]:
	## TODO normalize this stuff alerady
	var scheme:Array = Index.color_schemes[leader.color_scheme_index];
	var pairs:Dictionary[Color, Color] = {
		Color.BLUE: scheme[0].darkened(fighter_sprite_darkening),
		Color.GREEN:scheme[0],
		Color.RED:scheme[1].darkened(fighter_sprite_darkening),
		Color.YELLOW: scheme[1]
	}
	return pairs;

func color_code_prop(prop:Sprite2D)->void:
	const dict = {
		Color.RED: Color(.5, .5, .5, .4),
		Color.BLUE: Color(.3, .3, .3),
		Color.GREEN: Color(.9, .9, .9)
	}

	prop.texture = color_code_texture(prop.texture, dict);
