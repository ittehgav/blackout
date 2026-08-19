extends Artifice

const size_x = 2;
const size_y = 2;

const rarity = 3;

@export var retrieve_sfx:AudioStreamPlayer;

var initial_inventory_spot:int;

@export var retrieve_spot:Node2D;
@export var retrieve_hitbox:Area2D

func get_description()->String:
	return "In combat, throw to damage enemies and bounce between them until it falls on the ground, can be recast if picked up and returns to inventory at the end of combat."


func use()->bool:
	initial_inventory_spot = get_equipped_slot();
	projectile.reparent(Entities.player_fighter.equipment)
	var p:Projectile = throw();
	p.despawn_timer.timeout.connect(projectile_fall.bind(p))
	return consume()

func hit_callback(hit_target:ActiveFighter)->void:
	if hit_target == Entities.player_fighter:
		retrieve_item();
		return;
	Combat.deal_damage(Entities.player_fighter, hit_target, 100)
	
	hit_sfx.play();

	
	var target:Vector2 = global_position + Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var bounce:StraightProjectile = Combat.shoot_projectile(projectile, Entities.player_fighter, hit_callback, null, target);
	var delta:float= hit_target.hurtbox.get_node("hurtbox").shape.radius * 1.25;

	bounce.global_position = hit_target.global_position + target * delta
	bounce.despawn_timer.timeout.connect(projectile_fall.bind(bounce))

	bounce.hit_scan.monitoring = false;
	await get_tree().create_timer(.1).timeout;
	bounce.hit_scan.monitoring = true


func projectile_fall(target:Projectile) -> void:
	var tween:Tween = create_tween();
	tween.tween_property(target, "flight_speed", 0, 1);
	await get_tree().create_timer(.3).timeout;
	if is_instance_valid(target):
		target.hit_scan.monitoring = false
		await tween.finished;
		setup_retrieve(target.global_position);
		target.queue_free()

	
func setup_retrieve(target_position:Vector2)->void:
	if is_ancestor_of(retrieve_spot):
		retrieve_spot.reparent(Entities.player_fighter.ally_team.projectiles);
		
	retrieve_spot.global_position = target_position;
	retrieve_spot.show();
	retrieve_hitbox.monitoring = true;
	
func retrieve_item()->void:
	retrieve_sfx.play()
	reparent(Entities.player.inventory);
	

	Entities.player.equip_artifice(self, initial_inventory_spot)
	retrieve_spot.hide();
	retrieve_hitbox.monitoring = false;




func _on_retrieve_hitbox_area_entered(area: Area2D) -> void:
	assert(area is HurtBox);
	retrieve_item();
