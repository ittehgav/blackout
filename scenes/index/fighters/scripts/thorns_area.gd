extends ColorRect

@export var thorns_sprite:Sprite2D;
@export var light:PointLight2D;
@export var hit_scan_area:Area2D;
@export var thorns_container:Node2D;

var hit_scan:CollisionShape2D;
var hit_scan_shape:Shape2D;

var current_sprite_positions:Array[Vector2];

const fade_in_time = .5
func _ready()->void:
	## plays when the thorns are first added;
	## also plays the animation for the invisible original but its k
	set_sprites();
	light.energy = 16;
	
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 1, fade_in_time)
	tween.tween_property(light, "energy", 0, fade_in_time * 2);
	
	generate_hit_scan();

func generate_hit_scan()->void:
	hit_scan = CollisionShape2D.new();
	hit_scan_shape = RectangleShape2D.new();
	hit_scan.shape = hit_scan_shape;
	
	hit_scan_shape.size = size;
	
	hit_scan_area.add_child(hit_scan);


const expansion:int = 20;
const growth = Vector2(expansion, expansion);
const growth_time = .5
const light_texture_size = 10;

func expand(center:Vector2)->void:
	## CENTER IS A GLOBAL POSITION
	set_sprites();
	var tween:Tween = create_tween();
	
	var new_size:Vector2 = size + growth;
	var shift:Vector2 = growth/2;
	
	var new_position:Vector2 = position - shift;
	var new_container_position:Vector2 = thorns_container.position + shift
	
	
	tween.tween_property(self, "size", new_size, growth_time);
	tween.parallel().tween_property(self, "position", new_position, growth_time)
	tween.parallel().tween_property(thorns_container, "position", new_container_position, growth_time)

	
	tween.parallel().tween_property(hit_scan_shape, "size", new_size, growth_time);
	
	
	tween.parallel().tween_property(light, "energy", 16, growth_time)
	tween.parallel().tween_property(light, "scale", new_size/light_texture_size, growth_time)

	tween.tween_property(light, "energy", 0, growth_time/2);



const thorns_sprite_spacing = 128

func set_sprites()->void:
	var top_left_position:Vector2 = (global_position/thorns_sprite_spacing).floor() * thorns_sprite_spacing;
	var bottom_right_position:Vector2 = ((global_position + size)/thorns_sprite_spacing).floor()* thorns_sprite_spacing + Vector2(thorns_sprite_spacing, thorns_sprite_spacing);
	
	var sprite_positions:Array[Vector2];
	
	var x:int = top_left_position.x;
	var y:int = top_left_position.y;
	while x < bottom_right_position.x:
		while y < bottom_right_position.y:
			sprite_positions.append(Vector2(x, y))
			y += thorns_sprite_spacing;
		y = top_left_position.y
		x += thorns_sprite_spacing;
	
	for p:Vector2 in sprite_positions:
		if p not in current_sprite_positions:
			var sprite:Sprite2D = thorns_sprite.duplicate()
			sprite.show();
			thorns_container.add_child(sprite)
			sprite.global_position = p;
			current_sprite_positions.append(p);
