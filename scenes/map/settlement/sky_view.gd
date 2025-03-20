extends Control

@export var clouds:Node2D;

@export var cloud_textures:Array[Texture]
@export var star_textures:Array[Texture]

@export var chatter_box:Label;




func generate_sky():
	for c in clouds.get_children():
		c.queue_free();
	clouds.position.x = 0;
	
	const props_x = 4;
	const props_y = 3;
	
	var window_size:Vector2 = get_window().size;
	var window_x_fraction = window_size.x/props_x;
	var window_y_fraction = window_size.y/props_y;
	
	const drift_range = 100;
	for y in props_y:

		for x in props_x:
			var texture = cloud_textures.pick_random();
			var sprite:Sprite2D = Sprite2D.new();
			sprite.scale = Vector2(8,8);
			sprite.texture = texture;
			
			var x_offset = x * window_x_fraction + window_x_fraction/2 + randi_range(drift_range * -1, drift_range);
			var y_offset = y * window_y_fraction + window_y_fraction/2 +randi_range(drift_range * -1, drift_range)
			sprite.position = Vector2(x_offset,y_offset);
			clouds.add_child(sprite);
			
			var y_drift = randi_range(drift_range * -1, drift_range)
			var tween = create_tween();
			tween.tween_property(sprite, "position:y", sprite.position.y + y_drift, 10)
	
	var clouds_tween = create_tween();
	var x_drift = randi_range(100, 150);
	if randf_range(0, 1) > .5:
		x_drift *= -1;
	clouds_tween.tween_property(clouds, "position:x", position.x + x_drift, 10)
	await get_tree().create_timer(1.25).timeout
	var wait_acm:float = 0;
	for i in 3:
		var x_margin = 100;
		var chatter = chatter_box.duplicate();
		chatter.position = Vector2(randi_range(x_margin, window_size.x - x_margin), window_size.y + 200 + randi_range(10, 50));
		add_child(chatter)
		
		
		var tween = create_tween();
		tween.set_trans(Tween.TRANS_QUAD)
		wait_acm += .5
		tween.tween_interval(wait_acm);
		tween.tween_callback(chatter.show)
		tween.tween_property(chatter, "position:y", chatter.position.y - randi_range(200, 400), .75);
		tween.parallel().tween_property(chatter, "modulate:a", 0, 1)
