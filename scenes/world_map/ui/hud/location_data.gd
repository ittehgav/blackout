extends PanelContainer


## TODO unexport this when entities are declared before loading htis scene
@export var sfx:SfxPlayer

@export var road_sprite:Sprite2D

@export var main_text_label:Label;
@export var sub_text_label:Label;

@export var location_sprite:TextureRect;

@export var location_sign:LocationSign;





func display_current_location(target:Location = Entities.player_party.current_location)->void:
	main_text_label.text = target.unique_name;
	sub_text_label.hide()
	
	var location_texture:Texture2D = target.sprite.texture
	var texture_size:Vector2 =  location_texture.get_size();
	location_sprite.custom_minimum_size = texture_size * 2
	
	location_sprite.texture = location_texture;
	location_sprite.self_modulate.a = 1;
	
	road_sprite.hide();
	location_sign.show();

	location_sign.load_location(target);


func _on_player_party_started_moving() -> void:
	show()
	location_sprite.self_modulate.a = 0;
	location_sprite.custom_minimum_size = Vector2(128, 128);
	location_sprite.size = Vector2(128, 128);
	location_sign.hide();
	road_sprite.show();
	
	sub_text_label.show()
	main_text_label.text = "Traveling...";
	sub_text_label.text = "[spacebar] speed up time"
	


func _on_player_party_stopped_moving() -> void:
	display_current_location();
