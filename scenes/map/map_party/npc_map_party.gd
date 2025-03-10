extends MapParty;

## NPC map parties are essentially representations of 
## Leader nodes' parties, which will contain all the data that makes an NPC map party


func _ready():
	find_target();

func _physics_process(delta: float) -> void:
	if target_entity:
		var direction:Vector2 = (target_entity.position - position).normalized();
		## without multiplying by delta this behaves exacly as move_and_collide(with delta)
		velocity = direction * move_speed
		move_and_slide();

func find_target() -> void:
	match leader.behavior:
		"agressive":
			if position.distance_to(Entities.in_map_player.position) <= leader.sight_range:
				target_entity =  Entities.in_map_player;
