extends Weapon


const size_x = 3;
const size_y = 2;

const rarity = 2;

@export var vfx_root:Node2D;

func get_description()->String:
	return "Damages all enemies surrounding you, dealing " + Index.get_color_tag("attack") + str(final_damage()) +\
	" damage.[/color] Cooldown is 20% faster for each enemy you hit with the same attack, up to 80% faster.";

func use(_alt:bool=false)->void:
	use_sfx.play();
	animation_player.play("attack")
	
func impact()->void:
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	
	var hits:int = len(Entities.player_fighter.hit_targets)
	if hits:
		apply_cdr(hits);
		hit.emit()

func apply_cdr(hits:int)->void:
	if hits > 4:
		hits = 4;
	var reduction_multiplier:float = .2 * hits
	var timer:Timer = Entities.player_fighter.equipment.weapon_control.weapon_cd;

	var previous_wait_time:float = timer.wait_time;
	var new_wait_time:float = previous_wait_time - previous_wait_time * reduction_multiplier;
	timer.start(new_wait_time) ## apparently doesnt change wait_time?
	timer.wait_time = previous_wait_time


func _on_animation_player_animation_started(_anim_name: StringName) -> void:
	vfx_root.global_position = Entities.player_fighter.global_position;
