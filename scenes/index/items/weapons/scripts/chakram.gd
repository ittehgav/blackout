extends Weapon


const size_x = 3;
const size_y = 2;

const rarity = 2;

func get_description()->String:
	return "Damages all enemies surrounding you, dealing " + Index.get_color_tag("attack") + str(final_damage()) +\
	"damage. Cooldown is 20% faster for each enemy you hit with the same attack, up to 80%.";

func use(_alt:bool=false)->void:

	use_sfx.play();
	animation_player.play("attack")
	
func impact()->void:
	Combat.aoe_damage(Entities.player_fighter, hit_scan);
	
	var hits:int = len(Entities.player_fighter.hit_targets)
	if hits:
		apply_cdr(hits);
		hit_sfx.play();
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
