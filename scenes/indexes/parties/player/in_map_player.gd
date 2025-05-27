extends MapParty

class_name InMapPlayer;

@export var sfx:AudioStreamPlayer;
@export var camera:Camera2D;


func _ready()->void:
	Entities.in_map_player = self;


func _input(e:InputEvent)->void:
	if e is InputEventMouseButton and e.pressed \
	and e.button_index==MOUSE_BUTTON_LEFT and not Entities.world_map.pause_stack:
		var cursor_position:Vector2 = get_global_mouse_position()
		if position.distance_to(cursor_position) > 30:

			target_position = cursor_position;

			started_moving.emit();
	if e.is_action_pressed("stop_movement"):
		stop_movement();
	
	if camera.in_player:
		var camera_direction:Vector2 =\
		 Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if camera_direction and camera.in_player:
			camera.free_panning()
			
func move_toward_entity()->void:
	target_entity = Entities.map_entity_under_mouse
	target_position = target_entity.position;
	
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true);
	
	target_entity.set_collision_layer_value(1, false)
	target_entity.set_collision_layer_value(2, true)

	
func _physics_process(_delta: float) -> void:
	if target_position:
		if global_position.distance_to(target_position) < 2.5:
			stop_movement();
		else:
			var gap:Vector2 = (target_position - global_position).normalized()
			velocity = gap * move_speed;
			move_and_slide();


func stop_movement(play_sound:bool=true)->void:
	if play_sound:
		sfx.play_sound_by_key("movement_stop")

	target_position = Vector2.ZERO
	stopped_moving.emit()

func interact_with_map_entity(entity:MapEntity)->void:
	if entity is Settlement:
		Entities.current_settlement = entity;
		Entities.world_map.ui.settlement_ui.settlement_entered.emit(entity)

	elif entity is MapParty:
		Entities.current_speaking_party = entity;
		Entities.dialogue_player.start_dialogue(entity.leader)


func _on_started_moving() -> void:
	sfx.play_sound_by_key("movement_start")
	get_tree().paused = false;
	camera.return_to_player()



func _on_stopped_moving() -> void:
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, false)
	
	if target_entity:
		target_entity.set_collision_layer_value(2, false)
		target_entity.set_collision_layer_value(1, true)
		target_entity = null;
	get_tree().paused = true;



func intimidate_odds(target:NpcMapParty)->float:
	var combined_level:int = leader.combat_level * 2;
	for unit:FighterUnit in leader.roster.units:
		combined_level += unit.level;
		
	var target_combined_level:int = target.leader.unit.level * 2;
	for unit:FighterUnit in target.leader.roster.units:
		target_combined_level += unit.level;
	
	var frac:float = float(combined_level)/float(target_combined_level);
	if frac >= 3.00:
		return 1.0;
	elif frac >= 2:
		## frac == 2 - odds = .9
		return frac * .45
	elif frac >= 1.75:
		## fract == 1.75 - odds = .8
		return frac * .8/1.75 
	elif frac >= 1.5:
		## frac == 1.5 - odds = .7
		return frac * .7/1.5;
	elif frac >= 1.25:
		## frac == 1.25 - odds = .5
		return frac * .5/1.25
	elif frac >= 1.00:
		## frac == 1.00 - odds = .4
		return frac * .4
	elif frac >= .75:
		## frac == .75 - odds = .3
		return frac * .3/.75
	elif frac >= .5:
		## frac == .5 - odds = .2
		return frac * .2/.5;
	else:
		return 0;

func convince_odds(target:NpcMapParty)->float:
	var level_gap: = 0;
	var leadership_lvl_gap:int = leader.leadership_level - target.leader.unit.level;
	var combat_lvl_gap:int = leader.combat_level - target.leader.unit.level;
	
	if abs(leadership_lvl_gap) < abs(combat_lvl_gap):
		level_gap = abs(leadership_lvl_gap);
	else:
		level_gap = abs(combat_lvl_gap);
	
	var odds: = .8;
	odds += .1 * leader.leadership_stats.charisma
	var per_level_decay: = .8;
	per_level_decay += .025 * leader.leadership_stats.charisma;
	for i:int in level_gap:
		odds *= per_level_decay
	return odds

func roll_intimidate(target:NpcMapParty)->bool:
	var roll: = randf_range(0, 1);
	if roll < intimidate_odds(target):
		return true;
	else:
		return false

func roll_convince(target:NpcMapParty)->bool:
	var roll: = randf_range(0, 1);
	if roll < convince_odds(target):
		return true;
	else:
		return false;


func _on_interaction_range_body_entered(body: Node2D) -> void:
	if body is MapEntity:
		stop_movement(false);
		entity_entered_range.emit(body)
		


func _on_interaction_range_body_exited(body: Node2D) -> void:
	if body is MapEntity:
		entity_left_range.emit(body);


func _on_entity_entered_range(entity: MapEntity) -> void:
	if entity is Settlement:
		sfx.play_sound_by_key("settlement_contact");
	elif entity is NpcMapParty:
		match entity.leader.party_type:
			"thugs":
				if not entity.pacified:
					interact_with_map_entity(entity);
		sfx.play_sound_by_key("map_party_contact");


func _on_quadrant_changed(new_quadrant: WorldMapQuadrant, direction: Vector2) -> void:
	super(new_quadrant, direction);
