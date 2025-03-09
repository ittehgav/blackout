extends TileMapLayer

@export var noise_height_text:NoiseTexture2D;
var noise:Noise



const height = 100;
const width = 100;

func _ready():
	noise = noise_height_text.noise

	for x in width:
		for y in height:
			var roll:float = noise.get_noise_2d(x, y);
			
			if roll > 0 and roll < .3:
				set_cell(Vector2(x, y), 0, Vector2.ZERO);
			else:
				set_cell(Vector2(x, y), 0, Vector2.RIGHT)
