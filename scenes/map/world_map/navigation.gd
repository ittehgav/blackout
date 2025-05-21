extends PanelContainer

@export var destination_container:HBoxContainer


@export var compass:Sprite2D;

@export var settlement_prompt_container:HBoxContainer;
@export var settlement_sprite:TextureRect;
@export var settlement_name:Label;

@export var estimate:Label;
@export var stop_prompt:Label;
@export var destination_label:Label;
@export var player:InMapPlayer;

var nearby_settlement:Settlement;

var player_moving:bool;
const pixel_to_meters = .2;

func _process(_delta:float)->void:
	if not player_moving:
		var cursor_position:Vector2 = Entities.world_map.get_local_mouse_position();
		set_estimate(cursor_position)
		compass.rotation = player.position.angle_to_point(cursor_position)
	else:
		set_estimate(player.target_position)
func _on_in_map_player_started_moving() -> void:
	stop_prompt.show();
	compass.rotation = player.position.angle_to_point(player.target_position)
	set_estimate(player.target_position)
	player_moving = true;


func _on_in_map_player_stopped_moving() -> void:
	stop_prompt.hide();
	player_moving = false


func refresh_distance() -> void:
	if player_moving:
		if player.target_entity:
			set_distance_label(player.target_entity.position)
		else:
			set_distance_label(player.target_position);
	else:
		if Entities.map_entity_under_mouse:
			set_distance_label(Entities.map_entity_under_mouse.position)
		else:
			set_distance_label(Entities.world_map.get_local_mouse_position())

func set_distance_label(target:Vector2)->void:
	destination_label.text = str(int(player.position.distance_to(target)*pixel_to_meters))+ "m"

func _on_in_map_player_entity_entered_range(entity: MapEntity) -> void:
	if entity is Settlement:
		nearby_settlement = entity;
		show_enter_settlement_prompt(entity);


func _on_in_map_player_entity_left_range(entity: MapEntity) -> void:
	settlement_prompt_container.hide();
	destination_container.show();
	nearby_settlement = null;
	
func _input(e:InputEvent)->void:
	if nearby_settlement and e.is_action_pressed("world_map_interact"):
		player.interact_with_map_entity(nearby_settlement);

func show_enter_settlement_prompt(settlement:Settlement)->void:
	destination_container.hide();
	settlement_prompt_container.show()
	
	settlement_name.text = settlement.name;
	settlement_sprite.texture = settlement.get_node("sprite").texture

func set_estimate(target:Vector2)->void:
	var in_game_minutes:float = player.position.distance_to(target)/player.move_speed;
	estimate.text = parse_minutes(in_game_minutes);
	
func parse_minutes(time:float)->String:
	var hours:int = 0;
	var minutes:int = 0;
	
	var final_string:String;
	
	while time >= 60:
		hours -= 1;
		time -= 60;

	minutes = int(time + 1);
	if hours < 10:
		final_string = "0" + str(hours);
	else:
		final_string = str(hours);
	final_string += ":" + str(minutes);
	return final_string;
