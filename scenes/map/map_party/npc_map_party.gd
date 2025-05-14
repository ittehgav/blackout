extends MapParty;

class_name NpcMapParty
## NPC map parties are essentially representations of 
## Leader nodes' parties, which will contain all the data that makes an NPC map party

var feared_entity:MapEntity;

func _ready()->void:
	await Entities.in_map_player.ready;
	find_target()

func _physics_process(_delta: float) -> void:
	var direction:Vector2;
	if feared_entity:
		direction = (target_entity.position - position).normalized()*-1
	elif target_entity:
		direction= (target_entity.position - position).normalized();
		## without multiplying by delta this behaves exacly as move_and_collide(with delta)??
	else:
		## if teheres no target entity/feared entity, the find_target function makes the npc run in a random direction
		direction = (target_position - position).normalized();
	velocity = direction * move_speed
	move_and_slide();

func find_target() -> void:
	match leader.behavior:
		"agressive":
			if position.distance_to(Entities.in_map_player.position) <= leader.sight_range:
				target_entity =  Entities.in_map_player;
			else:
				idle_movement()
		"peaceful":
			idle_movement()
		"scared":
			if position.distance_to(Entities.in_map_player.position) <= leader.sight_range:
				feared_entity =  Entities.in_map_player;
			else:
				idle_movement();

func idle_movement()->void:
	target_position = Vector2(randi_range(-100, 100), randi_range(-100, 100));
