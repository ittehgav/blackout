extends Weapon

@export var dash_target:Node2D
@export var bar:TextureProgressBar
@export var hint:Label




const size_x = 4;
const size_y = 2

const rarity = 3;

func get_description()->String:
	var string:String = "Deals " + str(final_damage()) + " damage to enemies in front of you.\nAlternative use: slice through enemies, dashing a long distance and gaining an "\
	+ Index.stat_colored_name("agility") + " bonus for each enemy hit.";
	return string


var skill_check_tween:Tween;
func start()->void:
	use_sfx.play()
	## animationplayer doesnt work properly with the bar(or control nodes altogether?)?
	bar.show()
	skill_check_tween = create_tween();
	skill_check_tween.tween_property(bar, "value", 120, 1);
	skill_check_tween.tween_callback(Entities.player_fighter.equipment.weapon_control.release_weapon_command);

func use(alt:bool=false)->void:
	if alt:
		dash()
	else:
		use_sfx.play()
		animation_player.play("upward_swing")

func dash()->void:
	alt_use_sfx.play()
	Entities.player_fighter.global_position = dash_target.global_position

	Combat.aoe_damage(Entities.player_fighter, alt_hit_scan);
	
	var agi_gain:float = .3 * len(Entities.player_fighter.hit_targets);
	if agi_gain:
		status.apply_on_target(Entities.player_fighter, agi_gain);
	
	if len(Entities.player_fighter.hit_targets):
		hit.emit()
		hit_sfx.play()
			
func impact()->void:
	Combat.aoe_damage(Entities.player_fighter, hit_scan)
	if len(Entities.player_fighter.hit_targets):
		hit.emit()
		hit_sfx.play()
			
