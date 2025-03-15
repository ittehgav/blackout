extends Control

@export var player_sample:SpriteSample;
@export var weapon_sample:SpriteSample;
@export var module_sample:SpriteSample;


	
func refresh_samples()->void:
	if weapon_sample.target_base:
		weapon_sample.target_base.queue_free();

	var weapon_to_sample:Weapon = Entities.player.equipped_weapon;
	weapon_sample.set_sample(weapon_to_sample);
	weapon_sample.tooltip.hint.queue_free();
	
	weapon_to_sample.scale = Vector2(2, 2);
	weapon_to_sample.offset = Vector2.ZERO;
	weapon_to_sample.rotation = 0;
