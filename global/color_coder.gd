extends Node

## color-coding is applied before fights and replaces the flat RGBs for team-corresponding colors
## all functions of this sort will be in this script
## (unless it ends up becoming massive?)

func color_code_player(character:FighterBase)->void:
	var base_color:Color = Color.SEA_GREEN.darkened(.25);
	var off_color:Color = Color.DARK_RED;
	
	var dict:={
		Color.GREEN: base_color,
		Color.BLUE: base_color.darkened(.5),
		Color.YELLOW: off_color,
		Color.RED: off_color.darkened(.5)
	} 
	color_code_sprite(character, dict);


func color_code_weapon(weapon:Sprite2D)->void:
	var base_color:Color = Color.RED;
	var dict:= {
		Color.GREEN:base_color,
		Color.BLUE:base_color.darkened(.5)
	}
	color_code_sprite(weapon, dict)



func color_code_fighter(fighter:FighterBase, scheme:int=1, sample:bool=false)->void:
	const darkening = .35
	var base_color:Color;
	var off_color:Color;
	match scheme:
		1:
			base_color = Color("007878");
			off_color = Color("C80000");
		2:
			base_color = Color.LIGHT_CORAL;
			off_color = Color.SILVER;
	
	var dict:Dictionary = {
		Color.GREEN:base_color,
		Color.BLUE: base_color.darkened(darkening),
		Color.YELLOW:off_color,
		Color.RED:off_color.darkened(darkening)
	}
	color_code_sprite(fighter, dict)
	
	if not sample:
		var outline_color:Color = off_color;
		outline_color.a -=.5;
		fighter.material.set_shader_parameter("color", outline_color)
	

func color_code_vehicle(vehicle:Vehicle)->void:
	var base_color:Color = Color.SADDLE_BROWN;
	var dict:= {
		Color.BLUE:base_color.darkened(.5),
		Color.GREEN: base_color
	}
	color_code_sprite(vehicle, dict);

func color_code_settlement(settlement:Settlement)->void:
	var sprite:Sprite2D = settlement.get_node("sprite");

	var dict:Dictionary = {
		Color.GREEN: Color.DARK_GREEN,
		Color.BLUE: Color.DARK_GREEN.lightened(.5),
		Color.RED: Color.DARK_GREEN.darkened(.5)
	}
	
	color_code_sprite(sprite, dict)



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
