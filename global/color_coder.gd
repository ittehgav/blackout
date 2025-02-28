extends Node

## color-coding is applied before fights and replaces the flat RGBs for team-corresponding colors
## all functions of this sort will be in this script
## (unless it ends up becoming massive?)

func color_code_player(character:FighterBase)->void:
	var img:Image = character.texture.get_image()

	var width:int = img.get_width()
	var height:int = img.get_height()
	var base_color:Color = Color.SEA_GREEN.darkened(.25);
	var off_color = Color.DARK_RED;

	for y:int in height:
		for x:int in width:
			var color:Color = img.get_pixel(x, y)
			if color.a:
				var new_color:Color;
				match color:
					Color.GREEN:
						new_color = base_color; 
					Color.BLUE:
						new_color = base_color.darkened(.5)
					Color.YELLOW:
						new_color = off_color
					Color.RED:
						new_color = off_color.darkened(.5)
				img.set_pixel(x, y, new_color)
	character.texture = ImageTexture.create_from_image(img)

func color_code_weapon(weapon:Sprite2D)->void:
	var img:Image = weapon.texture.get_image()
	
	var width:int = img.get_width();
	var height:int = img.get_height();
	var base_color:Color = Color.RED;

	for y:int in height:
		for x:int in width:
			var color:Color = img.get_pixel(x, y);
			if color.a:
				var new_color:Color;
				match color:
					Color.FUCHSIA:
						new_color = base_color.lightened(.5)
					Color.RED:
						new_color = base_color;
				img.set_pixel(x, y, new_color);
	weapon.texture = ImageTexture.create_from_image(img);



func color_code_fighter(fighter:FighterBase, scheme:int=1)->void:
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
	var outline_color = off_color;
	outline_color.a -=.5;
	fighter.material.set_shader_parameter("color", outline_color)
	var img:Image = fighter.texture.get_image()
	
	var width:int = img.get_width();
	var height:int = img.get_height();
	
	const outline_thickness = 2;

	for y:int in height:
		for x:int in width:
			var color:Color = img.get_pixel(x, y);
			if color.a:
				var new_color:Color;
				match color:
					Color.GREEN:
						new_color = base_color;
					Color.BLUE:
						new_color = base_color.darkened(darkening);
					Color.RED:
						new_color = off_color.darkened(darkening);
					Color.YELLOW:
						new_color = off_color;
				img.set_pixel(x, y, new_color);

				
	fighter.texture = ImageTexture.create_from_image(img);


func color_code_settlement(settlement:Settlement)->void:
	var sprite:Sprite2D = settlement.get_node("sprite");
	var texture = sprite.texture
	var img = texture.get_image()

	var width = img.get_width()
	var height = img.get_height()
	var base_color:Color = Color.DARK_GREEN;

	for y in height:
		for x in width:
			var color:Color = img.get_pixel(x, y)
			if color.a:
				var new_color:Color;
				match color:
					Color.GREEN:
						new_color = base_color; 
					Color.BLUE:
						new_color = base_color.lightened(.5)
					Color.RED:
						new_color = base_color.darkened(.5)
				img.set_pixel(x, y, new_color)
	sprite.texture = ImageTexture.create_from_image(img)
