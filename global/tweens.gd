extends Node

## ALL TWEENS THAT SHOW UP IN MORE THAN ONE SCRIPT WILL BE HERE
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


func arc_vfx(target:Sprite2D)->Tween:
	var clone:Sprite2D = target.duplicate();
	Entities.player_fighter.equipment.add_child(clone)
	clone.position = clone.offset * clone.scale.x;
	clone.offset = Vector2.ZERO
	
	var tween:Tween = create_tween();
	tween.tween_property(clone, "scale", clone.scale * 2, .15);
	tween.parallel().tween_property(clone, "modulate:a", .2, .15)
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
	return shader_color_blink(target.base, Color.PURPLE);

func heal_vfx(target:ActiveFighter, transparency:float =0.0)->Tween:
	return shader_color_blink(target.base, Color.GREEN - Color(0, 0, 0, transparency), 1);

func damage_vfx(target:ActiveFighter, intensity:int, from_player:bool=false)->Tween:
	var target_color:Color = Color.RED

	var duration:float = 1.0;
	if intensity == 1.0:
		target_color.a -= .8;
		duration = .2
	elif intensity == 2.0:
		target_color.a -= .5;
		duration = .3
	
	if from_player:
		target_color = Color.WHITE;
	
	return shader_color_blink(target.base, target_color, duration)

func stat_debuff_vfx(target:ActiveFighter)->Tween:
	return shader_color_blink(target.base, Color.PURPLE);
	
func stat_buff_vfx(target:ActiveFighter)->Tween:
	return shader_color_blink(target.base, Color.BLUE)


	
func lunge_forward_tween(fighter:ActiveFighter)->Tween:
	var gap:Vector2;
	if fighter.name != "player_fighter":
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
	var shift:Vector2 = fighter.base.position.move_toward(-gap, 50);
	fighter.base.position = shift
	
	var tween:Tween = create_tween();
	tween.tween_property(fighter.base,"position", Vector2.ZERO, .2);
	return tween

func camera_lunge(fighter:ActiveFighter)->Tween:
	var shift:Vector2 = fighter.camera.position.move_toward(fighter.camera.get_local_mouse_position(), 1);
	fighter.camera.offset = shift
	
	var tween:Tween = create_tween();
	tween.tween_property(fighter.camera, "offset", Vector2.ZERO, .1 );
	return tween;

func camera_recoil(fighter:ActiveFighter)->Tween:
	var gap:Vector2 = Vector2(-100, -50)
	if fighter.body.flip_h:
		gap.x *= -1
	var shift:Vector2 = fighter.base.position.move_toward(gap,100);
	fighter.camera.offset = shift
	
	var tween:Tween = create_tween();
	tween.tween_property(fighter.camera, "offset", Vector2.ZERO, .5 );
	return tween;

func ui_fade_in(target:CanvasItem, duration:float = .5)->Tween:
	target.show();
	
	target.modulate.a = .1
	## tween goes into the control because of nodes that process when pasued
	var tween:Tween = create_tween();
	tween.tween_property(target, "modulate:a", 1, duration);
	return tween

func ui_fade_out(target:CanvasItem, hide_after:bool=true, duration:float = .5)->Tween:
	var tween:Tween = create_tween();
	tween.tween_property(target,"modulate:a", 0, duration);
	if hide_after:
		tween.tween_callback(target.hide);
		return tween;
	else:
		return tween;



func shader_color_blink(target:FighterBase, target_color:Color, duration:float = .3)->Tween:
	target.material.set_shader_parameter("target_color", target_color);
	target.material.set_shader_parameter("grad", 1.0);

	var tween:Tween = create_tween();
	tween.tween_property(target.material, "shader_parameter/grad", 0.0, duration);
	return tween;

func weapon_grow(weapon:Weapon)->void:
	var tween: = create_tween();
	weapon.scale = Vector2(1.5, 1.5);
	tween.tween_property(weapon, "scale", Vector2.ONE, .5);




func fade_up(target:CanvasItem, free_after:bool = true)->Tween:
	var tween:Tween = create_tween();
	tween.tween_property(target, "position:y", target.position.y - 50, .5)
	if free_after:
		tween.parallel().tween_property(target, "modulate:a", 0, .5)
		tween.tween_callback(target.queue_free);
	return tween
	

func squish_bar(target:TextureProgressBar)->Tween:
	## bar can't be in a container
	target.scale = Vector2(.9, .5);
	var tween:Tween = create_tween();
	tween.tween_property(target, "scale", Vector2.ONE, .2);
	return tween;

func stretch_bar(target:TextureProgressBar)->Tween:
	## bar can't be in a container
	target.scale = Vector2(1.1, 1.5);
	var tween:Tween = create_tween();
	tween.tween_property(target, "scale", Vector2.ONE, .5);
	return tween;

func color_blink(target:CanvasItem, target_color:Color, duration:float = .2, target_property:String="modulate")->Tween:
	target[target_property] = target_color;

	var tween:Tween = create_tween();
	tween.tween_property(target, target_property, Color.WHITE, duration);
	return tween

func y_shake(target:CanvasItem, shake_count:int = 2, shake_range:int = 50)->Tween:
	var initial_y:int = target.position.y;
	var roll_1:int = randi_range(0, shake_range)
	target.position.y -= roll_1
	
	var tween:Tween = create_tween();
	for i in shake_count:
		var roll:int = randi_range(0, shake_range)
		if i % 2:
			roll *= -1;
		tween.tween_property(target, "position:y", initial_y + roll, .1)
	tween.tween_property(target, "position:y", initial_y, .1);

	return tween
	
func tween_count_label(target:Label, final_value:int, duration:float = .5)->Tween:
	var tween:Tween = create_tween();
	var current_value:int = int(target.text)
	tween.tween_method(set_label_text.bind(target), current_value, final_value, duration );
	return tween

func set_label_text(label:Label, target:int)->void:
	label.text = str(target)
