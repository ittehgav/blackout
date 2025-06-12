extends Node2D

@export var lightning_textures:Array[Texture]
@export var base:FighterBase;
## offsets match the indexes of the textures as they are ordered numerically in the image files



func shoot(targets:Array[ActiveFighter])->void:
	var current_position:Vector2 = global_position;
	
	for target:ActiveFighter in targets:
		if is_instance_valid(target):
			produce_lightning(current_position, target.global_position);
			current_position = target.global_position;

func produce_lightning(start:Vector2, end:Vector2)->void:
	if base.fighter.ally_team.team_n == 1:
		modulate.a = .5
	var distance:float = start.distance_to(end);
	var bolt_count :int = int(distance/64);
	
	var chain:Node2D = Node2D.new();
	for i:int in bolt_count:
		var bolt:Sprite2D = Sprite2D.new();
		var texture_index:int = i % len(lightning_textures);
		bolt.offset.y = -16;
		bolt.centered = false;
		bolt.texture = lightning_textures[texture_index]
		bolt.offset.x = i * 32;
		chain.add_child(bolt);
	
	add_child(chain);
	chain.global_position = start
	chain.rotation = start.angle_to_point(end);
	
	chain.modulate.a = .1
	
	const tween_c1 = .25
	const tween_c2 = .1
	
	var tween:Tween = create_tween();
	tween.tween_property(chain, "scale", Vector2(1.5, 1.5), .1)
	tween.parallel().tween_property(chain, "modulate:a", 1, tween_c1);
	tween.tween_property(chain, "modulate:a", 0, tween_c2);
	tween.tween_callback(chain.free);
