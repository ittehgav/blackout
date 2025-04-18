extends Node

## ALL TWEENS WILL BE DONE HERE
## all tween functions will return their tween


func swing_tween(target:Sprite2D, duration:float = .05)->Tween:
	var target_rotation:float;
	if target.swung:
		target_rotation = 0;
	else:
		target_rotation = 120;
	target.swung = not target.swung;

	var off_tween:Tween = create_tween();
	off_tween.tween_property(target, "skew", 45, duration/2)
	off_tween.tween_property(target, "skew", 0, duration/2)
	
	var tween:Tween = create_tween();
	tween.tween_property(target, "rotation_degrees", target_rotation, duration);
	return tween;


func arc_vfx(target:Polygon2D)->Tween:
	var clone:Polygon2D = target.duplicate();
	Entities.in_fight_player.hit_scan.add_child(clone)
	clone.show();
	
	var tween:Tween = create_tween();
	tween.tween_property(clone, "scale", Vector2(1.5, 1.5), .1);
	tween.parallel().tween_property(clone, "modulate:a", .2, .1)
	tween.tween_callback(clone.queue_free)
	
	return tween;
	
func gun_recoil(gun:Weapon)->Tween:
	gun.offset =  Vector2(-30, -30);
	gun.rotation_degrees = -30;
	
	const tween_duration = .25;
	var tween: = create_tween();
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(gun, "offset",Vector2.ZERO, tween_duration);
	tween.parallel().tween_property(gun, "rotation_degrees", 0, tween_duration)
	
	return tween

func stun_vfx(target:ActiveFighter)->Tween:
	return color_blink(target.base, Color.PURPLE);

func heal_vfx(target:ActiveFighter, transparency:float =0.0)->Tween:
	return color_blink(target.base, Color.GREEN - Color(0, 0, 0, transparency), 1);

func damage_vfx(target:ActiveFighter, intensity:int)->Tween:
	var target_color:Color = Color.RED
	var duration:float = 1.0;
	if intensity == 1.0:
		target_color.a -= .8;
		duration = .2
	elif intensity == 2.0:
		target_color.a -= .5;
		duration = .3
	
	return color_blink(target.base, target_color, duration)

func stat_debuff_vfx(target:ActiveFighter)->Tween:
	return color_blink(target.base, Color.PURPLE);
	
func stat_buff_vfx(target:ActiveFighter)->Tween:
	return color_blink(target.base, Color.BLUE)


	
func lunge_forward_tween(fighter:ActiveFighter)->Tween:
	var gap:Vector2;
	if fighter.name != "in_fight_player":
		gap =  fighter.target_unit.position - fighter.position;
	else:
		gap = fighter.get_node("hit_scan/shape").position
	var shift:Vector2 = fighter.base.position.move_toward(gap, 100);
	fighter.base.position = shift

	var tween:Tween = create_tween();
	tween.tween_property(fighter.base,"position", Vector2.ZERO, .1);
	return tween

func recoil_tween(fighter:ActiveFighter)->Tween:
	var gap:Vector2 =  fighter.target_unit.position - fighter.position;
	var shift:Vector2 = fighter.base.position.move_toward(gap * -1, 50);
	fighter.base.position = shift
	
	var tween:Tween = create_tween();
	tween.tween_property(fighter.base,"position", Vector2.ZERO, .2);
	return tween

func camera_lunge(fighter:ActiveFighter)->Tween:
	var gap:Vector2 = fighter.get_node("hit_scan/shape").position
	var shift:Vector2 = fighter.base.position.move_toward(gap, 100);
	fighter.camera.offset = shift
	
	var tween:Tween = create_tween();
	tween.tween_property(fighter.camera, "offset", Vector2.ZERO, .1 );
	return tween;


func ui_fade_in(target:Control)->Tween:
	target.modulate.a = .1
	
	## tween goes into the control because of nodes that process when pasued
	var tween:Tween = target.create_tween();
	tween.tween_property(target, "modulate:a", 1, .5);
	
	return tween

func growth_tween(unit:ActiveFighter)->Tween:
	unit.base.scale *= 2
	var return_scale:Vector2 = unit.base.scale/2
	
	var tween:Tween = create_tween();
	tween.tween_property(unit.base, "scale", return_scale, .2);
	
	return tween;

func recoil_target(unit:ActiveFighter)->Tween:
	var target:ActiveFighter = unit.target_unit
	var rel:Vector2 = (target.position - unit.position).normalized();
	var target_recoil:Vector2 = rel * 50;
	target.base.position = target_recoil;
	
	var tween:Tween = create_tween();
	tween.tween_property(target.base, "position", Vector2.ZERO, .25);
	return tween;

func color_blink(target:FighterBase, target_color:Color, duration:float = .3)->Tween:
	target.material.set_shader_parameter("target_color", target_color);
	target.material.set_shader_parameter("grad", 1.0);

	var tween:Tween = create_tween();
	tween.tween_property(target.material, "shader_parameter/grad", 0.0, duration);
	return tween;

func weapon_grow(weapon:Weapon):
	var tween = create_tween();
	weapon.scale = Vector2(1.5, 1.5);
	tween.tween_property(weapon, "scale", Vector2.ONE, .5);
	
