extends Weapon

const rarity = 3;

const size_x = 2;
const size_y = 4;


const r1_improvement = "Fires 1 additional bolt";
const r2_improvement = "+25% damage per bolt";
const r3_improvement = "Each bolt chains to 1 additional enemy."

@export var hit_sfx:AudioStreamPlayer
@export var lightning:CombatVFX

const total_bolts = 3;
const bolt_range = 500
## make this scale with technique?

@export var bolts_aoe:Array[Area2D]

func get_description()->String:
	var damage:String = Index.colored_text("attack", str(final_damage()) + " damage");
	return "On hit, shoots lightning in random directions, dealing %s to hit enemies." % [damage];

func use(_alt:bool=false)->void:
	animation_player.play("melee/attack");
	pending_impact = true;
	
func impact()->void:
	generate_bolts()
	
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	pending_impact = false;
	
	if len(Entities.player_fighter.hit_targets):
		hit_sfx.play()
		hit.emit();
		shoot_bolts(Entities.player_fighter.hit_targets[0].global_position);
	else:
		clear_bolts();

func clear_bolts()->void:
	while len(bolts_buffer):
		var bolt:CombatVFX=bolts_buffer[0]
		bolts_buffer.erase(bolt);
		bolt.queue_free()

var bolts_buffer:Array[CombatVFX]
func generate_bolts()->void:
	var player_fighter:PlayerFighter = Entities.player_fighter;
	for i in range(total_bolts):
		var new_bolt:CombatVFX = lightning.duplicate(DUPLICATE_USE_INSTANTIATION);
		bolts_buffer.append(new_bolt);
		player_fighter.ally_team.projectiles.add_child(new_bolt);
	
		var angle_roll: = randi_range(0, 360)
		new_bolt.rotation_degrees = angle_roll + 90
		
		var aoe:Area2D = bolts_aoe[i];
		aoe.rotation_degrees = angle_roll;

func shoot_bolts(origin:Vector2)->void:
	for i in range(3):
		## targets that were hit by the melee only take 1 bolt hit

		var aoe:Area2D = bolts_aoe[i];
		aoe.global_position = origin;
		await get_tree().process_frame
		
		var bolt:CombatVFX = bolts_buffer[i];
		bolt.shoot_bolt(Entities.player_fighter)
		bolt.animation_player.animation_finished.connect(bolt.queue_free)
		Combat.aoe_damage(Entities.player_fighter, aoe)

	while len(bolts_buffer):
		bolts_buffer.remove_at(0)
		
