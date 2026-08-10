extends Weapon

const rarity = 3;

const size_x = 3;
const size_y = 2;

const scorched_ground_duration = 5

var scorched_ground_damage:float = 35;



@export var scorched_ground:TextureRect;
@export var scorched_ground_hit_scan:Area2D;
@export var scorched_ground_sfx:AudioStreamPlayer
@export var blast_area:CollisionShape2D

func get_description()->String:
	var ammo_str:String = ammo_cost_string()
	var damage_str:String = damage_string();
	return "Consumes %s to fire a bomb that burns the ground in a circle area, burning enemies inside it for %s per second."%[ammo_str, damage_str]

func use(_alt:bool=false)->void:
	consume_ammo()
	animation_player.play(get_animation_key("attack"))
	Combat.shoot_projectile(projectile, Entities.player_fighter, projectile_hit, apply_scorched_ground);


func projectile_hit(target:CombatEntity)->void:
	Combat.deal_damage(Entities.player_fighter, target);
	if refinement_level == 2:
		status.apply_on_target(target)
	hit.emit()

var active_hit_scans:Array[Area2D]
func apply_scorched_ground(target:Vector2)->void:
	
	var ground:TextureRect = scorched_ground.duplicate();
	Entities.player_fighter.ally_team.ground_elements.add_child(ground);
	ground.global_position = target - ground.size/2;
	ground.show();
	scorched_ground_sfx.play()
	
	
	var scan:Area2D = scorched_ground_hit_scan.duplicate()
	active_hit_scans.append(scan)
	scan.global_position = target;
	Entities.player_fighter.ally_team.projectiles.add_child(scan)
	
	await get_tree().create_timer(scorched_ground_duration).timeout;
	scan.queue_free()
	ground.queue_free()


func _on_scoched_ground_dmg_ticker_timeout() -> void:
	for scan:Area2D in active_hit_scans:
		if is_instance_valid(scan):
			Combat.aoe_damage(Entities.player_fighter, scan, scorched_ground_damage, true)
		else:
			active_hit_scans.erase(scan)

const r1_improvement = "+10% scorched ground damage"
const r2_improvement = "Enemies directly hit by the grenade get an agility debuff.";
const r3_improvement = "+50% scorched area size";

func apply_r1()->void:
	scorched_ground_damage += scorched_ground_damage/10;
func apply_r2()->void:
	pass
func apply_r3()->void:
	blast_area.shape.radius *= 1.5;
	scorched_ground.size *= 1.5;
	scorched_ground.pivot_offset *= 1.5
