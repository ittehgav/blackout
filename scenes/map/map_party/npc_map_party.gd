extends MapParty;

class_name NpcMapParty
## NPC map parties are essentially representations of 
## Leader nodes' parties, which will contain all the data that makes an NPC map party


@export var scared_icon_texture:Texture;
@export var passive_icon_texture:Texture;
@export var agressive_icon_texture:Texture;
@export var idle_icon_texture:Texture;

@export var behavior_icon:TextureRect;
@export var find_target_timer:Timer;
var feared_entity:MapEntity;

func _ready()->void:
	await Entities.in_map_player.ready;
	find_target()

func _physics_process(_delta: float) -> void:
	var direction:Vector2;
	
	if feared_entity or target_entity:
		## idle movement is done through tweens
		if feared_entity:
			direction = -(feared_entity.global_position - global_position).normalized()
		elif target_entity:
			direction = (target_entity.global_position - global_position).normalized();
			## without multiplying by delta this behaves exacly as move_and_collide(with delta)??

		velocity = direction * move_speed
		move_and_slide();

func find_target() -> void:
	match leader.behavior:
		"passive":
			set_behavior_icon("passive")
			idle_movement()
		"agressive":
			if global_position.distance_to(Entities.in_map_player.global_position) <= leader.sight_range:
				set_behavior_icon("agressive")
				target_entity =  Entities.in_map_player;
			else:
				set_behavior_icon("idle")
				idle_movement()
		"scared":
			set_behavior_icon("scared")
			if global_position.distance_to(Entities.in_map_player.global_position) <= leader.sight_range:
				feared_entity =  Entities.in_map_player;
			else:
				idle_movement();


func idle_movement()->void:
	var tween:Tween = create_tween();
	var target_position:Vector2= global_position + Vector2(randi_range(-100, 100), randi_range(-100, 100));
	vehicle.adjust_direction(target_position)
	tween.tween_property(self, "global_position", target_position, find_target_timer.wait_time);


func set_behavior_icon(target:String)->void:
	behavior_icon.show();
	match target:
		"agressive":
			behavior_icon.texture = agressive_icon_texture;
		"scared":
			behavior_icon.texture = scared_icon_texture
		"idle":
			behavior_icon.texture = idle_icon_texture;
		"passive":
			behavior_icon.texture = passive_icon_texture;
