extends Control

@export var settlement_ui:Control;

@export var clouds:Node2D;

@export var sky_bg:ColorRect;
@export var crowd_rect:TextureRect;
@export var background:TextureRect;


@export var cloud_textures:Array[Texture]
@export var star_textures:Array[Texture]

@export var chatter_box:Label;

func _ready()->void:
	get_window().size_changed.connect(resize);

func resize()->void:
	if is_inside_tree():
		var window_size:Vector2 = get_window().size;
		
		size = window_size;
		position.y = size.y * -1
		background.size = window_size
	

func pass_time(time:int, floating_chatter:bool=false)->Tween:
	generate_sky(floating_chatter);
	
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_SINE);
	tween.parallel().tween_property(settlement_ui, "position:y", settlement_ui.position.y + settlement_ui.size.y, 2.5);
	await tween.finished;
	
	for i in time:
		Entities.world_map.time_skipped.emit()
		Entities.world_map.hour_passed.emit();
		await sky_bg.color_background(true)
	
	await get_tree().create_timer(time/2).timeout;
	var crowd_tween:Tween = create_tween();
	crowd_tween.tween_property(crowd_rect, "modulate:a", 1, .15);
	crowd_tween.tween_callback(sky_bg.switch_crowd);
	crowd_tween.tween_property(crowd_rect, "modulate:a", 1, .15)
	
	return crowd_tween;

func return_camera()->Tween:
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(settlement_ui, "position:y", 0, 1);
	return tween

func generate_sky(floating_chatter:bool)->void:
	## TODO separate this into a function that generates the clouds and one that moves them
	## and then make it so there's clouds that appear in the settlement's background without the camera going up
	for c in clouds.get_children():
		c.queue_free();
	clouds.position.x = 0;
	
	const props_x = 4;
	const props_y = 3;
	
	var window_size:Vector2 = get_window().size;
	var window_x_fraction:float = window_size.x/props_x;
	var window_y_fraction:float = window_size.y/props_y;
	
	const drift_range = 100;
	for y in props_y:
		for x in props_x:
			var texture:Texture = cloud_textures.pick_random();
			var sprite:Sprite2D = Sprite2D.new();
			sprite.scale = Vector2(8,8);
			sprite.texture = texture;
			
			var x_offset:float = x * window_x_fraction + window_x_fraction/2 + randi_range(-drift_range, drift_range);
			var y_offset:float = y * window_y_fraction + window_y_fraction/2 +randi_range(-drift_range, drift_range)
			sprite.position = Vector2(x_offset,y_offset);
			clouds.add_child(sprite);
			
			var y_drift:int = randi_range(-drift_range, drift_range)
			var tween:Tween = create_tween();
			tween.tween_property(sprite, "position:y", sprite.position.y + y_drift, 10)
	
	var clouds_tween:Tween = create_tween();
	var x_drift:int = randi_range(100, 150);
	if randf_range(0, 1) > .5:
		x_drift *= -1;
	clouds_tween.tween_property(clouds, "position:x", position.x + x_drift, 10)
	
	if floating_chatter:
		if Entities.world_map.current_hour >= 18 || Entities.world_map.current_hour <= 3:
			chatter_box.modulate = Color.WHITE;
		else:
			chatter_box.modulate = Color.BLACK
		await get_tree().create_timer(1.25).timeout
		var wait_acm:float = 0;
		for i in 3:
			const x_margin = 300;
			var chatter:Label = chatter_box.duplicate();
			chatter.position = Vector2(randi_range(x_margin, window_size.x - x_margin), window_size.y + 20);
			add_child(chatter)
			 
			
			var tween:Tween = create_tween();
			tween.set_trans(Tween.TRANS_QUAD)
			wait_acm += .5
			tween.tween_interval(wait_acm);
			tween.tween_callback(chatter.show)
			tween.tween_property(chatter, "position:y", chatter.position.y - randi_range(500, 1000), 1.5);
			tween.parallel().tween_property(chatter, "modulate:a", 0, 2)
