extends Node


## color-coding is applied before fights and replaces the flat RGBs for team-corresponding colors
## all functions of this sort will be in this script
## (unless it ends up becoming massive?)
const fighter_sprite_darkening = .35




func color_code_fighter(fighter:ActiveFighter, team_n:int)->void:
	var base:FighterBase = fighter.base
	
	if not base:return;## skips over props (make this skip in-context instead?)

	
	color_code_fighter_overlay(fighter.overlay, fighter.ally_team)

	var outline_color:Color;
	match team_n:
		1:
			outline_color = Index.player_team_color;
		2:
			outline_color = Index.enemy_team_color
	base.material.set_shader_parameter("color", outline_color)


const t1_hp_bar_color:Color=Color(0.36, 0.9, 0.432, 1.0)
const t2_hp_bar_color:Color = Color(1.0, 0.1, 0.1, 1.0)
static func color_code_fighter_overlay(target:FighterOverlay, team:Team)->void:
	var hp_bar_color:Color;
	match team.team_n:
		1:
			hp_bar_color = t1_hp_bar_color
		2:
			hp_bar_color = t2_hp_bar_color
	
	target.hp_bar.modulate = hp_bar_color;


	

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
	
