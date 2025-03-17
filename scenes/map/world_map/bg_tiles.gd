extends TileMapLayer


@export var noise_height_texture:NoiseTexture2D;
var noise:Noise;



var taken_positions:Array[Vector2]

const height = 100;
const width = 100;

func _ready()->void:	
	noise = noise_height_texture.noise
	var min:float =  0.0;
	var max:float  =0.0;
	for x in width * 2:
		for y in height * 2:
			var roll:float = noise.get_noise_2d(x - width, y - height);
			if roll > max:
				max = roll;
			elif roll < min:
				min = roll;
			#
			if roll < -.6:
				set_cell(Vector2(x-width, y-height), 0, Vector2.ONE);
			elif roll < 0:
				set_cell(Vector2(x-width, y-height), 0, Vector2.ZERO);
			elif roll > .2 :
				set_cell(Vector2(x-width, y-height), 0, Vector2.RIGHT)
			else:
				set_cell(Vector2(x-width, y-height), 0, Vector2.DOWN)


	
