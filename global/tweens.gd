extends Node

## ALL TWEENS WILL BE DONE HERE
## all tween functions will return their tween

func stat_icon_sprite(stat:String)->Sprite2D:
	var sprite = Sprite2D.new();
	match stat:
		"defense", "attack", "max_hp", "move_speed":
			sprite.texture = Icons[stat];
	return sprite;

func swing_tween(target:Sprite2D, duration:float = .05)->Tween:
	var target_rotation:float;
	if target.swung:
		target_rotation = 0;
	else:
		target_rotation = 120;
	target.swung = not target.swung;

	var off_tween = create_tween();
	off_tween.tween_property(target, "skew", 45, duration/2)
	off_tween.tween_property(target, "skew", 0, duration/2)
	
	var tween:Tween = create_tween();
	tween.tween_property(target, "rotation_degrees", target_rotation, duration);
	return tween;


func arc_vfx(target:Polygon2D)->Tween:
	var clone:Polygon2D = target.duplicate();
	Entities.fighting_player.hit_scan.add_child(clone)
	clone.position = Vector2(60, -20)
	clone.show();
	
	var tween = create_tween();
	tween.parallel().tween_property(clone, "modulate:a", .2, .1)
	tween.tween_callback(clone.queue_free)
	
	return tween;
	
func stun_vfx(target:ActiveFighter)->Tween:
	var tween = create_tween();
	var up_bounce = Vector2(-10, -50);
	var down_bounce = Vector2(10, 50);
	tween.tween_property(target.base, "position", up_bounce, .1);
	tween.tween_property(target.base, "position", down_bounce, .1);
	tween.tween_property(target.base, "position", Vector2.ZERO, .05)
	
	return tween;

	
func heal_vfx(target:ActiveFighter)->Tween:
	return color_blink(target.base, Color.GREEN);

func stat_change_vfx(target:ActiveFighter, stat:String, positive:bool)->Tween:
	var blink_color:Color;
	if positive:
		blink_color = Color.BLUE;
	else:
		blink_color = Color.REBECCA_PURPLE
		
	var icon = stat_icon_sprite(stat);
	target.floating_icon_anchor.add_child(icon);
	
	var y_shift = -30;
	if not positive:
		icon.modulate = Color.RED;
		y_shift *= -1
	else:
		icon.modulate = Color.BLUE

	var icon_tween:Tween = create_tween();
	icon_tween.tween_property(icon, "position:y", y_shift, .45);
	icon_tween.parallel().tween_property(icon, "modulate:a", 0, .45)
	icon_tween.tween_callback(icon.queue_free);
	
	return color_blink(target.base, blink_color);

func damage_blink(target:ActiveFighter)->Tween:
	return color_blink(target.base, Color.RED)

func color_blink(target:FighterBase, target_color:Color)->Tween:
	target.material.set_shader_parameter("target_color", target_color);
	target.material.set_shader_parameter("grad", 1.0);

	var tween = create_tween();
	tween.tween_property(target.material, "shader_parameter/grad", 0.0, .3);
	return tween;

func damage_overlay_tween(target:Label, intensity:float)->Tween:
	var shake_range:float = 50 * intensity;
	
	var back_x = shake_range * -1;
	var back_y = randf_range(shake_range * -1, shake_range);
	var back_v2 = Vector2(back_x, back_y);
	
	var forth_x = shake_range;
	var forth_y = randf_range(shake_range * -1, shake_range);
	var forth_v2 = Vector2(forth_x, forth_y);
	
	const step = .025;
	var tween = create_tween();
	tween.tween_property(target, "position", back_v2, step);
	tween.tween_property(target, "position", forth_v2, step);
	tween.tween_property(target, "position", Vector2.ZERO, step);
	return tween;

func death_vfx(target:ActiveFighter)->Tween:
	target.modulate = Color.DARK_RED;
	
	var tween:Tween = create_tween();
	tween.tween_property(target, "modulate:a", 0, .5);
	return tween;
	
func lunge_forward_tween(fighter:ActiveFighter)->Tween:
	var gap:Vector2;
	if fighter.name != "in_fight_player":
		gap =  fighter.target_unit.position - fighter.position;
	else:
		gap = fighter.get_node("hit_scan/shape").position
	var shift = fighter.base.position.move_toward(gap, 100);
	fighter.base.position = shift

	var tween = create_tween();
	tween.tween_property(fighter.base,"position", Vector2.ZERO, .1);
	return tween

func recoil_tween(fighter:ActiveFighter)->Tween:
	var gap =  fighter.target_unit.position - fighter.position;
	var shift = fighter.base.position.move_toward(gap * -1, 50);
	fighter.base.position = shift
	
	var tween = create_tween();
	tween.tween_property(fighter.base,"position", Vector2.ZERO, .2);
	return tween

func camera_lunge(fighter:ActiveFighter)->Tween:
	var gap = fighter.get_node("hit_scan/shape").position
	var shift = fighter.base.position.move_toward(gap, 100);
	fighter.camera.offset = shift
	
	var tween = create_tween();
	tween.tween_property(fighter.camera, "offset", Vector2.ZERO, .1 );
	return tween;
