extends TileMapLayer


const source_id = 0;
const grass_coords = Vector2(1, 1);
const sand_coords = Vector2(11, 1)

@export var noise_height_texture:NoiseTexture2D;
var width = 100;
var height = 100;
var noise:Noise;

func _ready() -> void:
	noise = noise_height_texture.noise;
	noise.seed = randi_range(1, 10)
	generate_world();
	
func generate_world():
	for x in width:
		for y in height:
			var noise_val = noise.get_noise_2d(x, y)
			if noise_val > 0.0:
				set_cell(Vector2(x, y), source_id, grass_coords);
			else:
				set_cell(Vector2(x, y), source_id, sand_coords);

				
