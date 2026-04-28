extends AudioStreamPlayer

@export var wood_hit:AudioStream;
@export var flesh_hit:AudioStream;
@export var metal_hit:AudioStream;

func weapon_hit()->void:
	var target:CombatEntity = Entities.player_fighter.hit_targets[0]
	pitch_scale = 1
	match target.body_type:
		CombatEntity.BodyType.flesh:
			pitch_scale = 1.25
			stream = flesh_hit;
		CombatEntity.BodyType.metal:
			stream = metal_hit;
		CombatEntity.BodyType.wood:
			pitch_scale = 1.5
			stream = wood_hit;
	play()
