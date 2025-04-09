extends Node

@export var unit:NpcFighter;



func _on_npc_fighter_damage_taken(damage: float) -> void:
	var intensity:int=1;
	if damage > unit.max_hp/2:
		intensity = 3;
	elif damage > unit.max_hp/3:
		intensity = 2;

	Tweens.damage_vfx(unit, intensity)


func _on_npc_fighter_healing_received(value: float) -> void:
	var heal_fraction:float = unit.max_hp/value;
	var transparency:float;
	if heal_fraction > .5:
		transparency = 0;
	elif heal_fraction > .3:
		transparency = .6
	else:
		transparency = .2
	
	Tweens.heal_vfx(unit, transparency)


func _on_npc_fighter_status_applied(_source: ActiveFighter, data: Dictionary) -> void:
	## VFX from statuses will be handled here
	match data.type:
		"stun":
			unit.base.modulate = Color.PURPLE
			Tweens.stun_vfx(unit);



func _on_npc_fighter_status_removed(status_type: String, _data: Dictionary) -> void:
	match status_type:
		"stun":
			unit.base.modulate = Color.WHITE;
