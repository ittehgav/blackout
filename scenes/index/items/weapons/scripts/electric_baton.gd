extends Weapon

const rarity = 3;

const size_x = 2;
const size_y = 4;




@export var hit_sfx:AudioStreamPlayer
@export var lightning:CombatVFX
@export var extra_bolts_sfx:AudioStreamPlayer;

const total_bolts = 3;
const bolt_range = 500
## make this scale with technique?

var bolts:int = total_bolts ## to override for modifier

@export var bolts_aoe:Array[Area2D]

func get_description()->String:
	var damage:String = Index.colored_text("attack", str(final_damage()) + " damage");
	return "On hit, shoots lightning in random directions, dealing %s to enemies." % [damage];

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
	for i in range(bolts):
		var new_bolt:CombatVFX = lightning.duplicate(DUPLICATE_USE_INSTANTIATION);
		bolts_buffer.append(new_bolt);
		player_fighter.ally_team.projectiles.add_child(new_bolt);
	
		var angle_roll: = randi_range(0, 360)
		new_bolt.rotation_degrees = angle_roll + 90
		
		var aoe:Area2D = bolts_aoe[i];
		aoe.rotation_degrees = angle_roll;

func shoot_bolts(origin:Vector2, buffed:bool = false)->void:
	if buffed:
		Entities.player_fighter.camera.shake_feedback(5)
		extra_bolts_sfx.play()
	for i in range(bolts):
		## targets that were hit by the melee only take 1 bolt hit

		var aoe:Area2D = bolts_aoe[i];
		aoe.global_position = origin;
		await get_tree().process_frame
		
		
		var bolt:CombatVFX = bolts_buffer[i];
		
		bolt.shoot_bolt(Entities.player_fighter.hit_targets[0])
		if buffed:
			bolt.scale *= 2;
			aoe.scale *= 2;
		
		if refinement_level != 3 or buffed:
			bolts_buffer[0].animation_player.animation_finished.connect(clear_bolt.bind(bolt))
		
		Combat.aoe_damage(Entities.player_fighter, aoe)
	if refinement_level == 3 and not buffed:
		await bolts_buffer[0].animation_player.animation_finished
		for bolt in bolts_buffer:
			bolt.rotation_degrees = randi_range(0, 360)
		shoot_bolts(origin, true)
	else:
		if buffed:
			await bolts_buffer[0].animation_player.animation_finished
			for aoe:Area2D in bolts_aoe:
				aoe.scale /= 2
		while len(bolts_buffer):
			bolts_buffer.remove_at(0)


const r1_description = "+10% damage";
const r2_description = "Fires one additional bolt.";
const r3_description = "Fire a second, larger salvo of bolts."

func apply_r1()->void:
	base_damage += base_damage/10
func apply_r2()->void:
	bolts = 4;
func apply_r3()->void:
	pass;

func clear_bolt(_key:String, target:Node2D)->void:
	target.queue_free() ## to catch the animation_finished signal signature
