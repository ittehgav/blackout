extends PanelContainer

@export var destination_container:HBoxContainer

@export var settlement_prompt_container:HBoxContainer;
@export var settlement_sprite:TextureRect;
@export var settlement_name:Label;

@export var destination_label:Label;
@export var player:InMapPlayer;

var nearby_settlement:Settlement;

var player_moving:bool;
const pixel_to_meters = .2;

func _on_in_map_player_started_moving() -> void:
	player_moving = true;


func _on_in_map_player_stopped_moving() -> void:
	player_moving = false


func refresh_distance() -> void:
	if player_moving:
		if player.target_entity:
			destination_label.text = str(int(player.position.distance_to(player.target_entity.position))*pixel_to_meters) + "m";
		else:
			destination_label.text = str(int(player.position.distance_to(player.target_position))*pixel_to_meters)+"m";
	else:
		if Entities.map_entity_under_mouse:
			destination_label.text = str(int(player.position.distance_to(Entities.map_entity_under_mouse.position))*pixel_to_meters)+"m"
		else:
			destination_label.text = str(int(player.position.distance_to(Entities.world_map.get_local_mouse_position()))*pixel_to_meters)+"m";



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
