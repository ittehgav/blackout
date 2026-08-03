extends SfxPlayer;

@export var damage_taken:AudioStream;
@export var weapon_change:AudioStream;
@export var module_unavailable:AudioStream;



func damage_taken_sfx(_damage:float, _source:ActiveFighter, quiet:bool)->void:
	if not quiet:
		play_sound_obj(damage_taken);


func _on_equipment_weapon_changed() -> void:
	play_sound_obj(weapon_change);


func _on_equipment_module_fumbled() -> void:
	play_sound_obj(module_unavailable)


func _on_equipment_artifice_fumbled() -> void:
	play_sound_obj(module_unavailable)
