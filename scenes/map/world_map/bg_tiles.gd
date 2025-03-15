extends TileMapLayer

@export var noise_height_text:NoiseTexture2D;
var noise:Noise



const height = 100;
const width = 100;

func _ready()->void:
	noise = noise_height_text.noise

	for x in width * 2:
		for y in height * 2:
			var roll:float = noise.get_noise_2d(x - width, y - height);
			
			if roll > 0 and roll < .3:
				set_cell(Vector2(x-width, y-height), 0, Vector2.ZERO);
			else:
				set_cell(Vector2(x-width, y-height), 0, Vector2.RIGHT)
