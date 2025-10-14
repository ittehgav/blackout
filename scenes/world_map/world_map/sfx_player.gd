extends SfxPlayer

@export var upkeep_paid:AudioStream;
@export var food_shortage:AudioStream;
@export var fuel_shortage:AudioStream;


func _on_player_upkeep_paid_fully() -> void:
	play_sound_obj(upkeep_paid)


func _on_player_upkeep_fuel_shortage() -> void:
	play_sound_obj(fuel_shortage)


func _on_player_upkeep_food_shortage() -> void:
	play_sound_obj(food_shortage)
