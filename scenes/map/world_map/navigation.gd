extends PanelContainer

@export var minute_ticker:Timer;

@export var destination_container:HBoxContainer


@export var compass:Sprite2D;

@export var interact_prompt_container:HBoxContainer;
@export var map_entity_name:Label;
@export var interact_prompt_label:Label;

@export var settlement_sprite:TextureRect;
@export var trader_icon:ResourceIcon;


@export var entity_icons:Array[TextureRect];

@export var estimate:Label;
@export var stop_prompt:Label;
@export var destination_label:Label;
@export var player:InMapPlayer;

var nearby_entity:MapEntity;

var player_moving:bool;
const pixel_to_meters = 1;
const map_party_move_speed_to_meters_per_second = 1;
@onready var irl_minute_to_igt_minute:float = minute_ticker.wait_time;

func _process(_delta:float)->void:
	if not player_moving:
		var cursor_position:Vector2 = Entities.world_map.get_local_mouse_position();
		set_estimate(cursor_position)
		compass.rotation = player.position.angle_to_point(cursor_position)
	else:
		set_estimate(player.target_position)

func _input(e:InputEvent)->void:
	## kinda silly that this is in this script?
	if nearby_entity and e.is_action_pressed("world_map_interact") and get_tree().paused:
		player.interact_with_map_entity(nearby_entity);



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
			set_distance_label(player.target_entity.global_position)
		else:
			set_distance_label(player.target_position);
	else:
		if Entities.map_entity_under_mouse:
			set_distance_label(Entities.map_entity_under_mouse.global_position)
		else:
			set_distance_label(get_global_mouse_position())

func set_distance_label(target:Vector2)->void:
	var distance: = (player.global_position.distance_to(target)*pixel_to_meters);
	if distance > 1000:
		destination_label.text = str(snapped(distance/1000, .01)) + "km"
	else:	
		destination_label.text = str(int(distance))+ "m"

func _on_in_map_player_entity_entered_range(entity: MapEntity) -> void:
	nearby_entity = entity;
	if entity is Settlement:
		show_enter_settlement_prompt(entity);
	if entity is NpcMapParty:
		show_interact_with_party_prompt(entity);


func _on_in_map_player_entity_left_range(_entity: MapEntity) -> void:
	interact_prompt_container.hide();
	destination_container.show();
	nearby_entity = null;
	

func show_enter_settlement_prompt(settlement:Settlement)->void:
	destination_container.hide();
	interact_prompt_container.show()
	
	
	for icon in entity_icons:
		icon.hide();
	settlement_sprite.show();
	
	
	map_entity_name.text = settlement.name;
	settlement_sprite.texture = settlement.get_node("sprite").texture
	interact_prompt_label.text = "[spacebar] enter"

func show_interact_with_party_prompt(party:NpcMapParty)->void:
	for icon in entity_icons:
		icon.hide();
	trader_icon.show();
	
	destination_container.hide();
	interact_prompt_container.show();
	
	map_entity_name.text = party.leader.name;
	interact_prompt_label.text = "[spacebar] enter"
	

func set_estimate(target:Vector2)->void:
	var in_game_minutes:float = player.position.distance_to(target)/(player.move_speed * map_party_move_speed_to_meters_per_second);
	in_game_minutes /= irl_minute_to_igt_minute;
	estimate.text = parse_minutes(in_game_minutes);



func parse_minutes(time:float)->String:
	var hours:int = 0;
	var minutes:int = 0;
	
	var final_string:String;
	
	while time >= 60:
		hours += 1;
		time -= 60;

	minutes = int(time + 1);
	if hours < 10:
		final_string = "0" + str(hours);
	else:
		final_string = str(hours);
	var minutes_string:String;
	if minutes < 10:
		minutes_string = "0" + str(minutes);
	else:
		minutes_string = str(minutes)
	final_string += ":" + minutes_string;
	return final_string;
