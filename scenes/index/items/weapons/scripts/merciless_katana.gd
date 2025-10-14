extends Weapon

@export var dash_target:Node2D
@export var bar:TextureProgressBar
@export var hint:Label

@export var skill_check_sfx:AudioStreamPlayer

const size_x = 4;
const size_y = 2

const rarity = 3;

func get_description()->String:
	return "Hold to charge an attack in the direction of the cursor, when released, slice through enemies in the trajectory, release in perfect timing to deal double damage.";

var skill_check_tween:Tween;
func start()->void:
	use_sfx.play()
	## animationplayer doesnt work properly with the bar(or control nodes altogether?)?
	bar.show()
	skill_check_tween = create_tween();
	skill_check_tween.tween_property(bar, "value", 120, 1);
	skill_check_tween.tween_callback(Entities.player_fighter.equipment.weapon_control.release_weapon_command);


func release()->void:
	if bar.value < 15:
		fumble();
	elif bar.value < 95 or bar.value > 105:
		dash(false)
	else:
		dash(true)
	if skill_check_tween:
		skill_check_tween.kill()
		reset_bar()

func skill_check_bonus(damage:int)->int:
	return damage * 2;

func dash(hit_skill_check:bool=false)->void:
	Entities.player_fighter.global_position = dash_target.global_position
	if hit_skill_check:
		Combat.aoe_damage(Entities.player_fighter, hit_scan, skill_check_bonus);
	else:
		Combat.aoe_damage(Entities.player_fighter, hit_scan);
	
	if len(Entities.player_fighter.hit_targets):
		hit.emit()
		if hit_skill_check:
			skill_check_sfx.play()
		else:
			hit_sfx.play()
			

func reset_bar()->void:
	bar.value = 0;
	bar.hide()

func fumble()->void:
	Entities.player_fighter.equipment.weapon_fumbled.emit();
	Entities.player_fighter.equipment.weapon_control.weapon_cd.stop();
	

	var new_hint:Label = hint.duplicate();
	Entities.player_fighter.floating_icon_anchor.add_child(new_hint);
	new_hint.show();
	var tween:Tween = create_tween();
	tween.tween_property(new_hint, "position:y", -30, 1);
	tween.parallel().tween_property(new_hint, "modulate:a", 0, 1);
	tween.tween_callback(new_hint.queue_free);

	reset_bar()
