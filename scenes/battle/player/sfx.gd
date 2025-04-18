extends SfxPlayer;

@export var damage_taken:AudioStream;
@export var weapon_change:AudioStream;

func damage_taken_sfx(_damage:float)->void:
	play_sound_obj(damage_taken);


func _on_equipment_weapon_equipped(weapon: Weapon) -> void:
	play_sound_obj(weapon_change);
