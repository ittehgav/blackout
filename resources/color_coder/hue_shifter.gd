@tool
extends Resource

class_name HueShiftGen

@export var target_texture:Texture2D;
const base_path:String="assets/visual/sprites/fighters/units/";
@export var base_name:String


const player_team_color:Color=Color("24b32696");
const enemy_team_color:Color=Color("66141496");

@export var generate:bool:
	set(value):
		if value:
			generate_color_coded_sprites();


@export var ally_texture:Texture2D;
@export var enemy_texture:Texture2D;

func generate_color_coded_sprites()->void:
	var base_image:Image = target_texture.get_image();
	
	var base_size:Vector2 = target_texture.get_size()
	
	var ally_image:Image = base_image.duplicate();
	var enemy_image:Image = base_image.duplicate()
	
	
	for y:int in base_size.y:
		for x:int in base_size.x:
			var color:Color = base_image.get_pixelv(Vector2i(x, y));
			if color.a:
				if color.s > .15:
					## if the saturation is lower, the images are kept the same
					color.h = player_team_color.h;
					color.s += .2
					ally_image.set_pixel(x, y, color);
					
					color.h = enemy_team_color.h;
					color.s += .2
					enemy_image.set_pixel(x, y, color)
	
	
	
	var ally_path:String = base_path + base_name + "/" + base_name + "_ally.png"
	var enemy_path:String = base_path + base_name + "/" + base_name + "_enemy.png"
	
	ally_image.save_png(ally_path);
	ally_texture = load(ally_path)
	
	enemy_image.save_png(enemy_path);
	enemy_texture = load(enemy_path)
	
	ResourceSaver.save(self)


	
func apply_color_coding(target:ActiveFighter, team_n:int)->void:
	## looking weird because it uses variables differently in 
	## tool mode and regular test runs
	var coded_texture:Texture2D;
	if team_n == 1:
		coded_texture = ally_texture;
	else:
		coded_texture=enemy_texture;
		
	target.sprite.texture = coded_texture;
	
	

	
	
