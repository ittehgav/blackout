extends Control

@export var interact_btn:Button;
@export var movement_overlay:Control

var current_entity:MapEntity;

const btn_offset = Vector2(-100, -40);



	
func btn_fade_in()->void:
	interact_btn.show();
	interact_btn.modulate.a = .5;
	interact_btn.modulate.v = .5;
	var tween:Tween = create_tween();
	tween.tween_property(interact_btn, "modulate", Color.WHITE, .5);

func _on_in_map_player_entity_entered_range(entity: MapEntity) -> void:
	btn_fade_in();
	current_entity = entity;
	interact_btn.reparent(entity);
	interact_btn.position = Vector2(-30, 50)
	
	if entity is Settlement:
		interact_btn.text = "Enter";
	else:
		interact_btn.text = "Talk"

func _on_button_pressed() -> void:
	Entities.in_map_player.interact_with_map_entity(current_entity)


func _on_in_map_player_entity_left_range(entity: MapEntity) -> void:
	current_entity = null;
	interact_btn.hide();
	interact_btn.reparent(self);


func _on_interact_btn_pressed() -> void:
	Entities.in_map_player.interact_with_map_entity(current_entity);
