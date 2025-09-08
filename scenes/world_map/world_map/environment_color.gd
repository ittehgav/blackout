extends CanvasModulate

@export var environment_colors:Array[Color];
@export var horizon_colors:Array[Color]
@export var backdrop:ColorRect

@export var roadside:TileMapLayer
@export var horizon:TileMapLayer

@export var player_light:PointLight2D;

@export var ticker:Timer;

func _ready()->void:
	await get_parent().ready;
	## TODO eventually all onpening environment setups will be in a single script
	## which may or may not be this one
	_on_world_map_hour_passed(true);

func _on_world_map_hour_passed(instant:bool=false) -> void:
	var hour:int = Entities.world_map.current_hour;
	## 21:00 - 3:59 - darkest
	## 4:00 - 10:59 - morning
	## 11:00 - 16:59 - brightest
	## 17:00 - 20:59 - sundset
	var time_index:int;
	
	if hour >= 21 or hour < 4:
		player_light.enabled = true
		player_light.color.a = .12
		time_index = 0;
	elif hour >= 4 and hour < 11:
		player_light.enabled = true;
		player_light.color.a = .05
		time_index = 1;
	elif hour >= 11 and hour < 17:
		player_light.enabled = false;
		time_index = 2;
	elif hour >= 17 and hour < 21:
		player_light.enabled = true
		player_light.color.a = .05
		time_index = 3;

	const backdrop_volumes = [.2, .3, .6, .4]
	const light_alphas = [.15, .075, 0, 5]
		
	var target_color:Color = environment_colors[time_index]
	var target_horizon_color:Color = horizon_colors[time_index]
	var target_backdrop_v:float = backdrop_volumes[time_index]
	if not instant:
		const transition_time = 1;
		var tween:Tween = create_tween();
		tween.tween_property(self, "color", target_color, transition_time);
		tween.parallel().tween_property(backdrop, "color:v", target_backdrop_v, transition_time);
		tween.parallel().tween_property(horizon, "modulate", target_horizon_color, transition_time)
		tween.parallel().tween_property(roadside, "modulate:v", target_backdrop_v, transition_time)
	else:
		color = target_color;
		backdrop.color.v = target_backdrop_v;
		horizon.modulate = target_horizon_color;
		roadside.modulate.v = target_backdrop_v
#func _process(_delta:float)->void:
	#if Input.is_action_just_pressed("skip_time"):
		#ticker.advance_hour()
		#ticker.advance_hour()
		#ticker.advance_hour()
		#
	
	
