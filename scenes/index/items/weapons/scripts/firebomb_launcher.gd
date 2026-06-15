extends Weapon

const rarity = 3;

const size_x = 3;
const size_y = 2;

const scorched_ground_duration = 5

const r1_improvement = "+50% scorched area size";
const r2_improvement = "Enemies directly hit by the grenade take double damage from scorched ground";
const r3_improvement = "Enemies in the scorched ground have -50% agility.";

@export var scorched_ground:TextureRect;
@export var scorched_ground_hit_scan:Area2D;
@export var scorched_ground_sfx:AudioStreamPlayer

func get_description()->String:
	var ammo_str:String = ammo_cost_string()
	var damage_str:String = damage_string();
	return "Consumes %s to fire a bomb that burns the ground in a circle area, burning enemies inside it for %s per second."%[ammo_str, damage_str]

func use(_alt:bool=false)->void:
	consume_ammo()
	animation_player.play(animation_root_key+"/attack")
	Combat.shoot_projectile(projectile, Entities.player_fighter, projectile_hit);


func projectile_hit(target:CombatEntity)->void:
	Combat.deal_damage(Entities.player_fighter, target);
	scorched_ground_sfx.play()
	apply_scorched_ground(target)
	hit.emit()

func apply_scorched_ground(target:CombatEntity)->void:
	var ground:TextureRect = scorched_ground.duplicate();
	Entities.player_fighter.ally_team.ground_elements.add_child(ground);
	ground.scale = Vector2(4, 4)
	ground.global_position = target.global_position - Vector2(256, 256);
	ground.show();
	
	var blast_area:CollisionShape2D = ground.get_node("blast_area")
	blast_area.reparent(scorched_ground_hit_scan)
	await get_tree().create_timer(scorched_ground_duration).timeout;
	blast_area.queue_free();
	ground.queue_free()
	
func _on_scoched_ground_dmg_ticker_timeout() -> void:
	Combat.aoe_damage(Entities.player_fighter, scorched_ground_hit_scan, 0, true)
