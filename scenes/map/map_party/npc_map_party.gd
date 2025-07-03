extends MapParty;

class_name NpcMapParty
## NPC map parties are essentially representations of 
## Leader nodes' parties, which will contain all the data that makes an NPC map party




@export var behavior_icon:TextureRect;
@export var find_target_timer:Timer;
@export var party_size_label:Label;

var feared_entity:MapEntity;
var pacified:bool;

var intimidate_attempted:bool = false;
var persuade_attempted:bool=false;

func _ready()->void:
	match leader.party_type:
		"thugs":
			behavior_icon.texture = Index.agressive_icon_texture;
			party_size_label.text = str(len(leader.roster.units))
		"travelling_trader":
			behavior_icon.texture = Index.salesman_icon_texture;
	find_target.call_deferred();
	

func _physics_process(_delta: float) -> void:
	if target_entity:
		var direction:Vector2;
		## only movement towards an entity (right now only the player) is done through here
		direction = (target_entity.global_position - global_position).normalized();
		velocity = direction * move_speed;
		move_and_slide();

func find_target() -> void:
	match leader.party_type:
		"thugs":
			## behavior icons will be set on status application
			if pacified:
				set_behavior_icon("idle")
				idle_movement();
			else:
				if global_position.distance_to(Entities.player_map_party.global_position) <= leader.sight_range:
					if feared_entity:
						set_behavior_icon("scared");
						var direction:Vector2 = (global_position - feared_entity.global_position).normalized();
						run_in_direction(direction);
					else:
						set_behavior_icon("agressive")
						target_entity = Entities.player_map_party;
						vehicle.adjust_direction(target_entity.global_position)
				else:
					set_behavior_icon("idle")
					idle_movement();
		"travelling_trader":
			## traders will stand still if the player is nearby
			if global_position.distance_to(Entities.player_map_party.global_position) >= leader.sight_range:
				idle_movement();

func set_behavior_icon(key:String)->void:
	behavior_icon.texture = Index[key+"_icon_texture"];

func run_in_direction(direction:Vector2)->void:
	vehicle.adjust_direction(global_position + direction);
	var duration:float = find_target_timer.wait_time;
	var tween:Tween = create_tween();
	tween.tween_property(self, "global_position", global_position + direction * move_speed, duration);

func idle_movement()->void:
	var direction:Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1));
	run_in_direction(direction);
	
func clear_feared_entity()->void:
	feared_entity = null;
	
func depacify()->void:
	pacified = false;
