extends PanelContainer


## TODO unexport this when entities are declared before loading htis scene
@export var sfx:SfxPlayer
@export var player_party:PlayerParty

@export var road_sprite:Sprite2D

@export var main_text_label:Label;
@export var sub_text_label:Label;

@export var location_sprite:TextureRect;

@export var settlement_sign:SettlementSign;



func _ready()->void:
	player_party.current_settlement.data.seen = true;
	player_party.current_settlement.data.visited = true;
	display_current_settlement()
	
func display_current_settlement(target:Settlement = Entities.player_party.current_settlement)->void:
	if not player_party.current_settlement:
		return
	
	main_text_label.text = target.unique_name;
	sub_text_label.text = "[spacebar] enter"
	
	var settlement_texture:Texture2D = target.get_node("sprite").texture
	var texture_size:Vector2 =  settlement_texture.get_size();
	location_sprite.custom_minimum_size = texture_size * 2
	
	location_sprite.texture = settlement_texture;
	location_sprite.self_modulate.a = 1;
	
	road_sprite.hide();
	settlement_sign.show();

	settlement_sign.load_settlement(target);


func _on_player_upkeep_food_shortage() -> void:
	sfx.play_sound_by_key("food_shortage")


func _on_player_upkeep_fuel_shortage() -> void:
	sfx.play_sound_by_key("fuel_shortage")


func _on_player_upkeep_paid_fully() -> void:
	sfx.play_sound_by_key("upkeep_paid")


func _on_player_party_started_moving() -> void:
	location_sprite.self_modulate.a = 0;
	location_sprite.custom_minimum_size = Vector2(128, 128);
	location_sprite.size = Vector2(128, 128);
	settlement_sign.hide();
	road_sprite.show();
	
	main_text_label.text = "Traveling...";
	sub_text_label.text = "Arrival by [color=white]erm"
	
